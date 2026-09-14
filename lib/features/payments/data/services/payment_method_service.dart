import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/payment_method_model.dart';

class PaymentMethodService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final data = await _supabase
        .from('payment_info')
        .select()
        .order('updated_at', ascending: false);

    return data
        .map<PaymentMethodModel>((item) => PaymentMethodModel.fromMap(item))
        .toList();
  }

  Future<PaymentMethodModel> createBank({
    required String bankName,
    required String accountNumber,
    required String accountName,
  }) async {
    final data = await _supabase
        .from('payment_info')
        .insert({
          'type': 'bank',
          'bank_name': bankName,
          'account_number': accountNumber,
          'account_name': accountName,
        })
        .select()
        .single();

    return PaymentMethodModel.fromMap(data);
  }

  Future<PaymentMethodModel> createQris({required String qrisImageUrl}) async {
    final data = await _supabase
        .from('payment_info')
        .insert({'type': 'qris', 'qris_image_url': qrisImageUrl})
        .select()
        .single();

    return PaymentMethodModel.fromMap(data);
  }

  Future<String> uploadQris(File image) async {
    final extension = image.path.split('.').last.toLowerCase();

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';

    final filePath = 'qris/$fileName';

    await _supabase.storage
        .from('payment-images')
        .upload(filePath, image, fileOptions: const FileOptions(upsert: false));

    return filePath;
  }

  // =========================
  // UPDATE BANK
  // =========================

  Future<PaymentMethodModel> updateBank({
    required String id,
    required String bankName,
    required String accountNumber,
    required String accountName,
  }) async {
    final data = await _supabase
        .from('payment_info')
        .update({
          'type': 'bank',
          'bank_name': bankName,
          'account_number': accountNumber,
          'account_name': accountName,
          'qris_image_url': null,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id)
        .select()
        .single();

    return PaymentMethodModel.fromMap(data);
  }

  // =========================
  // UPDATE QRIS
  // =========================

  Future<PaymentMethodModel> updateQris({
    required String id,
    String? qrisImageUrl,
  }) async {
    final updateData = <String, dynamic>{
      'type': 'qris',
      'bank_name': null,
      'account_number': null,
      'account_name': null,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (qrisImageUrl != null && qrisImageUrl.isNotEmpty) {
      updateData['qris_image_url'] = qrisImageUrl;
    }

    final data = await _supabase
        .from('payment_info')
        .update(updateData)
        .eq('id', id)
        .select()
        .single();

    return PaymentMethodModel.fromMap(data);
  }

  // =========================
  // SIGNED URL QRIS
  // =========================

  Future<String?> getQrisSignedUrl(String? path) async {
    if (path == null || path.isEmpty) {
      return null;
    }

    try {
      final signedUrl = await _supabase.storage
          .from('payment-images')
          .createSignedUrl(path, 3600);

      return signedUrl;
    } catch (_) {
      return null;
    }
  }

  // =========================
  // DELETE
  // =========================

  Future<void> deletePaymentMethod(String id) async {
    await _supabase.from('payment_info').delete().eq('id', id);
  }

  // =========================
  // USER PAYMENT METHODS
  // =========================

  Future<List<Map<String, dynamic>>> getPaymentMethodsForUser() async {
    final data = await _supabase
        .from('payment_info')
        .select()
        .order('updated_at', ascending: false);

    final result = <Map<String, dynamic>>[];

    for (final item in data) {
      final payment = Map<String, dynamic>.from(item);

      if (payment['type'] == 'qris') {
        final path = payment['qris_image_url']?.toString();

        if (path != null && path.isNotEmpty) {
          payment['qris_image_url'] = await getQrisSignedUrl(path);
        }
      }

      result.add(payment);
    }

    return result;
  }
}
