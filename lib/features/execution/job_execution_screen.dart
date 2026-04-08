import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';

import 'package:sevix_worker/features/jobs/worker_job.dart';

enum JobPhase { enRoute, arrived, inProgress, review }

final jobPhaseProvider = StateProvider.autoDispose<JobPhase>((ref) {
  return JobPhase.enRoute;
});

class JobExecutionScreen extends ConsumerStatefulWidget {
  final WorkerJob job;
  final String selectedLanguage;

  const JobExecutionScreen({
    super.key,
    required this.job,
    this.selectedLanguage = 'en',
  });

  @override
  ConsumerState<JobExecutionScreen> createState() => _JobExecutionScreenState();
}

class _JobExecutionScreenState extends ConsumerState<JobExecutionScreen> {
  static const String _mapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );
  static const String _directionsApiKey = String.fromEnvironment(
    'GOOGLE_DIRECTIONS_API_KEY',
    defaultValue: '',
  );

  final ImagePicker _picker = ImagePicker();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2.8,
    penColor: const Color(0xFF0B1533),
    exportBackgroundColor: Colors.white,
  );

  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionSubscription;
  Position? _workerPosition;
  Position? _lastWorkerPosition;
  List<LatLng> _routePoints = const [];

  bool _isLoadingRoute = false;
  bool _isSubmitting = false;
  bool _signatureConfirmed = false;
  XFile? _completionPhoto;

  @override
  void initState() {
    super.initState();
    _bootstrapLocationTracking();
    _signatureController.addListener(_onSignatureChanged);
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _mapController?.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  String _t(String en, String si, String ta) {
    switch (widget.selectedLanguage) {
      case 'si':
        return si;
      case 'ta':
        return ta;
      case 'en':
      default:
        return en;
    }
  }

  Future<void> _bootstrapLocationTracking() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      _showSnack(
        _t(
          'Location services are disabled.',
          'ස්ථාන සේවාව අක්‍රියයි.',
          'இருப்பிட சேவை முடக்கப்பட்டுள்ளது.',
        ),
      );
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _showSnack(
        _t(
          'Location permission is required for live navigation.',
          'සජීවී මාර්ගනය සඳහා ස්ථාන අවසරය අවශ්‍යයි.',
          'நேரடி வழிசெலுத்தல் కోసం இருப்பிட அனுமதி தேவை.',
        ),
      );
      return;
    }

    final current = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _workerPosition = current;
      _lastWorkerPosition = current;
    });

    await _refreshRoute();

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (position) async {
            if (!mounted) {
              return;
            }

            await _animateWorkerMarker(position);

            final phase = ref.read(jobPhaseProvider);
            if (phase == JobPhase.enRoute || phase == JobPhase.arrived) {
              await _refreshRoute();
            }
          },
        );
  }

  Future<void> _animateWorkerMarker(Position nextPosition) async {
    final from = _lastWorkerPosition;

    if (from == null) {
      setState(() {
        _workerPosition = nextPosition;
        _lastWorkerPosition = nextPosition;
      });
      return;
    }

    const steps = 6;
    for (var i = 1; i <= steps; i++) {
      if (!mounted) {
        return;
      }
      final t = i / steps;
      final lat = from.latitude + (nextPosition.latitude - from.latitude) * t;
      final lng =
          from.longitude + (nextPosition.longitude - from.longitude) * t;
      setState(() {
        _workerPosition = Position(
          longitude: lng,
          latitude: lat,
          timestamp: DateTime.now(),
          accuracy: nextPosition.accuracy,
          altitude: nextPosition.altitude,
          altitudeAccuracy: nextPosition.altitudeAccuracy,
          heading: nextPosition.heading,
          headingAccuracy: nextPosition.headingAccuracy,
          speed: nextPosition.speed,
          speedAccuracy: nextPosition.speedAccuracy,
        );
      });
      await Future<void>.delayed(const Duration(milliseconds: 80));
    }

    _lastWorkerPosition = nextPosition;
  }

  Future<void> _refreshRoute() async {
    final current = _workerPosition;
    if (current == null) {
      return;
    }

    final origin = LatLng(current.latitude, current.longitude);
    final destination = LatLng(widget.job.latitude, widget.job.longitude);

    setState(() {
      _isLoadingRoute = true;
    });

    try {
      final points = await _fetchRoutePolyline(origin, destination);
      if (!mounted) {
        return;
      }
      setState(() {
        _routePoints = points.isEmpty ? [origin, destination] : points;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _routePoints = [origin, destination];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRoute = false;
        });
      }
    }
  }

  Future<List<LatLng>> _fetchRoutePolyline(
    LatLng origin,
    LatLng destination,
  ) async {
    if (_directionsApiKey.isEmpty) {
      return [origin, destination];
    }

    final uri = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'mode': 'driving',
      'key': _directionsApiKey,
    });

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Directions API error');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = (data['routes'] as List<dynamic>? ?? const []);
    if (routes.isEmpty) {
      return [origin, destination];
    }

    final polyline =
        (routes.first as Map<String, dynamic>)['overview_polyline']
            as Map<String, dynamic>? ??
        const {};
    final encoded = (polyline['points'] as String?) ?? '';
    if (encoded.isEmpty) {
      return [origin, destination];
    }

    return _decodePolyline(encoded);
  }

  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    var index = 0;
    var lat = 0;
    var lng = 0;

    while (index < encoded.length) {
      var b = 0;
      var shift = 0;
      var result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dLat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dLng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  void _onSignatureChanged() {
    if (_signatureConfirmed && mounted) {
      setState(() {
        _signatureConfirmed = false;
      });
    }
  }

  void _showSnack(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  double _distanceMeters(Position current) {
    return Geolocator.distanceBetween(
      current.latitude,
      current.longitude,
      widget.job.latitude,
      widget.job.longitude,
    );
  }

  Future<void> _moveToNextPhase() async {
    final current = ref.read(jobPhaseProvider);

    switch (current) {
      case JobPhase.enRoute:
        ref.read(jobPhaseProvider.notifier).state = JobPhase.arrived;
        _showSnack(
          _t(
            'Customer notified: You have arrived.',
            'ඔබ පැමිණි බව පාරිභෝගිකයාට දැනුම් දුන්නා.',
            'நீங்கள் வந்துவிட்டீர்கள் என வாடிக்கையாளருக்கு அறிவிக்கப்பட்டது.',
          ),
        );
        return;
      case JobPhase.arrived:
        ref.read(jobPhaseProvider.notifier).state = JobPhase.inProgress;
        _showSnack(
          _t(
            'Work session started.',
            'වැඩ ආරම්භ විය.',
            'வேலை அமர்வு தொடங்கியது.',
          ),
        );
        return;
      case JobPhase.inProgress:
        ref.read(jobPhaseProvider.notifier).state = JobPhase.review;
        return;
      case JobPhase.review:
        return;
    }
  }

  Future<void> _captureCompletionPhoto() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 2000,
    );

    if (!mounted || file == null) {
      return;
    }

    setState(() {
      _completionPhoto = file;
    });
  }

  Future<void> _confirmSignature() async {
    if (_signatureController.isEmpty) {
      _showSnack(
        _t(
          'Customer signature is required.',
          'පාරිභෝගික අත්සන අවශ්‍යයි.',
          'வாடிக்கையாளர் கையொப்பம் தேவை.',
        ),
      );
      return;
    }

    setState(() {
      _signatureConfirmed = true;
    });

    _showSnack(
      _t(
        'Signature confirmed.',
        'අත්සන තහවුරු කරන ලදී.',
        'கையொப்பம் உறுதிப்படுத்தப்பட்டது.',
      ),
    );
  }

  Future<void> _finishAndRequestPayment() async {
    if (_completionPhoto == null || !_signatureController.isNotEmpty) {
      _showSnack(
        _t(
          'Photo and signature are both required.',
          'ඡායාරූපය සහ අත්සන දෙකම අවශ්‍යයි.',
          'புகைப்படம் மற்றும் கையொப்பம் இரண்டும் தேவை.',
        ),
      );
      return;
    }

    if (!_signatureConfirmed) {
      _showSnack(
        _t(
          'Please confirm customer signature first.',
          'කරුණාකර පළමුව අත්සන තහවුරු කරන්න.',
          'முதலில் கையொப்பத்தை உறுதிப்படுத்தவும்.',
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final signatureBytes = await _signatureController.toPngBytes(
        height: 280,
        width: 880,
      );

      if (signatureBytes == null || signatureBytes.isEmpty) {
        throw Exception('Signature export failed');
      }

      final now = DateTime.now();
      final basePath =
          'job_completions/${widget.job.id}/${now.millisecondsSinceEpoch}';

      final photoRef = FirebaseStorage.instance.ref().child(
        '$basePath-completion-photo.jpg',
      );
      await photoRef.putFile(File(_completionPhoto!.path));
      final photoUrl = await photoRef.getDownloadURL();

      final signatureRef = FirebaseStorage.instance.ref().child(
        '$basePath-customer-signature.png',
      );
      await signatureRef.putData(
        Uint8List.fromList(signatureBytes),
        SettableMetadata(contentType: 'image/png'),
      );
      final signatureUrl = await signatureRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.job.id)
          .set({
            'status': 'completed',
            'completedAt': FieldValue.serverTimestamp(),
            'completionPhotoUrl': photoUrl,
            'customerSignatureUrl': signatureUrl,
          }, SetOptions(merge: true));

      if (!mounted) {
        return;
      }

      _showSnack(
        _t(
          'Job marked as completed. Payment request sent.',
          'වැඩ සම්පූර්ණයි. ගෙවීම් ඉල්ලීම යොමු විය.',
          'வேலை முடிந்தது. கட்டணம் கோரிக்கை அனுப்பப்பட்டது.',
        ),
      );

      Navigator.of(context).pop();
    } catch (_) {
      _showSnack(
        _t(
          'Upload failed. Status was not changed. Please retry.',
          'උඩුගත කිරීම අසාර්ථකයි. තත්ත්වය වෙනස් කළේ නැහැ.',
          'பதிவேற்றம் தோல்வி. நிலை மாற்றப்படவில்லை.',
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _primaryButtonLabel(JobPhase phase) {
    switch (phase) {
      case JobPhase.enRoute:
        return _t('I have arrived', 'මම පැමිණිවා', 'நான் வந்துவிட்டேன்');
      case JobPhase.arrived:
        return _t('Start Work', 'වැඩ ආරම්භ කරන්න', 'வேலை தொடங்கு');
      case JobPhase.inProgress:
        return _t('Complete Job', 'වැඩ සම්පූර්ණ කරන්න', 'வேலை முடிக்கவும்');
      case JobPhase.review:
        return _t(
          'Finish & Request Payment',
          'අවසන් කර ගෙවීම් ඉල්ලන්න',
          'முடித்து பணம் கோரவும்',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final phase = ref.watch(jobPhaseProvider);

    if (phase == JobPhase.review) {
      return _buildCompletionScreen();
    }

    return _buildNavigationScreen(phase);
  }

  Widget _buildNavigationScreen(JobPhase phase) {
    final current = _workerPosition;
    final destination = LatLng(widget.job.latitude, widget.job.longitude);

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        infoWindow: InfoWindow(title: widget.job.customerName),
      ),
    };

    if (current != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('worker'),
          position: LatLng(current.latitude, current.longitude),
          rotation: current.heading,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          anchor: const Offset(0.5, 0.5),
          flat: true,
        ),
      );
    }

    final polylines = <Polyline>{};
    if (_routePoints.length >= 2) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('live-route'),
          points: _routePoints,
          color: const Color(0xFF0F4C81),
          width: 6,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: _mapsApiKey.isEmpty
                ? _buildMapUnavailableView()
                : GoogleMap(
                    style: _silverMapStyleJson,
                    initialCameraPosition: CameraPosition(
                      target: current == null
                          ? destination
                          : LatLng(current.latitude, current.longitude),
                      zoom: 14.8,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    compassEnabled: true,
                    mapToolbarEnabled: false,
                    markers: markers,
                    polylines: polylines,
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                  ),
          ),
          if (_isLoadingRoute)
            const Positioned(
              top: 56,
              left: 16,
              right: 16,
              child: LinearProgressIndicator(minHeight: 4),
            ),
          Positioned(
            top: 42,
            left: 16,
            right: 16,
            child: Card(
              color: Colors.white.withValues(alpha: 0.94),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.navigation, color: Color(0xFF0B1533)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _directionsApiKey.isEmpty
                            ? _t(
                                'Set GOOGLE_DIRECTIONS_API_KEY for fastest route.',
                                'වේගවත් මාර්ගය සඳහා GOOGLE_DIRECTIONS_API_KEY සකසන්න.',
                                'விரைவு பாதைக்கு GOOGLE_DIRECTIONS_API_KEY அமைக்கவும்.',
                              )
                            : _t(
                                'Live fastest route is active.',
                                'සජීවී වේගවත් මාර්ගය ක්‍රියාත්මකයි.',
                                'நேரடி விரைவு பாதை இயங்குகிறது.',
                              ),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildControlPanel(phase, current),
    );
  }

  Widget _buildMapUnavailableView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
        ),
      ),
      child: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 22),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.map_outlined,
                  size: 34,
                  color: Color(0xFF0B1533),
                ),
                const SizedBox(height: 8),
                Text(
                  _t(
                    'Embedded map is disabled.',
                    'අභ්‍යන්තර සිතියම අක්‍රියයි.',
                    'உள்ளமைவு வரைபடம் முடக்கப்பட்டுள்ளது.',
                  ),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  _t(
                    'Set GOOGLE_MAPS_API_KEY in --dart-define to enable map view and avoid runtime disconnects.',
                    'සිතියම සක්‍රීය කර runtime disconnect වැළැක්වීමට --dart-define තුළ GOOGLE_MAPS_API_KEY සකසන්න.',
                    'வரைபடத்தை இயக்கவும் runtime disconnect தவிர்க்கவும் --dart-define இல் GOOGLE_MAPS_API_KEY அமைக்கவும்.',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF334155)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlPanel(JobPhase phase, Position? current) {
    final meters = current == null ? null : _distanceMeters(current);
    final kmText = meters == null
        ? '--'
        : '${(meters / 1000).toStringAsFixed((meters / 1000) < 10 ? 1 : 0)} km';

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 18,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFFE8EEF7),
                    child: Text(
                      widget.job.customerName
                          .trim()
                          .split(RegExp(r'\\s+'))
                          .take(2)
                          .map((e) => e.isEmpty ? '' : e[0].toUpperCase())
                          .join(),
                      style: const TextStyle(
                        color: Color(0xFF0B1533),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.job.customerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          widget.job.location,
                          style: const TextStyle(color: Color(0xFF475569)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      kmText,
                      style: const TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              LinearProgressIndicator(
                minHeight: 8,
                value: _phaseProgress(phase),
                borderRadius: BorderRadius.circular(999),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _moveToNextPhase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B1533),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  child: Text(_primaryButtonLabel(phase)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _phaseProgress(JobPhase phase) {
    switch (phase) {
      case JobPhase.enRoute:
        return 0.33;
      case JobPhase.arrived:
        return 0.66;
      case JobPhase.inProgress:
        return 1.0;
      case JobPhase.review:
        return 1.0;
    }
  }

  Widget _buildCompletionScreen() {
    final canSubmit =
        _completionPhoto != null &&
        _signatureController.isNotEmpty &&
        _signatureConfirmed;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _t(
            'Job Completion & Proof',
            'වැඩ අවසන් කිරීම',
            'வேலை நிறைவு & ஆதாரம்',
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t(
                      'Job Finished Photo',
                      'වැඩ අවසන් ඡායාරූපය',
                      'வேலை முடிந்த புகைப்படம்',
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: _completionPhoto == null
                        ? OutlinedButton.icon(
                            onPressed: _captureCompletionPhoto,
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: Text(
                              _t(
                                'Take Mandatory Photo',
                                'අනිවාර්ය ඡායාරූපය ගන්න',
                                'கட்டாய புகைப்படம் எடுக்கவும்',
                              ),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_completionPhoto!.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  if (_completionPhoto != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextButton.icon(
                        onPressed: _captureCompletionPhoto,
                        icon: const Icon(Icons.replay),
                        label: Text(
                          _t(
                            'Retake Photo',
                            'නැවත ඡායාරූපය ගන්න',
                            'மீண்டும் எடுக்கவும்',
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t(
                      'Customer Signature',
                      'පාරිභෝගික අත්සන',
                      'வாடிக்கையாளர் கையொப்பம்',
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 190,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Signature(
                      controller: _signatureController,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          _signatureController.clear();
                          setState(() {
                            _signatureConfirmed = false;
                          });
                        },
                        icon: const Icon(Icons.clear),
                        label: Text(_t('Clear', 'මකන්න', 'அழிக்கவும்')),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _confirmSignature,
                        icon: const Icon(Icons.verified),
                        label: Text(
                          _t(
                            'Confirm Signature',
                            'අත්සන තහවුරු කරන්න',
                            'கையொப்பம் உறுதிசெய்யவும்',
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        _signatureConfirmed
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: _signatureConfirmed
                            ? Colors.green
                            : const Color(0xFF64748B),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canSubmit && !_isSubmitting
                  ? _finishAndRequestPayment
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B1533),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              icon: _isSubmitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.lock_clock),
              label: Text(
                _t(
                  'Finish & Request Payment',
                  'අවසන් කර ගෙවීම් ඉල්ලන්න',
                  'முடித்து பணம் கோரவும்',
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _t(
              'Cloud Function should process final fee and payout after status becomes completed.',
              'completed තත්වයෙන් පසු Cloud Function මඟින් ගාස්තු හා ගෙවීම සිදු විය යුතුය.',
              'completed நிலைக்குப் பிறகு Cloud Function கட்டணம் மற்றும் payout செயல்படுத்த வேண்டும்.',
            ),
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

const String _silverMapStyleJson = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]
''';

