import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../blocs/passport/passport_bloc.dart';
import '../../blocs/passport/passport_state.dart';
import '../../models/models.dart';
import '../../utils/app_colors.dart';
import '../scan/scan_result_page.dart';
import 'dart:convert';

class PassportScreen extends StatefulWidget {
  const PassportScreen({super.key});

  @override
  State<PassportScreen> createState() => _PassportScreenState();
}

class _PassportScreenState extends State<PassportScreen> {
  final GlobalKey _globalKey = GlobalKey();
  String? _profileImagePath;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    context.read<PassportBloc>().add(LoadPassport());
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    try {
      final box = Hive.box('cached_rewards');
      final imagePath = box.get('profile_image_path');
      if (imagePath != null && File(imagePath as String).existsSync()) {
        setState(() => _profileImagePath = imagePath);
      }
    } catch (e) {
      debugPrint('Error loading profile image: $e');
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      final box = Hive.box('cached_rewards');
      await box.put('profile_image_path', pickedFile.path);

      if (mounted) {
        setState(() => _profileImagePath = pickedFile.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to select image: $e')),
        );
      }
    }
  }

  Future<void> _shareCollage() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/heritage_passport.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(file.path)], text: 'Check out my Ethiopian Heritage Trail Passport!');
    } catch (e) {
      debugPrint('Error generating collage: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Heritage Passport'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.secondary),
            onPressed: _shareCollage,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            onPressed: () => context.read<PassportBloc>().add(RefreshPassport()),
          ),
        ],
      ),
      body: BlocBuilder<PassportBloc, PassportState>(
        builder: (context, state) {
          if (state is PassportLoading) {
             return const Center(child: CircularProgressIndicator(color: AppColors.secondary));
          } else if (state is PassportError) {
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   const Icon(Icons.book_outlined, color: AppColors.textSecondary, size: 48),
                   const SizedBox(height: 12),
                   Text('Could not load passport: ${state.error}', style: const TextStyle(color: AppColors.textSecondary)),
                   TextButton(
                     onPressed: () => context.read<PassportBloc>().add(RefreshPassport()),
                     child: const Text('Retry')
                   ),
                 ],
               ),
             );
          } else if (state is PassportLoaded) {
             final passport = state.passport;
             return RepaintBoundary(
               key: _globalKey,
               child: Container(
                 color: AppColors.background,
                 child: SingleChildScrollView(
                   padding: const EdgeInsets.all(16),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       // Profile card with image picker
                       _ProfileCard(
                         passport: passport,
                         profileImagePath: _profileImagePath,
                         onTapProfilePicture: _pickProfileImage,
                       ),
                       const SizedBox(height: 16),
         
                       // Progress card
                       _ProgressCard(passport: passport),
                       const SizedBox(height: 24),
         
                       DefaultTabController(
                         length: 2,
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             const TabBar(tabs: [Tab(text: 'Badges'), Tab(text: 'My Memories')]),
                             SizedBox(
                               height: 360,
                               child: TabBarView(children: [
                                 passport.earnedRewards.isEmpty
                                     ? const Center(child: Text('No badges yet', style: TextStyle(color: AppColors.textSecondary)))
                                     : SingleChildScrollView(child: _RewardGrid(rewards: passport.earnedRewards)),
                                 const _MemoryGrid(),
                               ]),
                             ),
                           ],
                         ),
                       ),
                       const SizedBox(height: 24),
         
                       // Visited sites timeline
                       const _SectionHeader(title: 'Timeline'),
                       const SizedBox(height: 12),
                       if (passport.visitedLandmarks.isEmpty)
                         const Center(
                           child: Padding(
                             padding: EdgeInsets.all(20),
                             child: Text('No sites visited yet. Scan a QR code to start!',
                                 style: TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
                           ),
                         )
                       else
                         ...passport.visitedLandmarks.asMap().entries.map((entry) => _TimelineTile(landmark: entry.value, isLast: entry.key == passport.visitedLandmarks.length -1)),
                     ],
                   ),
                 ),
               ),
             );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final PassportModel passport;
  final String? profileImagePath;
  final VoidCallback onTapProfilePicture;

  const _ProfileCard({
    required this.passport,
    this.profileImagePath,
    required this.onTapProfilePicture,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.primary, AppColors.primary.withBlue(160)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        GestureDetector(
          onTap: onTapProfilePicture,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.secondary.withOpacity(0.2),
                backgroundImage: profileImagePath != null && File(profileImagePath!).existsSync()
                    ? FileImage(File(profileImagePath!))
                    : null,
                child: profileImagePath == null || !File(profileImagePath!).existsSync()
                    ? Text(
                        passport.displayName[0].toUpperCase(),
                        style: const TextStyle(color: AppColors.secondary, fontSize: 26, fontWeight: FontWeight.w700),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(passport.displayName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.star, color: AppColors.gold, size: 16),
              const SizedBox(width: 4),
              Text('${passport.totalPoints} points', style: const TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w600)),
            ]),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${passport.totalVisits}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.w800)),
          const Text('visits', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ]),
      ],
    ),
  );
}

class _ProgressCard extends StatelessWidget {
  final PassportModel passport;
  const _ProgressCard({required this.passport});

  @override
  Widget build(BuildContext context) {
    final pct = passport.totalLandmarks > 0 ? passport.completionPercent / 100 : 0.0;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Trail Completion', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
              Text('${passport.visitedLandmarks.length}/${passport.totalLandmarks} sites',
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppColors.surface,
              color: AppColors.success,
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text('${passport.completionPercent.toStringAsFixed(1)}% complete',
              style: const TextStyle(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Text(title,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700));
}

class _RewardGrid extends StatelessWidget {
  final List<RewardModel> rewards;
  const _RewardGrid({required this.rewards});

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85),
    itemCount: rewards.length,
    itemBuilder: (ctx, i) {
      final r = rewards[i];
      return GestureDetector(
        onTap: () => ctx.go('/reward/${r.name}', extra: r),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, color: AppColors.gold, size: 36),
              const SizedBox(height: 6),
              Text(r.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      );
    },
  );
}

class _MemoryGrid extends StatelessWidget {
  const _MemoryGrid();

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: Hive.box('landmark_contents').listenable(),
        builder: (context, box, _) {
          final memories = box.values
              .whereType<String>()
              .map((raw) => LandmarkContentModel.fromJson(jsonDecode(raw) as Map<String, dynamic>))
              .toList()
            ..sort((a, b) => (b.visitDate ?? '').compareTo(a.visitDate ?? ''));
          if (memories.isEmpty) {
            return const Center(child: Text('Saved scan memories appear here', style: TextStyle(color: AppColors.textSecondary)));
          }
          return GridView.builder(
            padding: const EdgeInsets.only(top: 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12),
            itemCount: memories.length,
            itemBuilder: (context, index) {
              final memory = memories[index];
              return GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ScanResultPage(
                    response: ScanResponse(
                      visitId: '',
                      landmarkId: memory.landmarkId,
                      landmarkName: memory.landmarkName,
                      pointsEarned: memory.badge.badgePoints,
                      totalPoints: 0,
                      distanceMeters: 0,
                      firstVisit: false,
                      savedToPassport: true,
                      content: memory,
                    ),
                  ),
                )),
                child: Container(
                  decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(12)),
                  clipBehavior: Clip.antiAlias,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      child: memory.media.heroImageUrl == null
                          ? const Center(child: Icon(Icons.image, color: AppColors.textSecondary))
                          : Image.network(memory.media.heroImageUrl!, width: double.infinity, fit: BoxFit.cover),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(memory.landmarkName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                    ),
                  ]),
                ),
              );
            },
          );
        },
      );
}

class _TimelineTile extends StatelessWidget {
  final LandmarkModel landmark;
  final bool isLast;
  const _TimelineTile({required this.landmark, required this.isLast});

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      children: [
        Column(
          children: [
            Container(width: 14, height: 14, decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle)),
            if (!isLast)
              Expanded(child: Container(width: 2, color: AppColors.secondary.withValues(alpha: 0.4))),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(landmark.name, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(landmark.category, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
