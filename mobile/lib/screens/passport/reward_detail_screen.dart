import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/models.dart';
import '../../utils/app_colors.dart';

class RewardDetailScreen extends StatefulWidget {
  final RewardModel reward;
  const RewardDetailScreen({super.key, required this.reward});

  @override
  State<RewardDetailScreen> createState() => _RewardDetailScreenState();
}

class _RewardDetailScreenState extends State<RewardDetailScreen> {
  late VideoPlayerController _videoController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    // Use a placeholder video for demonstration
    _videoController = VideoPlayerController.networkUrl(
        Uri.parse('https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'))
      ..initialize().then((_) {
        setState(() {});
      });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlayingAudio = state == PlayerState.playing);
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleAudio() async {
    if (_isPlayingAudio) {
      await _audioPlayer.pause();
    } else {
      // Mock audio
      await _audioPlayer.play(UrlSource('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reward;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reward Detail'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Video Player
            if (_videoController.value.isInitialized)
              AspectRatio(
                aspectRatio: _videoController.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    VideoPlayer(_videoController),
                    _ControlsOverlay(controller: _videoController),
                    VideoProgressIndicator(_videoController, allowScrubbing: true),
                  ],
                ),
              )
            else
              Container(height: 200, color: Colors.black26, child: const Center(child: CircularProgressIndicator())),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.emoji_events, color: AppColors.gold, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(r.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Audio Player Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Audio Guide', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                            Text('Listen to history', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ],
                        ),
                        IconButton(
                          icon: Icon(_isPlayingAudio ? Icons.pause_circle_filled : Icons.play_circle_fill,
                              color: AppColors.secondary, size: 48),
                          onPressed: _toggleAudio,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text('Discover', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  Text(r.description ?? 'This badge unlocks exclusive stories about this heritage site.',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;
  const _ControlsOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        controller.value.isPlaying ? controller.pause() : controller.play();
      },
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, VideoPlayerValue value, child) {
              if (!value.isPlaying) {
                return const Icon(Icons.play_arrow, color: Colors.white, size: 60);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
