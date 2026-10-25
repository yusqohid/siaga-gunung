import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang & Sumber Data'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App header
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.volcano_rounded,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Versi 1.0.0 • Proyek Kesiapsiagaan Akademik',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Data source details
          _buildInfoCard(
            title: 'Sumber Data Resmi',
            icon: Icons.source_rounded,
            content:
                'Data tingkat aktivitas dan laporan vulkanik diperoleh dari situs web resmi MAGMA Indonesia (Multiplatform Application for Geohazard Mitigation and Assessment in Indonesia) yang dikelola oleh Pusat Vulkanologi dan Mitigasi Bencana Geologi (PVMBG), Badan Geologi, Kementerian Energi dan Sumber Daya Mineral (ESDM).',
          ),

          const SizedBox(height: 12),

          // Technical architecture note
          _buildInfoCard(
            title: 'Arsitektur & Penanganan Data',
            icon: Icons.memory_rounded,
            content:
                '• Backend: Python FastAPI dengan adapter scraper terisolasi yang dipin ke snapshot commit stabil (d565a3c).\n'
                '• Cache Cerdas: Pembaruan berkala setiap 30 menit dengan ambang basi (stale) 2 jam.\n'
                '• Proteksi Anomali: Jika pembaruan data dari sumber mengalami penurunan jumlah entri >20% secara tidak wajar, data cache valid dipertahankan demi keandalan informasi.\n'
                '• On-Demand Detail: Halaman laporan detail diambil langsung secara individual saat dibuka oleh pengguna.',
          ),

          const SizedBox(height: 24),

          // Portal MAGMA button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _openUrl('https://magma.esdm.go.id'),
              icon: const Icon(Icons.public_rounded, size: 18),
              label: const Text('Kunjungi Portal Resmi MAGMA Indonesia'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.secondary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
