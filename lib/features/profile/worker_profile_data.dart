class WorkerProfileData {
  final String fullName;
  final String profilePhotoPath;
  final String email;
  final String countryCode;
  final String telephone;
  final String dateOfBirth;
  final String address;
  final String city;
  final String nationalId;
  final List<String> workerTypes;
  final String experienceYears;
  final String bio;
  final String serviceRadiusKm;
  final String nicPhotoPath;

  const WorkerProfileData({
    required this.fullName,
    required this.profilePhotoPath,
    required this.email,
    required this.countryCode,
    required this.telephone,
    required this.dateOfBirth,
    required this.address,
    required this.city,
    required this.nationalId,
    required this.workerTypes,
    required this.experienceYears,
    required this.bio,
    required this.serviceRadiusKm,
    required this.nicPhotoPath,
  });

  factory WorkerProfileData.empty() {
    return const WorkerProfileData(
      fullName: '',
      profilePhotoPath: '',
      email: '',
      countryCode: '+94',
      telephone: '',
      dateOfBirth: '',
      address: '',
      city: '',
      nationalId: '',
      workerTypes: <String>[],
      experienceYears: '',
      bio: '',
      serviceRadiusKm: '5',
      nicPhotoPath: '',
    );
  }

  WorkerProfileData copyWith({
    String? fullName,
    String? profilePhotoPath,
    String? email,
    String? countryCode,
    String? telephone,
    String? dateOfBirth,
    String? address,
    String? city,
    String? nationalId,
    List<String>? workerTypes,
    String? experienceYears,
    String? bio,
    String? serviceRadiusKm,
    String? nicPhotoPath,
  }) {
    return WorkerProfileData(
      fullName: fullName ?? this.fullName,
      profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
      email: email ?? this.email,
      countryCode: countryCode ?? this.countryCode,
      telephone: telephone ?? this.telephone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      city: city ?? this.city,
      nationalId: nationalId ?? this.nationalId,
      workerTypes: workerTypes ?? this.workerTypes,
      experienceYears: experienceYears ?? this.experienceYears,
      bio: bio ?? this.bio,
      serviceRadiusKm: serviceRadiusKm ?? this.serviceRadiusKm,
      nicPhotoPath: nicPhotoPath ?? this.nicPhotoPath,
    );
  }
}

