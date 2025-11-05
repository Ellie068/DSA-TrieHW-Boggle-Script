// generates a random 6x6 letter grid for 'Boggle' game
// saves it to a JSON file that can be edited manually

import 'dart:io';
import 'dart:convert';
import 'dart:math';

void main() {
  print('=== Boggle Grid Generator ===\n');
  
  // Ask user if they want random or manual input
  print('Choose an option:');
  print('1. Generate random 5x5 grid');
  print('2. Generate random 6x6 grid');
  stdout.write('Enter choice (1 or 2): ');
  
  String? choice = stdin.readLineSync();
  
  List<String> grid;
  
  if (choice == '2') {
    grid = generateRandomGrid6();
  } else {
    grid = generateRandomGrid5();
  }
  
  // Display the grid
  print('\nGenerated Grid:');
  printGrid(grid);
  
  // Save to JSON file
  saveGridToJson(grid, 'boggle_grid.json');
  
  print('\n✓ Grid saved to boggle_grid.json');
  print('You can edit this file manually to change letters!');
}

// Generate a random 6x6 grid
List<String> generateRandomGrid6() {
  // German letter frequency (approximate)
  // common letters appear more times in this string
  String germanLetters = 
      'EEEEEEEEEE'  // E leter usually common (in most and also duetsch word letter statistics)
      'NNNNNNNN'
      'IIIIII'
      'RRRRRR'
      'SSSSSS'
      'TTTTT'
      'AAAAA'
      'DDDD'
      'HHHH'
      'UUUU'
      'LLLL'
      'CCC'
      'GGG'
      'MMM'
      'OOO'
      'BBB'
      'WWW'
      'FFF'
      'KK'
      'ZZ'
      'PP'
      'VV'
      'JJ'
      'YY'
      'XQ'; // rare letters
  
  Random random = Random();
  List<String> grid = [];
  
  for (int i = 0; i < 6; i++) {
    String row = '';
    for (int j = 0; j < 6; j++) {
      // random letter based on frequency
      int index = random.nextInt(germanLetters.length);
      row += germanLetters[index];
    }
    grid.add(row);
  }
  
  return grid;
}

List<String> generateRandomGrid5() {
  // German letter frequency (approximate)
  // common letters appear more times in this string
  String germanLetters = 
      'EEEEEEEEEE'  // E leter usually common (in most and also duetsch word letter statistics)
      'NNNNNNNN'
      'IIIIII'
      'RRRRRR'
      'SSSSSS'
      'TTTTT'
      'AAAAA'
      'DDDD'
      'HHHH'
      'UUUU'
      'LLLL'
      'CCC'
      'GGG'
      'MMM'
      'OOO'
      'BBB'
      'WWW'
      'FFF'
      'KK'
      'ZZ'
      'PP'
      'VV'
      'JJ'
      'YY'
      'XQ'; // rare letters
  
  Random random = Random();
  List<String> grid = [];
  
  for (int i = 0; i < 5; i++) {
    String row = '';
    for (int j = 0; j < 5; j++) {
      // random letter based on frequency
      int index = random.nextInt(germanLetters.length);
      row += germanLetters[index];
    }
    grid.add(row);
  }
  
  return grid;
}

// Get grid manually from user input
// List<String> getManualGrid() {
//   List<String> grid = [];
  
//   print('\nEnter 6 rows of 6 letters each:');
//   for (int i = 0; i < 6; i++) {
//     stdout.write('Row ${i + 1}: ');
//     String? input = stdin.readLineSync();
    
//     if (input == null || input.length != 6) {
//       print('Error: Please enter exactly 6 letters!');
//       i--; // Try again
//       continue;
//     }
    
//     grid.add(input.toUpperCase());
//   }
  
//   return grid;
// }

// Print the grid nicely
void printGrid(List<String> grid) {
  print('');
  for (String row in grid) {
    print(row.split('').join(' '));
  }
}

// Save grid to JSON file
void saveGridToJson(List<String> grid, String filename) {
  Map<String, dynamic> data = {
    'grid': grid,
    'size': 6,
    'description': 'Boggle grid - you can edit the letters manually'
  };
  
  String jsonString = JsonEncoder.withIndent('  ').convert(data);
  
  File file = File(filename);
  file.writeAsStringSync(jsonString);
}