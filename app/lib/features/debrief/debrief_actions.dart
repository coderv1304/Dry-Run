import 'package:flutter/material.dart';

import '../../design/components/dr_button.dart';
import '../../design/components/dr_icon.dart';
import '../../design/icons.g.dart';
import '../../design/dr_theme.dart';
import '../../design/space_tokens.g.dart';
import '../../l10n/app_localizations.dart';

class DebriefActions extends StatelessWidget {
  const DebriefActions({
    super.key,
    required this.l10n,
    required this.sharing,
    required this.deleting,
    required this.onShare,
    required this.onDelete,
  });

  final AppLocalizations l10n;
  final bool sharing;
  final bool deleting;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: DrSpace.s8,
      runSpacing: DrSpace.s8,
      children: <Widget>[
        DrButton(
          label: sharing ? l10n.debriefSharing : l10n.debriefShareButton,
          onPressed: sharing || deleting ? null : onShare,
          type: DrButtonType.primary,
          size: DrButtonSize.lg,
          elder: true,
          leadingIcon: DrIcon(
            data: DrIcons.usersThree,
            size: DrSize.iconMd,
            color: context.drColors.textOnAction,
          ),
        ),
        DrButton(
          label: deleting ? l10n.debriefDeleting : l10n.debriefDeleteButton,
          onPressed: sharing || deleting ? null : onDelete,
          type: DrButtonType.error,
          size: DrButtonSize.md,
        ),
      ],
    );
  }
}
