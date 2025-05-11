class ReportFormData {
  // Step 1: Data Lokasi dan Deskripsi
  String? title;
  String? description;
  int? provinceId;
  int? cityId;
  String? address;
  String? imagePath;
  bool isAnonymous = false;

  // Step 2: Kategori dan Instansi
  int? categoryId;
  int? agencyId;

  // Step 3: Verifikasi
  bool isVerified = false;

  bool get isStep1Valid {
    return title != null &&
        description != null &&
        provinceId != null &&
        cityId != null &&
        address != null;
  }

  bool get isStep2Valid {
    return categoryId != null && agencyId != null;
  }

  bool get isStep3Valid {
    return isVerified;
  }

  Map<String, dynamic> toMap(int userId) {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'province_id': provinceId,
      'city_id': cityId,
      'address': address,
      'category_id': categoryId,
      'agency_id': agencyId,
      'image_path': imagePath,
      'is_anonymous': isAnonymous ? 1 : 0,
    };
  }
}
