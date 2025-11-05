// CS Data Structures & Algorithms Homework
// Boggle Word Finder using Trie data structure

import 'dart:io';
import 'dart:convert';

class TrieNode {
  final Map<String, TrieNode> children = {};
  bool isEndOfWord = false;
}

class Trie {
  TrieNode root = TrieNode();

  void insert(String word) {
    TrieNode currentNode = root;
    for (int i = 0; i < word.length; i++) {
      final letter = word[i];
      if (!currentNode.children.containsKey(letter)) {
        currentNode.children[letter] = TrieNode();
      }
      currentNode = currentNode.children[letter]!;
    }
    currentNode.isEndOfWord = true;
  }

  bool search(String word) {
    TrieNode currentNode = root;
    for (int i = 0; i < word.length; i++) {
      final letter = word[i];
      if (!currentNode.children.containsKey(letter)) {
        return false;
      }
      currentNode = currentNode.children[letter]!;
    }
    return currentNode.isEndOfWord;
  }

  // Check if a prefix exists in the trie
  // this is important for optimization | we can stop searching
  // if the current path ca't lead to any valid words
  bool isPrefix(String prefix) {
    TrieNode currentNode = root;
    for (int i = 0; i < prefix.length; i++) {
      final letter = prefix[i];
      if (!currentNode.children.containsKey(letter)) {
        return false;
      }
      currentNode = currentNode.children[letter]!;
    }
    return true; // The prefix exists in the trie
  }
}

void main() {
  print('\x1b[38;5;123m=== Boggle Word Finder ===\n\x1b[0m');
  
  // Step 1: Load the German word list and build the trie
  print('\x1b[38;5;39mLoading German word list...\x1b[0m');
  Trie trie = loadGermanWords();
  print('\x1b[38;5;219mWord list loaded!\x1b[0m\n');
  
  // Step 2: Load the grid from JSON file
  print('\x1b[38;5;39mLoading grid from boggle_grid.json...\x1b[0m');
  List<List<String>> grid = loadGridFromJson('boggle_grid.json');
  print('\x1b[38;5;120mGrid loaded!\x1b[0m\n');
  
  // Print the grid
  print('Grid:');
  printGrid(grid);
  print('');
  
  // Step 3: Find all words in the grid
  print('Searching for words...\x1b[0m\n');
  Map<String, List<String>> foundWords = findAllWords(grid, trie);
  
  // Step 4: Display results
  displayResults(foundWords);
}

// Load German words from file and build trie
Trie loadGermanWords() {
  Trie trie = Trie();
  
  // Try to load from german_words.txt
  File file = File('german_words_1.9m.txt');
  
  if (!file.existsSync()) {
    print('\x1b[38;5;202mWarning: german_words.txt not found!\x1b[0m`');
    print('\x1b[38;5;39mCreating sample word list...\x1b[0m\n');
    createSampleGermanWords();
    file = File('german_words.txt');
  }
  
  // Read file and insert words into trie
  List<String> lines = file.readAsLinesSync();
  int wordCount = 0;
  
  for (String line in lines) {
    String word = line.trim().toUpperCase();
    // Only use words that are 3+ letters
    if (word.length >= 3 && word.isNotEmpty) {
      trie.insert(word);
      wordCount++;
    }
  }
  
  print('\x1b[38;5;120mLoaded $wordCount German words into trie\x1b[0m');
  
  return trie;
}

// Load grid from JSON file
List<List<String>> loadGridFromJson(String filename) {
  File file = File(filename);
  
  if (!file.existsSync()) {
    print('\x1b[38;5;196mError: $filename not found!\x1b[0m');
    print('\x1b[38;5;202mPlease run grid_generator.dart first!\x1b[0m');
    exit(1);
  }
  
  String jsonString = file.readAsStringSync();
  Map<String, dynamic> data = json.decode(jsonString);
  
  List<String> gridStrings = List<String>.from(data['grid']);
  
  // Convert to 2D list of characters
  List<List<String>> grid = [];
  for (String row in gridStrings) {
    grid.add(row.toUpperCase().split(''));
  }
  
  return grid;
}

// Print the grid nicely
void printGrid(List<List<String>> grid) {
  for (List<String> row in grid) {
    print(row.join(' '));
  }
}

// Main algorithm: Find all words in the grid
Map<String, List<String>> findAllWords(List<List<String>> grid, Trie trie) {
  Map<String, List<String>> foundWords = {};
  int rows = grid.length;
  int cols = grid[0].length;

  for (int row = 0; row < rows; row++) {
    for (int col = 0; col < cols; col++) {
      Set<String> visited = {};
      searchFromPosition(grid, row, col, '', visited, trie, foundWords, []);
    }
  }

  return foundWords;
}

// Recursive function to search for words starting from a position
// This uses depth-first search (DFS) algorithm
void searchFromPosition(
  List<List<String>> grid,
  int row,
  int col,
  String currentWord,
  Set<String> visited,
  Trie trie,
  Map<String, List<String>> foundWords,
  List<String> path,
) {
  // Check if position is valid
  int rows = grid.length;
  int cols = grid[0].length;
  
  if (row < 0 || row >= rows || col < 0 || col >= cols) {
    return; // Out of bounds
  }
  
  // Check if we've already visited this cell in current path
  String posKey = '$row,$col';
  if (visited.contains(posKey)) {
    return; // Already visited
  }
  
  // Add current letter to word
  String newWord = currentWord + grid[row][col];
  
  // Optimization: Check if this prefix exists in dictionary
  // If not, no point continuing this path
  if (!trie.isPrefix(newWord)) {
    return;
  }
  
  // Mark as visited
  visited.add(posKey);
  path.add(posKey);
  
  // Check if current word is valid (3+ letters and exists in dictionary)
  if (newWord.length >= 3 && trie.search(newWord)) {
    foundWords.putIfAbsent(newWord, () => List.from(path));
  }
  
  // Try all 8 neighboring positions (up, down, left, right, and diagonals)
  for (int dRow = -1; dRow <= 1; dRow++) {
    for (int dCol = -1; dCol <= 1; dCol++) {
      if (dRow == 0 && dCol == 0) continue; // Skip current position
      // Recursively search from neighbor
      searchFromPosition(
        grid, 
        row + dRow, 
        col + dCol, 
        newWord, 
        visited, 
        trie, 
        foundWords,
        path,
        );
    }
  }
  
  // Backtrack - unmark as visited so other paths can use this cell
  visited.remove(posKey);
  path.removeLast();
}

// Display the results
void displayResults(Map<String, List<String>> words) {
  if (words.isEmpty) {
    print('\x1b[38;5;202mNo words found\x1b[0m');
    return;
  }
  
  // Sort words by length (longest first), then alphabetically
  List<String> sortedWords = words.keys.toList();
  sortedWords.sort((a, b) {
    if (a.length != b.length) {
      return b.length.compareTo(a.length); // Longer words first
    }
    return a.compareTo(b); // Alphabetically
  });
  
  print('\x1b[38;5;120mFound ${words.length} words:\x1b[0m\n');
  
  // Group by length
  int currentLength = 0;
  for (String word in sortedWords) {
    if (word.length != currentLength) {
      currentLength = word.length;
      print('\x1b[38;5;225m\n--- $currentLength-letter words ---\x1b[0m');
    }
    print(word);
  }
  
  print('\n');
  print('\x1b[38;5;225mTotal: ${words.length} words found\x1b[0m');

  saveResultsToFiles(words);
}

void saveResultsToFiles(Map<String, List<String>> foundWords) {
  try {
    // Save to plain text file
    final txtFile = File('boggle_found_words.txt');
    final buffer = StringBuffer();

    buffer.writeln('Found words: (${foundWords.length})\n');

    // Group words by their length for JSON output
    final Map<int, List<String>> grouped = {};
    for (final word in foundWords.keys) {
      grouped.putIfAbsent(word.length, () => []).add(word);
    }

    final sortedLengths = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    for (final len in sortedLengths) {
      buffer.writeln('\n${len} Letters ${'=' * (50 - len.toString().length - 8)}');
      for (final word in grouped[len]!..sort()) {
        final coords = foundWords[word]!.join('>');
        buffer.writeln('$word ($coords)');
      }
    }

    txtFile.writeAsStringSync(buffer.toString());
    print('\x1b[38;5;123mSaved results to boggle_found_words.txt\x1b[0m');

    // Also save JSON
    final jsonFile = File('boggle_found_words.json');
    jsonFile.writeAsStringSync(JsonEncoder.withIndent('  ').convert({
      'total_words': foundWords.length,
      'words': foundWords,
    }));
    print('\x1b[38;5;123mSaved results to boggle_found_words.json\x1b[0m\n');
  } catch (e) {
    print('\x1b[38;5;196mError saving results: $e\x1b[0m');
  }
}

// Create a sample German word list if file doesn't exist
void createSampleGermanWords() {
  // Sample of common German words for testing
  List<String> sampleWords = [
    'ABER', 'ALLE', 'ALSO', 'ALTE', 'ANDER', 'ANDERE', 'ARBEIT',
    'AUS', 'AUCH', 'BALD', 'BEI', 'BEIDE', 'BEIM', 'BERG', 'BETT',
    'BIN', 'BIS', 'BITTE', 'BUCH', 'DAME', 'DANN', 'DAS', 'DASS',
    'DEIN', 'DEM', 'DEN', 'DER', 'DIESE', 'DIR', 'DOCH', 'DREI',
    'EIN', 'EINE', 'EINS', 'ENDE', 'ERST', 'ESSEN', 'EUCH', 'EUER',
    'FAHR', 'FALL', 'FEST', 'FINDEN', 'FRAGE', 'FRAU', 'FREI', 'FREUND',
    'GANZ', 'GEBEN', 'GEGEN', 'GEHEN', 'GELD', 'GENUG', 'GERN', 'GUT',
    'HABEN', 'HALB', 'HALT', 'HAND', 'HAUS', 'HEUTE', 'HIER', 'HOCH',
    'ICH', 'IHNEN', 'IHRE', 'IMMER', 'JAHR', 'JETZT', 'JUNG', 'KEIN',
    'KEINE', 'KIND', 'KLEIN', 'KOMMEN', 'KURZ', 'LADEN', 'LAND', 'LANG',
    'LASSEN', 'LEBEN', 'LEER', 'LESEN', 'LETZT', 'LEUTE', 'LIEBE', 'LIEGEN',
    'MACHEN', 'MANN', 'MEHR', 'MEIN', 'MEINE', 'MENSCH', 'MICH', 'MIT',
    'NACH', 'NACHT', 'NEIN', 'NEUE', 'NICHT', 'NOCH', 'NUN', 'NUR',
    'OBEN', 'ODER', 'OHNE', 'ORT', 'SAGEN', 'SEHEN', 'SEHR', 'SEIN',
    'SEINE', 'SEIT', 'SELBST', 'SICH', 'SIND', 'SOLL', 'STADT', 'STARK',
    'STEHEN', 'TAG', 'TEIL', 'TIEF', 'TUN', 'TURM', 'UBER', 'UNSER',
    'UNTER', 'VIEL', 'VIER', 'VOLL', 'VON', 'VOR', 'WAHR', 'WANN',
    'WARM', 'WARTEN', 'WARUM', 'WAS', 'WASSER', 'WEIL', 'WEIT', 'WEITER',
    'WELCHE', 'WELT', 'WENIG', 'WENN', 'WERDEN', 'WIE', 'WIEDER', 'WISSEN',
    'WO', 'WOHL', 'WOLLEN', 'WORT', 'ZEIT', 'ZIMMER', 'ZWEI', 'ZWISCHEN'
  ];
  
  File file = File('german_words.txt');
  file.writeAsStringSync(sampleWords.join('\n'));
  
  print('\x1b[38;5;39mCreated german_words.txt with ${sampleWords.length} sample words\x1b[0m');
  print('\x1b[38;5;39mNote: you should download a full German word list!\x1b[0m');
  print('\x1b[38;5;39mSuggested: https://github.com/Jonny-exe/German-Words-Library\x1b[0m\n');
}