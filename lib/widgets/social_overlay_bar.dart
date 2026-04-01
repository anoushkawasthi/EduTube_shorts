import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// SocialOverlayBar displays Like and Share action buttons
class SocialOverlayBar extends StatefulWidget {
  final VoidCallback? onLike;
  final VoidCallback? onShare;
  final bool isLiked;

  const SocialOverlayBar({
    super.key,
    this.onLike,
    this.onShare,
    this.isLiked = false,
  });

  @override
  State<SocialOverlayBar> createState() => _SocialOverlayBarState();
}

class _SocialOverlayBarState extends State<SocialOverlayBar>
    with SingleTickerProviderStateMixin {
  late bool _isLiked;
  late AnimationController _likeAnimationController;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(SocialOverlayBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLiked != oldWidget.isLiked) {
      _isLiked = widget.isLiked;
    }
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _onLikeTap() {
    HapticFeedback.lightImpact();
    setState(() {
      _isLiked = !_isLiked;
    });
    // Pulse scale animation that returns to normal
    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
    });
    widget.onLike?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _onLikeTap,
          child: ScaleTransition(
            scale: Tween(begin: 1.0, end: 1.3).animate(
              CurvedAnimation(
                  parent: _likeAnimationController, curve: Curves.easeOut),
            ),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Icon(
                _isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: _isLiked ? Colors.redAccent : Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onShare?.call();
          },
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: const Icon(
              Icons.share_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}
