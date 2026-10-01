import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_category.dart';

class JobCategoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Stream<List<JobCategory>> getActiveCategories() => _db.collection('job_categories').where('active', isEqualTo: true).orderBy('order').snapshots().map((s) => s.docs.map((d) => JobCategory.fromDoc(d)).toList());
  Future<void> requestNewCategory({required String name, required String userId, String? userEmail}) async {
    final clean = name.trim();
    if (clean.isEmpty) throw Exception('category-name-empty');
    await _db.collection('job_categories_pending').add({'name': clean,'createdBy': userId,'createdByEmail': userEmail,'status': 'pending','createdAt': FieldValue.serverTimestamp()});
  }
}
