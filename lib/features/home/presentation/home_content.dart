class HomeContent {
  const HomeContent({required this.headline, required this.description});

  static const starter = HomeContent(
    headline: 'Your reusable Flutter app foundation is ready.',
    description: 'Start building with reusable architecture, shared UI '
        'components, testing, and automated build workflows.',
  );

  final String headline;
  final String description;

  List<String> get displayLines {
    final trimmedHeadline = headline.trim();
    final trimmedDescription = description.trim();

    return [
      if (trimmedHeadline.isNotEmpty) trimmedHeadline,
      if (trimmedDescription.isNotEmpty) trimmedDescription,
    ];
  }

  bool get isComplete => displayLines.length == 2;
}
