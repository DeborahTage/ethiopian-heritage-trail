import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/landmarks/landmarks_bloc.dart';
import '../../blocs/landmarks/landmarks_state.dart';
import '../../utils/app_colors.dart';

class LandmarkDetailScreen extends StatelessWidget {
  final String id;
  const LandmarkDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Heritage Site')),
      body: BlocBuilder<LandmarksBloc, LandmarksState>(
        builder: (context, state) {
          if (state is LandmarksLoaded) {
            final l = state.landmarks.firstWhere((p) => p.id == id);
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero image / map placeholder
                  Container(
                    height: 220, width: double.infinity,
                    color: AppColors.surface,
                    child: Stack(
                      children: [
                        Center(child: Icon(Icons.account_balance, size: 80, color: AppColors.primary.withOpacity(0.5))),
                        if (l.visited)
                          Positioned(top: 12, right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(20)),
                              child: const Row(children: [
                                Icon(Icons.check, color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text('Visited', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                              ]),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title + Amharic name
                        Text(l.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
                        if (l.nameAm != null)
                          Text(l.nameAm!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                        const SizedBox(height: 12),

                        // Region / category chips
                        Wrap(spacing: 8, children: [
                          if (l.region != null) _Chip(label: l.region!, icon: Icons.location_on),
                          _Chip(label: l.category, icon: Icons.category_outlined),
                        ]),
                        const SizedBox(height: 16),

                        // Points row
                        Row(children: [
                          const Icon(Icons.star, color: AppColors.gold, size: 20),
                          const SizedBox(width: 6),
                          Text('${l.pointsValue} points', style: const TextStyle(color: AppColors.accent, fontSize: 16, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          const Icon(Icons.radar, color: AppColors.textSecondary, size: 18),
                          const SizedBox(width: 4),
                          Text('${l.gpsRadiusMeters}m scan radius', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ]),
                        const Divider(color: AppColors.surface, height: 28),

                        // Description
                        if (l.description != null) ...[
                          const Text('About', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                          const SizedBox(height: 8),
                          Text(l.description!, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, height: 1.6)),
                        ],
                        const SizedBox(height: 24),

                        // Coordinates
                        Row(children: [
                          const Icon(Icons.my_location, color: AppColors.textSecondary, size: 16),
                          const SizedBox(width: 8),
                          Text('${l.latitude.toStringAsFixed(5)}, ${l.longitude.toStringAsFixed(5)}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: 'monospace')),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Chip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: AppColors.textSecondary),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
    ]),
  );
}
