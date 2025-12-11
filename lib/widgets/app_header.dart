import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final bool isDrawerOpen;
  final VoidCallback onToggleDrawer;
  final VoidCallback onOpenSideDrawer;

  const AppHeader({
    super.key,
    required this.isDrawerOpen,
    required this.onToggleDrawer,
    required this.onOpenSideDrawer,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          'assets/img/aposicon.png',
          width: 39,
          height: 39,
        ),
        const Expanded(
          child: Text(
            'ಅಪೊಸ್ತಲಿಕ \nಕ್ರೈಸ್ತತ್ವ',
            textAlign: TextAlign.start,
            style: TextStyle(
              fontFamily: 'BalooTamma2ExtraBold',
              fontWeight: FontWeight.w800,
              fontSize: 16,
              height: 1.1,
              color: Colors.black,
            ),
          ),
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 9.0),
              child: SizedBox(
                width: 70.0,
                height: 33.0,
                child: ElevatedButton(
                  onPressed: onToggleDrawer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF148EB7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        '  ವಿಷಯ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: 'BalooTamma2ExtraBold',
                        ),
                      ),
                      Icon(
                        isDrawerOpen ? Icons.expand_less : Icons.expand_more,
                        size: 21.0,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: 40.0,
              height: 55.0,
              alignment: Alignment.center,
              child: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: onOpenSideDrawer,
                iconSize: 28.0,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
