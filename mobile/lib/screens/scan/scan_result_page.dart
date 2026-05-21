import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/models.dart';
import '../../utils/app_colors.dart';

class ScanResultPage extends StatefulWidget {
  final ScanResponse response;
  final VoidCallback? onClose;

  const ScanResultPage({super.key, required this.response, this.onClose});

  @override
  State<ScanResultPage> createState() => _ScanResultPageState();
}

class _ScanResultPageState extends State<ScanResultPage> {
  bool _amharic = false;

  LandmarkContentModel? get content => widget.response.content;

  @override
  Widget build(BuildContext context) {
    final c = content;
    if (c == null) return _FallbackResult(response: widget.response, onClose: widget.onClose);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(c.landmarkName, overflow: TextOverflow.ellipsis),
          leading: IconButton(icon: const Icon(Icons.close), onPressed: widget.onClose ?? () => Navigator.of(context).pop()),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Story'),
              Tab(text: 'Gallery'),
              Tab(text: 'Video'),
              Tab(text: 'Audio'),
            ],
          ),
        ),
        body: Column(
          children: [
            if (c.media.heroImageUrl != null) _HeroImage(url: c.media.heroImageUrl!),
            _BadgeBanner(content: c),
            Expanded(
              child: TabBarView(
                children: [
                  _StoryTab(content: c, amharic: _amharic, onLanguageToggle: () => setState(() => _amharic = !_amharic)),
                  _GalleryTab(urls: c.media.galleryUrls),
                  _VideoTab(media: c.media),
                  _AudioTab(media: c.media),
                ],
              ),
            ),
            _BottomActions(content: c),
          ],
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  final String url;
  const _HeroImage({required this.url});

  @override
  Widget build(BuildContext context) => CachedNetworkImage(
        imageUrl: url,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(height: 200, color: AppColors.cardBg),
        errorWidget: (_, __, ___) => Container(
          height: 200,
          color: AppColors.cardBg,
          child: const Icon(Icons.image_not_supported, color: AppColors.textSecondary),
        ),
      );
}

class _BadgeBanner extends StatelessWidget {
  final LandmarkContentModel content;
  const _BadgeBanner({required this.content});

  Color get rarityColor => switch (content.badge.badgeRarity) {
        'legendary' => AppColors.gold,
        'epic' => Colors.purpleAccent,
        'rare' => AppColors.success,
        _ => AppColors.secondary,
      };

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        color: AppColors.cardBg,
        child: Row(
          children: [
            if (content.badge.badgeIconUrl != null)
              CachedNetworkImage(imageUrl: content.badge.badgeIconUrl!, width: 40, height: 40)
            else
              Icon(Icons.emoji_events, color: rarityColor, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(content.badge.badgeName ?? 'Heritage Badge',
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                Text('+${content.badge.badgePoints} points · ${content.badge.badgeRarity}',
                    style: TextStyle(color: rarityColor, fontSize: 12)),
              ]),
            ),
          ],
        ),
      );
}

class _StoryTab extends StatelessWidget {
  final LandmarkContentModel content;
  final bool amharic;
  final VoidCallback onLanguageToggle;
  const _StoryTab({required this.content, required this.amharic, required this.onLanguageToggle});

  @override
  Widget build(BuildContext context) {
    final story = content.story;
    final short = amharic ? (story.shortStoryAm ?? story.shortStoryEn) : (story.shortStoryEn ?? story.shortStoryAm);
    final full = amharic ? (story.fullHistoryAm ?? story.fullHistoryEn) : (story.fullHistoryEn ?? story.fullHistoryAm);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('EN')),
              ButtonSegment(value: true, label: Text('AM')),
            ],
            selected: {amharic},
            onSelectionChanged: (_) => onLanguageToggle(),
          ),
        ),
        const SizedBox(height: 12),
        Text(short ?? 'No story published yet.',
            style: const TextStyle(color: AppColors.textPrimary, height: 1.45, fontSize: 16, fontFamilyFallback: ['Noto Sans Ethiopic'])),
        if (full != null && full.isNotEmpty) ...[
          const SizedBox(height: 12),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Read full history', style: TextStyle(color: AppColors.secondary)),
            children: [
              Text(full, style: const TextStyle(color: AppColors.textSecondary, height: 1.5, fontFamilyFallback: ['Noto Sans Ethiopic'])),
            ],
          ),
        ],
        const SizedBox(height: 16),
        ...story.funFacts.map((fact) => ListTile(
              leading: const Icon(Icons.star, color: AppColors.gold),
              title: Text(fact, style: const TextStyle(color: AppColors.textPrimary)),
            )),
      ],
    );
  }
}

class _GalleryTab extends StatelessWidget {
  final List<String> urls;
  const _GalleryTab({required this.urls});

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) return const Center(child: Text('No gallery images yet', style: TextStyle(color: AppColors.textSecondary)));
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: urls.length,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => _FullscreenImage(url: urls[index]))),
        child: Hero(
          tag: urls[index],
          child: CachedNetworkImage(imageUrl: urls[index], fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class _FullscreenImage extends StatelessWidget {
  final String url;
  const _FullscreenImage({required this.url});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black),
        body: Center(
          child: Hero(
            tag: url,
            child: InteractiveViewer(child: CachedNetworkImage(imageUrl: url)),
          ),
        ),
      );
}

class _VideoTab extends StatefulWidget {
  final MediaContent media;
  const _VideoTab({required this.media});

  @override
  State<_VideoTab> createState() => _VideoTabState();
}

class _VideoTabState extends State<_VideoTab> {
  VideoPlayerController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    final url = widget.media.videoUrl;
    if (url == null) return;
    _controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await _controller!.initialize();
    await _controller!.play();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.media.videoUrl == null) return const Center(child: Text('No video available', style: TextStyle(color: AppColors.textSecondary)));
    if (_controller?.value.isInitialized == true) {
      return Column(children: [
        AspectRatio(aspectRatio: _controller!.value.aspectRatio, child: VideoPlayer(_controller!)),
        IconButton(icon: Icon(_controller!.value.isPlaying ? Icons.pause : Icons.play_arrow), onPressed: () {
          setState(() => _controller!.value.isPlaying ? _controller!.pause() : _controller!.play());
        }),
      ]);
    }
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.media.videoThumbnailUrl != null)
            CachedNetworkImage(imageUrl: widget.media.videoThumbnailUrl!, width: double.infinity, height: 220, fit: BoxFit.cover),
          IconButton(iconSize: 72, color: AppColors.secondary, icon: const Icon(Icons.play_circle_fill), onPressed: _play),
          Positioned(bottom: 16, child: Text('${widget.media.videoDuration ?? 0}s', style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}

class _AudioTab extends StatefulWidget {
  final MediaContent media;
  const _AudioTab({required this.media});

  @override
  State<_AudioTab> createState() => _AudioTabState();
}

class _AudioTabState extends State<_AudioTab> {
  final AudioPlayer _player = AudioPlayer();
  double _speed = 1;
  bool _playing = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.media.audioGuideUrl;
    if (url == null) return const Center(child: Text('No audio guide available', style: TextStyle(color: AppColors.textSecondary)));
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(
          iconSize: 72,
          color: AppColors.secondary,
          icon: Icon(_playing ? Icons.pause_circle : Icons.play_circle),
          onPressed: () async {
            if (_playing) {
              await _player.pause();
            } else {
              await _player.play(UrlSource(url));
            }
            setState(() => _playing = !_playing);
          },
        ),
        Text('${widget.media.audioDuration ?? 0}s', style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        SegmentedButton<double>(
          segments: const [
            ButtonSegment(value: 0.5, label: Text('0.5x')),
            ButtonSegment(value: 1, label: Text('1x')),
            ButtonSegment(value: 1.5, label: Text('1.5x')),
          ],
          selected: {_speed},
          onSelectionChanged: (value) {
            _speed = value.first;
            _player.setPlaybackRate(_speed);
            setState(() {});
          },
        ),
      ]),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final LandmarkContentModel content;
  const _BottomActions({required this.content});

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(12),
          color: AppColors.surface,
          child: Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.bookmark_add),
                label: const Text('Save to My Memories'),
                onPressed: () async {
                  await _saveContentAndMedia(content);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved for offline memories')));
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.share, color: AppColors.secondary),
              onPressed: () => Share.share('I unlocked ${content.badge.badgeName ?? content.landmarkName} on the Ethiopian Heritage Trail!'),
            ),
            IconButton(
              icon: const Icon(Icons.navigation, color: AppColors.secondary),
              onPressed: () => Share.share('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(content.landmarkName)}'),
            ),
          ]),
        ),
      );
}

Future<void> _saveContentAndMedia(LandmarkContentModel content) async {
  final visited = content.visitedNow();
  await Hive.box('landmark_contents').put(content.landmarkId, jsonEncode(visited.toJson()));
  final urls = [
    content.media.heroImageUrl,
    content.media.videoUrl,
    content.media.videoThumbnailUrl,
    content.media.audioGuideUrl,
    ...content.media.galleryUrls,
  ].whereType<String>();
  for (final url in urls) {
    await _downloadMedia(url);
  }
}

Future<void> _downloadMedia(String url) async {
  final box = Hive.box('media_cache');
  if (box.containsKey(url)) return;
  try {
    final dir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory('${dir.path}/media_cache');
    if (!await mediaDir.exists()) await mediaDir.create(recursive: true);
    final uri = Uri.parse(url);
    final path = '${mediaDir.path}/${DateTime.now().microsecondsSinceEpoch}_${uri.pathSegments.last}';
    await Dio().download(url, path);
    await box.put(url, path);
  } catch (_) {}
}

class _FallbackResult extends StatelessWidget {
  final ScanResponse response;
  final VoidCallback? onClose;
  const _FallbackResult({required this.response, this.onClose});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(leading: IconButton(icon: const Icon(Icons.close), onPressed: onClose ?? () => Navigator.of(context).pop())),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.check_circle, color: AppColors.success, size: 80),
              const SizedBox(height: 16),
              Text(response.landmarkName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('+${response.pointsEarned} points', style: const TextStyle(color: AppColors.gold, fontSize: 32, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              const Text('Content is unavailable right now.', style: TextStyle(color: AppColors.textSecondary)),
            ]),
          ),
        ),
      );
}
