import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../design/color_tokens.g.dart';
import '../../design/components/dr_button.dart';
import '../../design/components/dr_icon.dart';
import '../../design/icons.g.dart';
import '../../design/dr_theme.dart';
import '../../design/space_tokens.g.dart';
import '../../design/type_tokens.g.dart';
import '../../l10n/app_localizations.dart';

class InviteResult extends StatelessWidget {
  const InviteResult({
    super.key,
    required this.url,
    required this.expiresAt,
    required this.copiedLabel,
    required this.onCopy,
    required this.onShare,
  });

  final String url;
  final String? expiresAt;
  final String? copiedLabel;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final DrColors colors = context.drColors;
    final DrTypeTheme type = context.drType;
    final String expiry = _formatDate(l10n, expiresAt);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(l10n.inviteCreatedTitle, style: type.title3.copyWith(color: colors.textPrimary)),
        const SizedBox(height: DrSpace.s8),
        Container(
          padding: const EdgeInsets.all(DrSpace.s12),
          decoration: BoxDecoration(
            color: colors.surfacePrimary,
            borderRadius: BorderRadius.circular(DrRadius.r8),
            border: Border.all(color: colors.borderPrimary, width: DrSize.strokeHairline),
          ),
          child: Semantics(
            label: l10n.a11yInviteLink,
            child: SelectableText(
              url,
              style: type.body6.copyWith(color: colors.textPrimary),
            ),
          ),
        ),
        const SizedBox(height: DrSpace.s8),
        Text(
          l10n.inviteLinkHelper(expiry),
          style: type.caption2.copyWith(color: colors.textSecondary),
        ),
        const SizedBox(height: DrSpace.s16),
        Wrap(
          spacing: DrSpace.s8,
          runSpacing: DrSpace.s8,
          children: <Widget>[
            DrButton(
              label: l10n.copyInviteButton,
              onPressed: onCopy,
              type: DrButtonType.tertiary,
              size: DrButtonSize.md,
              leadingIcon: DrIcon(
                data: DrIcons.clipboardText,
                size: DrSize.iconSm,
                color: colors.textPrimary,
              ),
            ),
            DrButton(
              label: l10n.shareInviteButton,
              onPressed: onShare,
              type: DrButtonType.primary,
              size: DrButtonSize.md,
              leadingIcon: DrIcon(
                data: DrIcons.usersThree,
                size: DrSize.iconSm,
                color: colors.textOnAction,
              ),
            ),
          ],
        ),
        if (copiedLabel != null) ...<Widget>[
          const SizedBox(height: DrSpace.s8),
          Text(
            copiedLabel!,
            style: type.caption2.copyWith(color: colors.textTertiary),
          ),
        ],
      ],
    );
  }

  String _formatDate(AppLocalizations l10n, String? raw) {
    if (raw == null) {
      return '';
    }
    final DateTime? parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return raw;
    }
    return DateFormat.yMMMd(l10n.localeName).format(parsed.toLocal());
  }
}
