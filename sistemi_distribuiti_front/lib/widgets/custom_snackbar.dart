import 'package:flutter/material.dart';

enum SnackbarType { info, success, warning, error }

class CustomSnackbar extends StatefulWidget {
  final String message;
  final SnackbarType type;
  final Duration duration;
  final VoidCallback? onClose;

  const CustomSnackbar({
    Key? key,
    required this.message,
    this.type = SnackbarType.info,
    this.duration = const Duration(seconds: 4),
    this.onClose,
  }) : super(key: key);

  @override
  State<CustomSnackbar> createState() => _CustomSnackbarState();

  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (ctx) => CustomSnackbar(
        message: message,
        type: type,
        duration: duration,
        onClose: () => overlayEntry.remove(),
      ),
    );
    overlay.insert(overlayEntry);
  }
}

class _CustomSnackbarState extends State<CustomSnackbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (widget.onClose != null) widget.onClose!();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getIcon() {
    switch (widget.type) {
      case SnackbarType.success:
        return Icons.check_circle_outline;
      case SnackbarType.warning:
        return Icons.warning_amber_rounded;
      case SnackbarType.error:
        return Icons.error_outline;
      case SnackbarType.info:
      default:
        return Icons.info_outline;
    }
  }

  Color _getIconColor() {
    switch (widget.type) {
      case SnackbarType.success:
        return Colors.greenAccent;
      case SnackbarType.warning:
        return Colors.amberAccent;
      case SnackbarType.error:
        return Colors.redAccent;
      case SnackbarType.info:
      default:
        return Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24,
      right: 24,
      bottom: 24,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xE6323232), // rgba(50,50,50,0.9)
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getIcon(), color: _getIconColor(), size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _controller.reverse().then((_) {
                        if (widget.onClose != null) widget.onClose!();
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.close, color: Colors.white70, size: 22),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
