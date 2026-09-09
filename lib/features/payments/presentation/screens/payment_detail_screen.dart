import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/payment_formatter.dart';
import '../../data/models/payment_method_model.dart';
import '../../data/models/payment_model.dart';
import '../../data/services/payment_method_service.dart';
import '../../data/services/payment_service.dart';
import '../widgets/payment_amount_section.dart';
import '../widgets/payment_bill_section.dart';
import '../widgets/payment_category_filter.dart';
import '../widgets/payment_confirmation_button.dart';
import '../widgets/payment_detail_header.dart';
import '../widgets/payment_method_section.dart';
import '../widgets/payment_proof_section.dart';
import '../widgets/payment_submit_status_card.dart';
import '../widgets/payment_type_selector.dart';

class PaymentDetailScreen extends StatefulWidget {
  final String paymentId;
  final Payment? initial;
  final bool isAdmin;

  const PaymentDetailScreen({
    super.key,
    required this.paymentId,
    this.initial,
    this.isAdmin = false,
  });

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  final _paymentService = PaymentService();
  final _paymentMethodService = PaymentMethodService();
  final _amountController = TextEditingController();

  Payment? _payment;
  List<PaymentMethodModel> _paymentMethods = [];
  PaymentMethodModel? _selectedPaymentMethod;
  String? _qrisSignedUrl;

  PaymentType _paymentType = PaymentType.full;
  PaymentCategory _selectedCategory = PaymentCategory.all;

  File? _proofImage;

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _payment = widget.initial;
    _loadDetail();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadDetail() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final payment = await _paymentService.getPaymentDetail(widget.paymentId);

      final methods = await _paymentMethodService.getPaymentMethods();

      String? qrisUrl;

      for (final method in methods) {
        if (method.isQris &&
            method.qrisImageUrl != null &&
            method.qrisImageUrl!.isNotEmpty) {
          qrisUrl = await _paymentMethodService.getQrisSignedUrl(
            method.qrisImageUrl,
          );
          break;
        }
      }

      if (!mounted) return;

      PaymentMethodModel? selectedMethod;

      if (payment?.paymentMethod != null) {
        for (final method in methods) {
          if (method.type == payment!.paymentMethod) {
            selectedMethod = method;
            break;
          }
        }
      }

      selectedMethod ??= methods.isNotEmpty ? methods.first : null;

      setState(() {
        _payment = payment;
        _paymentMethods = methods;
        _qrisSignedUrl = qrisUrl;
        _selectedPaymentMethod = selectedMethod;
        _isLoading = false;

        if (payment != null) {
          _amountController.text = payment.amount.toString();
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onPaymentTypeChanged(PaymentType type) {
    final payment = _payment;

    if (payment == null) return;

    setState(() {
      _paymentType = type;

      if (type == PaymentType.full) {
        _amountController.text = payment.amount.toString();
      } else {
        _amountController.clear();
      }
    });
  }

  void _onPaymentMethodChanged(PaymentMethodModel method) {
    setState(() {
      _selectedPaymentMethod = method;

      if (method.isCash) {
        _proofImage = null;
      }
    });
  }

  int? _getPaymentAmount() {
    final payment = _payment;

    if (payment == null) return null;

    if (_paymentType == PaymentType.full) {
      return payment.amount;
    }

    final raw = _amountController.text.trim();

    if (raw.isEmpty) {
      return null;
    }

    final amount = int.tryParse(raw);

    if (amount == null || amount <= 0) {
      return null;
    }

    if (amount > payment.amount) {
      return null;
    }

    return amount;
  }

  int? _getPreviewAmount(Payment payment) {
    if (_paymentType == PaymentType.full) {
      return payment.amount;
    }

    final raw = _amountController.text.trim();

    if (raw.isEmpty) {
      return null;
    }

    return int.tryParse(raw);
  }

  List<PaymentItem> _getFilteredItems(Payment payment) {
    return _selectedCategory.filterItems(payment.items);
  }

  Future<void> _confirmPayment() async {
    final payment = _payment;

    if (payment == null) return;

    final paymentId = payment.id;

    if (paymentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data tagihan tidak valid.')),
      );
      return;
    }

    final selectedMethod = _selectedPaymentMethod;

    if (selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih metode pembayaran terlebih dahulu.'),
        ),
      );
      return;
    }

    final amount = _getPaymentAmount();

    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal pembayaran tidak valid.')),
      );
      return;
    }

    if (amount > payment.amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nominal tidak boleh melebihi total tagihan.'),
        ),
      );
      return;
    }

    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final latest = await _paymentService.getPaymentDetail(paymentId);

      if (!mounted) return;

      if (latest == null) {
        throw Exception('Tagihan tidak ditemukan di database.');
      }

      if (latest.isWaitingConfirmation) {
        setState(() {
          _payment = latest;
          _proofImage = null;
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pembayaran sudah dikirim dan sedang '
              'menunggu konfirmasi.',
            ),
          ),
        );

        return;
      }

      if (latest.isConfirmed) {
        setState(() {
          _payment = latest;
          _proofImage = null;
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pembayaran sudah dikonfirmasi oleh admin.'),
          ),
        );

        return;
      }

      if (selectedMethod.isCash) {
        await _paymentService.submitCashPayment(paymentId: paymentId);
      } else {
        if (_proofImage == null) {
          setState(() {
            _isSubmitting = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Upload bukti pembayaran terlebih dahulu.'),
            ),
          );

          return;
        }

        final proofPath = await _paymentService.uploadPaymentProof(
          paymentId: paymentId,
          file: _proofImage!,
        );

        await _paymentService.submitPaymentProof(
          paymentId: paymentId,
          proofUrl: proofPath,
          paymentMethod: selectedMethod.type,
        );
      }

      final updated = await _paymentService.getPaymentDetail(paymentId);

      if (!mounted) return;

      setState(() {
        _payment = updated;
        _proofImage = null;
        _isSubmitting = false;
      });

      if (selectedMethod.isCash) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pembayaran tunai ${PaymentFormatter.rupiah(amount)} '
              'berhasil dikirim dan menunggu konfirmasi.',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pembayaran ${PaymentFormatter.rupiah(amount)} '
              'berhasil dikirim dan menunggu konfirmasi.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memproses pembayaran: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Detail Tagihan')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _buildError(_error!);
    }

    final payment = _payment;

    if (payment == null) {
      return _buildError('Tagihan tidak ditemukan.');
    }

    final currentAmount = _getPreviewAmount(payment);

    final isWaiting = payment.isWaitingConfirmation;

    final isRejected = payment.isRejected;
    final isConfirmed = payment.isConfirmed;

    final canSubmit = !isWaiting && !isConfirmed;

    final isCash = _selectedPaymentMethod?.isCash ?? false;

    return RefreshIndicator(
      onRefresh: _loadDetail,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          PaymentDetailHeader(payment: payment, isAdmin: widget.isAdmin),
          if (isWaiting) ...[
            const SizedBox(height: 20),
            const PaymentSubmitStatusCard(status: PaymentSubmitStatus.waiting),
          ] else if (isRejected) ...[
            const SizedBox(height: 20),
            const PaymentSubmitStatusCard(status: PaymentSubmitStatus.rejected),
          ] else if (isConfirmed) ...[
            const SizedBox(height: 20),
            const PaymentSubmitStatusCard(
              status: PaymentSubmitStatus.confirmed,
            ),
          ],
          const SizedBox(height: 20),
          PaymentBillSection(
            payment: payment,
            items: _getFilteredItems(payment),
          ),
          const SizedBox(height: 20),
          PaymentCategoryFilter(
            selectedCategory: _selectedCategory,
            onCategoryChanged: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
          ),
          const SizedBox(height: 24),
          PaymentMethodSection(
            methods: _paymentMethods,
            selectedMethod: _selectedPaymentMethod,
            qrisSignedUrl: _qrisSignedUrl,
            onChanged: _onPaymentMethodChanged,
          ),
          if (canSubmit) ...[
            const SizedBox(height: 24),
            PaymentTypeSelector(
              selectedType: _paymentType,
              onChanged: _onPaymentTypeChanged,
            ),
            const SizedBox(height: 20),
            PaymentAmountSection(
              paymentType: _paymentType,
              totalAmount: payment.amount,
              controller: _amountController,
            ),
            if (_paymentType == PaymentType.installment &&
                _amountController.text.isNotEmpty &&
                currentAmount != null &&
                currentAmount < payment.amount) ...[
              const SizedBox(height: 8),
              Text(
                'Sisa tagihan: '
                '${PaymentFormatter.rupiah(payment.amount - currentAmount)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (!isCash) ...[
              const SizedBox(height: 24),
              PaymentProofSection(
                proofImage: _proofImage,
                onImagePicked: (file) {
                  setState(() {
                    _proofImage = file;
                  });
                },
                onImageRemoved: () {
                  setState(() {
                    _proofImage = null;
                  });
                },
              ),
            ],
            const SizedBox(height: 24),
            PaymentConfirmationButton(
              isLoading: _isSubmitting,
              label: isRejected
                  ? 'Kirim Ulang Pembayaran'
                  : isCash
                  ? 'Konfirmasi Pembayaran Tunai'
                  : 'Konfirmasi Pembayaran',
              onPressed: _confirmPayment,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(
              'Gagal Memuat Detail Tagihan',
              style: AppTextStyles.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDetail,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
