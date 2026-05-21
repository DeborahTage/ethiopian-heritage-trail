import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/landmarks/landmarks_bloc.dart';
import '../../blocs/landmarks/landmarks_state.dart';
import '../../models/models.dart';
import '../../utils/app_colors.dart';

class LandmarksScreen extends StatefulWidget {
  const LandmarksScreen({super.key});

  @override
  State<LandmarksScreen> createState() => _LandmarksScreenState();
}

class _LandmarksScreenState extends State<LandmarksScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LandmarksBloc>().add(LoadLandmarks());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heritage Sites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              context.go('/login');
            },
          ),
        ],
      ),
      body: BlocBuilder<LandmarksBloc, LandmarksState>(
        builder: (context, state) {
          if (state is LandmarksLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
          } else if (state is LandmarksError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, color: AppColors.textSecondary, size: 48),
                  const SizedBox(height: 12),
                  const Text('Could not load landmarks', style: TextStyle(color: AppColors.textSecondary)),
                  TextButton(
                    onPressed: () => context.read<LandmarksBloc>().add(LoadLandmarks()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is LandmarksLoaded) {
            final landmarks = state.landmarks;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: landmarks.length,
              itemBuilder: (ctx, i) => _LandmarkCard(landmark: landmarks[i]),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _LandmarkCard extends StatelessWidget {
  final LandmarkModel landmark;
  const _LandmarkCard({required this.landmark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/landmarks/${landmark.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: landmark.visited
              ? Border.all(color: AppColors.success.withOpacity(0.5), width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            // Category badge / image placeholder
            Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.3),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              ),
              child: Icon(Icons.account_balance,
                  color: landmark.visited ? AppColors.success : AppColors.secondary, size: 36),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(landmark.name,
                              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        if (landmark.visited)
                          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (landmark.region != null)
                      Text(landmark.region!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.gold, size: 14),
                        const SizedBox(width: 4),
                        Text('${landmark.pointsValue} pts',
                            style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 12),
                        const Icon(Icons.location_on, color: AppColors.textSecondary, size: 12),
                        const SizedBox(width: 2),
                        Text('${landmark.gpsRadiusMeters}m radius',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
