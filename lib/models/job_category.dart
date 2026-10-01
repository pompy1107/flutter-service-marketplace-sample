import 'package:cloud_firestore/cloud_firestore.dart';

class JobCategory {
  final String id;
  final String name;
  final String nameEn;
  final String slug;
  final String icon;
  final bool active;
  final int order;

  JobCategory({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.slug,
    required this.icon,
    required this.active,
    required this.order,
  });

  String localizedName(String languageCode) {
    if (languageCode.toLowerCase() == 'en' && nameEn.trim().isNotEmpty) {
      return nameEn;
    }
    return name;
  }

  factory JobCategory.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JobCategory(
      id: doc.id,
      name: (data['name'] ?? '').toString(),
      nameEn: (data['nameEn'] ?? '').toString(),
      slug: (data['slug'] ?? doc.id).toString(),
      icon: (data['icon'] ?? 'build').toString(),
      active: data['active'] ?? true,
      order: (data['order'] ?? 999).toInt(),
    );
  }
}
