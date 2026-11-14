class CleanRow extends StatelessWidget {
  const CleanRow({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final DrColors colors = context.drColors;
    return Padding(
      padding: const EdgeInsets.all(DrSpace.s16),
      child: ColoredBox(
        color: colors.surfacePrimary,
        child: Text(label, style: context.drType.body3),
      ),
    );
  }
}
