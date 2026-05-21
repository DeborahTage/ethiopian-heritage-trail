import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../blocs/scanner/scanner_bloc.dart';
import '../../blocs/scanner/scanner_event.dart';
import '../../blocs/scanner/scanner_state.dart';
import '../../models/models.dart';
import '../../utils/app_colors.dart';
import 'scan_result_page.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    autoStart: false,
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.normal,
    formats: [BarcodeFormat.qrCode],
  );
  bool _bottomSheetOpen = false;
  bool _processingSheetOpen = false;

  @override
  void initState() {
    super.initState();
    context.read<ScannerBloc>().add(InitializeScanner());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || _bottomSheetOpen) return;

    final state = context.read<ScannerBloc>().state;
    if (state is ScannerReady) {
      HapticFeedback.vibrate();
      context.read<ScannerBloc>().add(QrCodeDetected(raw));
    }
  }

  void _showResultSheet(BuildContext context, Widget content) {
    if (_bottomSheetOpen) return;
    _bottomSheetOpen = true;
    _controller.stop();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => content,
    ).whenComplete(() {
      _bottomSheetOpen = false;
      _processingSheetOpen = false;
      context.read<ScannerBloc>().add(DismissResult());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: BlocConsumer<ScannerBloc, ScannerState>(
        listener: (context, state) {
          if (state is ScannerReady) {
            _controller.start();
          } else if (state is ScannerProcessing) {
            if (!_processingSheetOpen) {
              _processingSheetOpen = true;
              _showResultSheet(context, _buildProcessingBottomSheet(state.message));
            }
          } else if (state is ScannerSuccess) {
            Future.microtask(() {
              if (!mounted) return;
              if (_bottomSheetOpen && Navigator.of(context, rootNavigator: true).canPop()) {
                Navigator.of(context, rootNavigator: true).pop();
              }
              _processingSheetOpen = false;
              _bottomSheetOpen = false;
              _showResultSheet(context, _buildSuccessBottomSheet(state.response));
            });
          } else if (state is ScannerFailure) {
            Future.microtask(() {
              if (!mounted) return;
              if (_bottomSheetOpen && Navigator.of(context, rootNavigator: true).canPop()) {
                Navigator.of(context, rootNavigator: true).pop();
              }
              _processingSheetOpen = false;
              _bottomSheetOpen = false;
              _showResultSheet(context, _buildErrorBottomSheet(state.error));
            });
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              MobileScanner(
                controller: _controller,
                onDetect: _onDetect,
                fit: BoxFit.cover,
                errorBuilder: (context, error, child) {
                  return Container(
                    color: Colors.black87,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.camera_alt_outlined,
                          color: Colors.white,
                          size: 64,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Camera access is required.\n${error.errorDetails?.message ?? "Unknown error"}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                },
              ),
              // Overlay frame
              Center(
                child: Container(
                  width: 250, height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.secondary, width: 2.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              Positioned(
                bottom: 40, left: 0, right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                    child: const Text('Point at a heritage site QR code',
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                ),
              ),
              if (state is ScannerGpsDenied)
                Positioned(
                  top: 20, left: 20, right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(8)),
                    child: const Text('GPS permission is required for verification.', 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                  ),
                )
            ],
          );
        },
      ),
    );
  }

  Widget _buildProcessingBottomSheet(String message) => Container(
    padding: const EdgeInsets.all(24),
    height: 250,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(color: AppColors.secondary),
        const SizedBox(height: 20),
        Text(message, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
      ],
    ),
  );

  Widget _buildSuccessBottomSheet(ScanResponse r) => SizedBox(
    height: MediaQuery.of(context).size.height * 0.92,
    child: ScanResultPage(response: r, onClose: () => Navigator.of(context).pop()),
  );

  Widget _buildLegacySuccessBottomSheet(ScanResponse r) => Container(
    padding: const EdgeInsets.all(28),
    height: 450,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, color: AppColors.success, size: 80),
        const SizedBox(height: 20),
        const Text('Visit Recorded!', style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(r.landmarkName, style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
        const SizedBox(height: 28),
        // Points banner
        Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            const Text('Points Earned', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 4),
            Text('+${r.pointsEarned}', style: const TextStyle(color: AppColors.gold, fontSize: 40, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Total: ${r.totalPoints} pts', style: const TextStyle(color: AppColors.accent)),
            if (r.firstVisit) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.success.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: const Text('🎉 First Visit Bonus!', style: TextStyle(color: AppColors.success, fontSize: 12)),
              ),
            ],
          ]),
        ),
        if (r.rewardUnlocked != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gold, width: 1.5),
              color: AppColors.gold.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              const Icon(Icons.emoji_events, color: AppColors.gold, size: 28),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Reward Unlocked!', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600)),
                Text(r.rewardUnlocked!.name, style: const TextStyle(color: AppColors.textPrimary)),
              ])),
            ]),
          ),
        ],
      ],
    ),
  );

  Widget _buildErrorBottomSheet(String error) => Container(
    padding: const EdgeInsets.all(28),
    height: 350,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: AppColors.error, size: 72),
        const SizedBox(height: 20),
        const Text('Scan Failed', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(12)),
          child: Text(error, style: const TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.refresh),
          label: const Text('Try Again'),
        ),
      ],
    ),
  );
}
