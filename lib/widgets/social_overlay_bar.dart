import 'package:flutter/material.dart';
import 'package:edutube_shorts/theme/theme.dart';

/// SocialOverlayBar displays Like and Share action buttons on the right side
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
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _onLikeTap() {
    setState(() {
      _isLiked = !_isLiked;
    });
    if (_isLiked) {
      _likeAnimationController.forward();
    } else {
      _likeAnimationController.reverse();
    }
    widget.onLike?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Like button with animation
        GestureDetector(
          onTap: _onLikeTap,
          child: ScaleTransition(
            scale: Tween(
              begin: 1.0,
              end: 1.2,
            ).animate(_likeAnimationController),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                color: _isLiked ? AppColors.accent : Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Share button
        GestureDetector(
          onTap: widget.onShare,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.share_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}
