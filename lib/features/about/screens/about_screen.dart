import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/ui_kit.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      appBar: AppBar(title: const Text('Tentang & Sumber Data')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: p.amb.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.volcano_rounded, size: 36, color: p.ink),
                ),
                const SizedBox(height: 12),
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: p.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Caption('Versi 1.0.0 · Proyek Kesiapsiagaan Akademik'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _InfoCard(
            title: 'Sumber Data Resmi',
            icon: Icons.source_rounded,
            content:
                'Data tingkat aktivitas dan laporan vulkanik diperoleh dari situs web resmi MAGMA Indonesia (Multiplatform Application for Geohazard Mitigation and Assessment in Indonesia) yang dikelola oleh Pusat Vulkanologi dan Mitigasi Bencana Geologi (PVMBG), Badan Geologi, Kementerian Energi dan Sumber Daya Mineral (ESDM).',
          ),
          const SizedBox(height: 12),
          _InfoCard(
            title: 'Arsitektur & Penanganan Data',
            icon: Icons.memory_rounded,
            content:
                '• Backend: Python FastAPI dengan adapter scraper terisolasi yang dipin ke snapshot commit stabil (d565a3c).\n'
                '• Cache Cerdas: Pembaruan berkala setiap 30 menit dengan ambang basi (stale) 2 jam.\n'
                '• Proteksi Anomali: Jika pembaruan data dari sumber mengalami penurunan jumlah entri >20% secara tidak wajar, data cache valid dipertahankan demi keandalan informasi.\n'
                '• On-Demand Detail: Halaman laporan detail diambil langsung secara individual saat dibuka oleh pengguna.',
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: () => _openUrl('https://magma.esdm.go.id'),
              icon: const Icon(Icons.public_rounded, size: 18),
              label: const Text('PORTAL RESMI MAGMA'),
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

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String content;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: p.ink),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: p.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(fontSize: 13, height: 1.5, color: p.mut),
          ),
        ],
      ),
    );
  }
}
