import 'package:flutter_test/flutter_test.dart';
import 'package:kosku/features/payments/data/models/payment_model.dart';
import 'package:kosku/features/payments/data/models/payment_status.dart';

void main() {
  group('Payment.fromMap - proof_url mapping', () {
    test('proof_url non-null dipetakan ke proofUrl', () {
      final payment = Payment.fromMap({
        'id': 'abc-123',
        'user_id': 'user-1',
        'amount': 1700000,
        'period': '2026-09-01',
        'proof_url': 'proofs/abc-123/1788875295853.jpg',
        'status': 'menunggu',
      });

      expect(payment.proofUrl, 'proofs/abc-123/1788875295853.jpg');
      expect(payment.hasSubmittedPayment, isTrue);
      expect(payment.isWaitingConfirmation, isTrue);
    });

    test('proof_url NULL dipetakan ke proofUrl null', () {
      final payment = Payment.fromMap({
        'id': 'abc-124',
        'user_id': 'user-1',
        'amount': 1700000,
        'period': '2026-09-01',
        'proof_url': null,
        'status': 'menunggu',
      });

      expect(payment.proofUrl, isNull);
      expect(payment.hasSubmittedPayment, isFalse);
      expect(payment.isWaitingConfirmation, isFalse);
    });

    test('proof_url ada + status dikonfirmasi tetap punya bukti', () {
      final payment = Payment.fromMap({
        'id': 'abc-125',
        'user_id': 'user-1',
        'amount': 1700000,
        'period': '2026-08-01',
        'proof_url': 'proofs/abc-125/1788800000000.jpg',
        'status': 'dikonfirmasi',
      });

      expect(payment.proofUrl, isNotNull);
      expect(payment.proofUrl!.isEmpty, isFalse);
      expect(payment.isConfirmed, isTrue);
      expect(payment.isWaitingConfirmation, isFalse);
    });

    test('proof_url ada + status ditolak tetap punya bukti, boleh resubmit', () {
      final payment = Payment.fromMap({
        'id': 'abc-126',
        'user_id': 'user-1',
        'amount': 1700000,
        'period': '2026-08-01',
        'proof_url': 'proofs/abc-126/1788800000000.jpg',
        'status': 'ditolak',
      });

      expect(payment.proofUrl, isNotNull);
      expect(payment.proofUrl!.isEmpty, isFalse);
      expect(payment.isRejected, isTrue);
      expect(payment.hasSubmittedPayment, isTrue);
    });
  });

  group('resolvePaymentDisplayStatus', () {
    final futureDueDate = DateTime.now().add(const Duration(days: 30));

    final pastDueDate = DateTime.now().subtract(const Duration(days: 30));

    test('dikonfirmasi tampil Lunas meskipun jatuh tempo lewat', () {
      final display = resolvePaymentDisplayStatus(
        status: 'dikonfirmasi',
        hasProof: true,
        isCash: false,
        dueDate: pastDueDate,
      );

      expect(display, PaymentDisplayStatus.paid);
    });

    test('menunggu + ada bukti tampil Menunggu Konfirmasi', () {
      final display = resolvePaymentDisplayStatus(
        status: 'menunggu',
        hasProof: true,
        isCash: false,
        dueDate: pastDueDate,
      );

      expect(display, PaymentDisplayStatus.waitingConfirmation);
    });

    test('menunggu tunai tampil Menunggu Konfirmasi', () {
      final display = resolvePaymentDisplayStatus(
        status: 'menunggu',
        hasProof: false,
        isCash: true,
        dueDate: pastDueDate,
      );

      expect(display, PaymentDisplayStatus.waitingConfirmation);
    });

    test('menunggu tanpa bukti sebelum jatuh tempo tampil Belum Bayar', () {
      final display = resolvePaymentDisplayStatus(
        status: 'menunggu',
        hasProof: false,
        isCash: false,
        dueDate: futureDueDate,
      );

      expect(display, PaymentDisplayStatus.notPaid);
    });

    test('menunggu tanpa bukti setelah jatuh tempo tampil Telat Bayar', () {
      final display = resolvePaymentDisplayStatus(
        status: 'menunggu',
        hasProof: false,
        isCash: false,
        dueDate: pastDueDate,
      );

      expect(display, PaymentDisplayStatus.late);
    });

    test('ditolak tampil Ditolak', () {
      final display = resolvePaymentDisplayStatus(
        status: 'ditolak',
        hasProof: true,
        isCash: false,
        dueDate: pastDueDate,
      );

      expect(display, PaymentDisplayStatus.rejected);
    });
  });
}