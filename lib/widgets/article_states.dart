import 'package:flutter/material.dart';

class LoadingStateWidget extends StatelessWidget {
  final double screenWidth;
  final double progress;
  const LoadingStateWidget({
    super.key,
    required this.screenWidth,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/img/aposicon.png',
          width: 80,
          height: 80,
        ),
        const SizedBox(height: 3),
        const Text(
          'ಅಪೊಸ್ತಲಿಕ ಕ್ರೈಸ್ತತ್ವ',
          style: TextStyle(
            fontSize: 28,
            fontFamily: 'BalooTamma2ExtraBold',
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100.0),
          child: Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 1.0,
                  ),
                  color: Colors.white,
                ),
              ),
              Positioned(
                left: 0,
                child: Container(
                  height: 10,
                  width: screenWidth * 0.8 * progress,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class NoInternetWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetWidget({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'ಇಂಟರ್ನೆಟ್ ಸಂಪರ್ಕ ಲಭ್ಯವಿಲ್ಲ.\n'
              'ಇಂಟರ್ನೆಟ್ ಆನ್ ಮಾಡಿ ಮತ್ತು ಕೆಳಗಿರುವ ರಿಫ್ರೆಶ್ ಬಟನ್ ಒತ್ತಿ.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontFamily: 'BalooTamma2ExtraBold',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF148EB7),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'ರಿಫ್ರೆಶ್',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'BalooTamma2ExtraBold',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String errorMsg;

  const ErrorStateWidget({super.key, required this.errorMsg});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Error: $errorMsg',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.red),
        ),
      ),
    );
  }
}
