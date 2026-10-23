/// Motivational quote model for daily inspiration.
class QuoteModel {
  final String quote;
  final String author;

  const QuoteModel({required this.quote, required this.author});

  static const List<QuoteModel> quotes = [
    QuoteModel(
      quote: "Action is the foundational key to all success.",
      author: "Pablo Picasso",
    ),
    QuoteModel(
      quote: "It always seems impossible until it's done.",
      author: "Nelson Mandela",
    ),
    QuoteModel(
      quote: "Focus on being productive instead of busy.",
      author: "Tim Ferriss",
    ),
    QuoteModel(
      quote: "The secret of getting ahead is getting started.",
      author: "Mark Twain",
    ),
    QuoteModel(
      quote: "Small daily improvements over time lead to stunning results.",
      author: "Robin Sharma",
    ),
    QuoteModel(
      quote: "Your future is created by what you do today, not tomorrow.",
      author: "Robert Kiyosaki",
    ),
  ];
}
