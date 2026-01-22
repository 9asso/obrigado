class GameCard {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String gameUrl;
  final String level;

  GameCard({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.gameUrl,
    this.level = 'V1',
  });
}

// Sample game data
final List<GameCard> sampleGames = [
  GameCard(
    id: '1',
    title: 'Math Adventure',
    subtitle: 'Learn numbers and counting',
    imageUrl: 'https://i.ytimg.com/vi/jwNm_H07bzs/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLDoQfTdHxYJJq6WVqI-q27IAd0t5A',
    gameUrl: 'https://www.mathplayground.com/ASB_Index.html',
    level: 'V2',
  ),
  GameCard(
    id: '2',
    title: 'Puzzle Game',
    subtitle: 'Train observation skills',
    imageUrl: 'https://sprunky.net/other-games/incredibox-sprunkstard.webp',
    gameUrl: 'https://www.crazygames.com/game/jigsaw-puzzles',
    level: 'V1',
  ),
  GameCard(
    id: '3',
    title: 'Memory Match',
    subtitle: 'Improve memory',
    imageUrl: 'assets/images/memory_game.png',
    gameUrl: 'https://www.memozor.com/memory-games/for-kids/animals',
    level: 'V3',
  ),
  GameCard(
    id: '4',
    title: 'Coloring Fun',
    subtitle: 'Unleash creativity',
    imageUrl: 'assets/images/coloring_game.png',
    gameUrl: 'https://www.thecolor.com/',
    level: 'V1',
  ),
  GameCard(
    id: '5',
    title: 'ABC Learning',
    subtitle: 'Learn the alphabet',
    imageUrl: 'assets/images/abc_game.png',
    gameUrl: 'https://www.abcya.com/games/alphabet_learning_games',
    level: 'V2',
  ),
];
