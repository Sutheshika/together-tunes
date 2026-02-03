import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool isSecondary;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isSecondary ? null : AppTheme.primaryGradient,
        color: isSecondary ? AppTheme.surfaceColor : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.buttonShadow,
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else if (icon != null)
              Icon(icon, size: 20),
            if ((isLoading || icon != null) && text.isNotEmpty)
              const SizedBox(width: 12),
            if (text.isNotEmpty)
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.3);
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
}

class AnimatedMusicIcon extends StatefulWidget {
  final bool isPlaying;
  final double size;

  const AnimatedMusicIcon({
    super.key,
    required this.isPlaying,
    this.size = 40,
  });

  @override
  State<AnimatedMusicIcon> createState() => _AnimatedMusicIconState();
}

class _AnimatedMusicIconState extends State<AnimatedMusicIcon>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedMusicIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            widget.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: widget.size * 0.6,
          ),
        );
      },
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppTheme.textSecondary)
                : null,
            suffixIcon: suffixIcon != null
                ? GestureDetector(
                    onTap: onSuffixTap,
                    child: Icon(suffixIcon, color: AppTheme.textSecondary),
                  )
                : null,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2);
  }
}

/// Reusable back button widget for all screens
class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed ?? () => Navigator.pop(context),
      icon: Icon(
        Icons.arrow_back_ios,
        color: color ?? AppTheme.textPrimary,
        size: size,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      tooltip: 'Go back',
    ).animate().fadeIn().slideX(begin: -0.2);
  }
}