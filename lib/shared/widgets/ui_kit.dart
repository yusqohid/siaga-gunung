import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../features/volcano/data/models/volcano_model.dart';
import 'level_style.dart';

/// Roman-numeral level marker used across lists, headers and map pins.
class LevelMark extends StatelessWidget {
  final ActivityLevel level;
  final double size;
  final bool solid;

  const LevelMark({
    super.key,
    required this.level,
    this.size = 36,
    this.solid = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bg = solid ? level.color : level.tintBackground(p);
    final fg = solid
        ? (level == ActivityLevel.levelII ? p.ink : Colors.white)
        : level.tintForeground(p);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.32),
        border: solid
            ? null
            : Border.all(color: level.tintBorder(p), width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        level.code,
        style: TextStyle(
          color: fg,
          fontSize: size * 0.40,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );
  }
}

/// Rounded selectable chip (region / level / category filters).
class PillChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const PillChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: selected ? p.amb : p.card,
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              height: 1,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? AppColors.inkOnAmber : p.ink,
            ),
          ),
        ),
      ),
    );
  }
}

/// Large light eyebrow + bold title used at the top of every main screen.
class ScreenHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final Widget? trailing;

  /// When true the eyebrow gets the full width and the trailing actions sit on
  /// the title row. Prevents the title/eyebrow from being squeezed when there
  /// are several action buttons.
  final bool trailingOnTitleRow;
  final double eyebrowSize;
  final double titleSize;

  const ScreenHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.trailing,
    this.trailingOnTitleRow = false,
    this.eyebrowSize = 30,
    this.titleSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    final eyebrowWidget = FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        eyebrow,
        maxLines: 1,
        style: TextStyle(
          fontSize: eyebrowSize,
          fontWeight: FontWeight.w300,
          height: 1.1,
          color: p.mut,
        ),
      ),
    );

    final titleStyle = TextStyle(
      fontSize: titleSize,
      fontWeight: FontWeight.w600,
      height: 1.1,
      letterSpacing: -0.3,
      color: p.ink,
    );

    if (trailing != null && trailingOnTitleRow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          eyebrowWidget,
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(title, maxLines: 1, style: titleStyle),
                ),
              ),
              const SizedBox(width: 10),
              trailing!,
            ],
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              eyebrowWidget,
              Text(title, style: titleStyle),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 10),
          trailing!,
        ],
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;

  const SectionTitle(
    this.text, {
    super.key,
    this.padding = const EdgeInsets.only(top: 26, bottom: 12),
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: padding,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: p.ink,
        ),
      ),
    );
  }
}

/// Small uppercase caption.
class Caption extends StatelessWidget {
  final String text;
  final Color? color;
  final double fontSize;

  const Caption(
    this.text, {
    super.key,
    this.color,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        letterSpacing: 0.1 * fontSize,
        fontWeight: FontWeight.w500,
        color: color ?? p.mut,
      ),
    );
  }
}

class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool accent;
  final String? tooltip;
  final double size;

  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.accent = false,
    this.tooltip,
    this.size = 46,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bg = accent ? p.amb : p.card;
    final fg = accent ? AppColors.inkOnAmber : p.ink;

    final button = Material(
      color: bg,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: size * 0.5, color: fg),
        ),
      ),
    );

    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// A plain rounded surface card matching the prototype's `.card`.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadius? radius;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.color,
    this.radius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final borderRadius = radius ?? BorderRadius.circular(24);
    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? p.card,
        borderRadius: borderRadius,
      ),
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: content,
        ),
      );
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return content;
  }
}
