import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class UserDashboardBanner extends StatefulWidget {
  const UserDashboardBanner({super.key});

  @override
  State<UserDashboardBanner> createState() => _UserDashboardBannerState();
}

class _UserDashboardBannerState extends State<UserDashboardBanner> {
  final PageController _pageController = PageController();

  Timer? _autoSlideTimer;

  int _currentPage = 0;

  final List<_BannerData> _banners = const [
    _BannerData(
      title: 'Tips Anak Kos',
      description:
          'Matikan perangkat elektronik saat tidak digunakan untuk membantu menghemat listrik.',
      titleColor: AppColors.secondary,
      descriptionColor: AppColors.onPrimary,
      imagePath: 'assets/images/avatar_junior-removebg-preview.png',
      textAlignment: TextAlign.left,
      imageAlignment: Alignment.bottomLeft,
      contentAlignment: Alignment.centerRight,
    ),
    _BannerData(
      title:
          'Sujudmu di tanah rantau adalah bukti pada orang tuamu bahwa mereka tidak gagal mendidikmu.',
      description: '',
      titleColor: Color(0xFF85FF67),
      descriptionColor: AppColors.onPrimary,
      imagePath: 'assets/images/avatar_santri.png',
      textAlignment: TextAlign.center,
      imageAlignment: Alignment.bottomLeft,
      contentAlignment: Alignment.centerRight,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_pageController.hasClients) {
        return;
      }

      final nextPage = (_currentPage + 1) % _banners.length;

      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _banners.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return _buildBanner(_banners[index]);
            },
          ),
        ),
        const SizedBox(height: 10),
        _buildIndicator(),
      ],
    );
  }

  Widget _buildBanner(_BannerData banner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.62, 0.90],
          colors: [Color(0xFF5283EF), Color(0xFF2F4B89)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: Image.asset(
              banner.imagePath,
              width: 115,
              height: 165,
              fit: BoxFit.contain,
              alignment: banner.imageAlignment,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox.shrink();
              },
            ),
          ),

          // Konten teks
          Padding(
            padding: EdgeInsets.only(left: 125, right: 20, top: 20, bottom: 20),
            child: Align(
              alignment: banner.contentAlignment,
              child: _buildContent(banner),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(_BannerData banner) {
    if (banner.description.isEmpty) {
      return Text(
        banner.title,
        textAlign: banner.textAlignment,
        style: AppTextStyles.headlineSmall.copyWith(
          color: banner.titleColor,
          fontWeight: FontWeight.w700,
          height: 1.35,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          banner.title,
          textAlign: banner.textAlignment,
          style: AppTextStyles.headlineMedium.copyWith(
            color: banner.titleColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          banner.description,
          textAlign: banner.textAlignment,
          style: AppTextStyles.bodyMedium.copyWith(
            color: banner.descriptionColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_banners.length, (index) {
        final isActive = index == _currentPage;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }
}

class _BannerData {
  final String title;
  final String description;
  final Color titleColor;
  final Color descriptionColor;
  final String imagePath;
  final TextAlign textAlignment;
  final Alignment imageAlignment;
  final Alignment contentAlignment;

  const _BannerData({
    required this.title,
    required this.description,
    required this.titleColor,
    required this.descriptionColor,
    required this.imagePath,
    required this.textAlignment,
    required this.imageAlignment,
    required this.contentAlignment,
  });
}
