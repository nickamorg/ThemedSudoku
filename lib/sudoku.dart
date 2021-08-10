import 'dart:convert';
import 'dart:math';
import 'package:thematicsudoku/DataStorage.dart';
import 'package:thematicsudoku/library.dart';

class SudokuGridView {
    Grid sudoku = Grid(size: 6);
    int totalLevels = 0;
    List<int> levelsTime = [];
    bool showThemes = false;
    bool showLevels = false;
    int expandedLevelIdx = -1;
    int selectedLevelThemeIdx = -1;
    String theme = THEMES[Random().nextInt(THEMES.length)];
    int size;
    List<int> levelThemes = List.generate(THEMES.length, (index) => 1 + Random().nextInt(THEMES.length));

    SudokuGridView({required this.size}) {
        sudoku = Grid(size: size);
        totalLevels = size * size;
    }

    double size2BorderSize() {
        return size == 4 ? 6 : size == 6 ? 4.5 : 3;
    }
}

class Grid {
    List<List<int>> cells = [];
    List<List<int>> solvedSudoku = [];
    int size;
    int height = 2;
    int width = 2;
    List<Cell> emptyCells = [];
    int emptyCellsCount = 0;
    List<Cell> revealedCells = [];

    Grid({required this.size}) {
        cells = List.generate(size, (i) => List.filled(size, 0, growable: true), growable: true);
        width = size % 2 == 0 ? size ~/ 2 : sqrt(size).toInt() * sqrt(size).toInt() == size ? sqrt(size).toInt() : size;
        height = size % 2 == 0 ? 2 : sqrt(size).toInt() * sqrt(size).toInt() == size ? sqrt(size).toInt() : 1;
    }

    @override
    String toString() {
        String str = '\n';
        cells.forEach((element) { str += element.toString() + '\n'; });

        return str;
    }

    List<List<int>> cloneSudoku(List<List<int>> sudoku) {
        List<List<int>> clonedSudoku = [];

        sudoku.forEach((rowCell) { 
            clonedSudoku.add(List.from(rowCell));
        });

        return clonedSudoku;
    }

    void generate(int clearedCells) {
        cells = List.generate(size, (i) => List.filled(size, 0, growable: true), growable: true);
        generateSudoku(0, 0);
        solvedSudoku = cloneSudoku(cells);
        emptyCellsCount = clearedCells;
        revealedCells = [];
        clearCells(clearedCells);
    }

    bool generateSudoku(int row, int col) {
        if (cells[row][col] == 0) {
            List<int> availableNumbers = List.generate(size, (index) => index + 1);
            bool isSolutionCorrect = true;
            bool flag = false;
            int idx = -1;
            int number = -1;

            do {
                if (!isSolutionCorrect) {
                    cells[row][col] = 0;
                    isSolutionCorrect = true;
                    availableNumbers.remove(number);
                    if (availableNumbers.length == 0) return false;
                }

                do {
                    idx = Random().nextInt(availableNumbers.length);
                    number = availableNumbers[idx];
                    availableNumbers.remove(number);

                    int diffCellRowNums = cells[row].takeWhile((cellCol) => cellCol != number).length;
                    int diffCellColNums = cells.takeWhile((cellRow) => cellRow[col] != number).length;
                    int diffCellBlockNums = checkBlock(row, col, number);

                    flag = diffCellBlockNums == size && diffCellRowNums == size && diffCellColNums == size;
                } while (!flag && availableNumbers.length > 0);

                if (!flag) return false;

                cells[row][col] = number;
                if (col < size - 1) {
                    isSolutionCorrect = generateSudoku(row, col + 1);
                } else if (row < size - 1) {
                    isSolutionCorrect = generateSudoku(row + 1, 0);
                }
            } while (!isSolutionCorrect);
        } else {
            if (col < size - 1) {
                return generateSudoku(row, col + 1);
            } else if (row < size - 1) {
                return generateSudoku(row + 1, 0);
            }
        }

        return true;
    }

    bool hasConflict(int row, int col) {
        for (int i = 0; i < size; i++) {
            if (cells[row][col] != 0 && cells[row][col] == cells[row][i] && i != col) return true;
        }

        for (int i = 0; i < size; i++) {
            if (cells[row][col] != 0 &&  cells[row][col] == cells[i][col] && i != row) return true;
        }

        int topRow = (row ~/ height) * height;
        int topCol = (col ~/ width) * width;
        for (int i = topRow; i < topRow + height; i++) {
            for (int j = topCol; j < topCol + width; j++) {
                if (cells[row][col] != 0 &&  cells[row][col] == cells[i][j] && (row != i || col != j)) return true;
            }
        }

        return false;
    }

    int checkBlock(int row, int col, int number) {
        int diffCellBlockNums = 0;

        int topRow = (row ~/ height) * height;
        int topCol = (col ~/ width) * width;
        for (int i = topRow; i < topRow + height; i++) {
            for (int j = topCol; j < topCol + width; j++) {
                if (cells[i][j] != number) diffCellBlockNums++;
            }
        }

        return diffCellBlockNums;
    }

    void clearCells(int total) {
        if (total == 0) return;

        emptyCells = [];

        do {
            int row = Random().nextInt(size);
            int col = Random().nextInt(size);

            if (cells[row][col] != 0) {
                emptyCells.add(Cell(row: row, col: col));
                cells[row][col] = 0;
                total--;
            }

        } while (total > 0);
    }

    bool isSolutionAmbiguous() {
        Grid clone = Grid(size: size);
        clone.cells = cloneSudoku(cells);
        clone.generate(0);

        for (int i = 0; i < size; i++) {
            for (int j = 0; j < size; j++) {
                if (solvedSudoku[i][j] != clone.cells[i][j]) {
                    return true;
                }
            }
        }

        return false;
    }

    bool isValidSolution() {
        bool isValidSolution = true;
        cells.forEach((cellRow) { 
            isValidSolution = cellRow.where((cell) => cell != 0).toSet().length == size;
        });
        if (!isValidSolution) return false;

        for (int j = 0; j < size; j++) {
            Set values = { };
            for (int i = 0; i < size; i++) {
                if (cells[i][j] != 0) values.add(cells[i][j]);
            }
            if (values.length != size) return false;
        }

        for (int i = 0; i < size; i += height) {
            for (int j = 0; j < size; j += width) {
                Set values = { };
                for (int col = i; col < i + height; col++) {
                    for (int row = j; row < j + width; row++) {
                        if (cells[i][j] != 0) values.add(cells[col][row]);
                    }
                }
                if (values.length != size) return false;
            }
        }

        return true;
    }

    bool isSudokuFilled() {
        int filled = 0;
        cells.forEach((cellRow) {
            cellRow.forEach((cell) {
                if (cell != 0) filled++;
            });
        });

        return filled == size * size;
    }

    int remainingRowCells(int row) {
        int count = 0;

        for (int col = 0; col < size; col++) {
            if (cells[row][col] == 0) count++;
        }

        return count;
    }

    int remainingColCells(int col) {
        int count = 0;

        for (int row = 0; row < size; row++) {
            if (cells[row][col] == 0) count++;
        }

        return count;
    }

    void revealRow(int row) {
        for (int col = 0; col < size; col++) {
            revealCell(row, col);
        }
    }

    void revealCol(int col) {
        for (int row = 0; row < size; row++) {
            revealCell(row, col);
        }
    }

    void revealCell(int row, int col) {
        cells[row][col] = solvedSudoku[row][col];
        Cell newCell = Cell(row: row, col: col);
        if (emptyCells.contains(newCell)) {
            emptyCells.remove(newCell);
            revealedCells.add(newCell);
        }
    }

    bool isReplaceable(int row, int col) {
        for (Cell cell in emptyCells) {
            if (cell.row == row && cell.col == col) return true;
        }

        return false;
    }
}

class Cell {
    int row;
    int col;

    Cell({required this.row, required this.col});

    bool operator ==(cords) => cords is Cell && row == cords.row && col == cords.col;

    int get hashCode => row.hashCode + col.hashCode;
}

class Levels {
    static List<SudokuGridView> sudokuList = [];

    static Future<void> init() async {
        sudokuList.add(SudokuGridView(size: 4));
        sudokuList.add(SudokuGridView(size: 6));
        sudokuList.add(SudokuGridView(size: 8));
        sudokuList.add(SudokuGridView(size: 9));

        sudokuList.forEach((sudokuGridView) {
            sudokuGridView.sudoku.generate(1);
        });

        await loadDataStorage();
    }

    static SudokuGridView? getSudokuBySize(int size) {
        for (SudokuGridView sudokuGridView in sudokuList) {
            if (sudokuGridView.size == size) return sudokuGridView;
        }

        return null;
    }

    static void storeData() {
		String str = '{"levels":{';
        int sudokuIdx = sudokuList.length;
        sudokuList.forEach((sudoku) {
            str += '"${sudoku.size}":{"time":${sudoku.levelsTime}}';
            str += '${(--sudokuIdx > 0 ? ',' : '')}';
        });
        str += '},"hints":$hints}';

		DataStorage.writeData(str);
    }

    static Future<void> loadDataStorage() async {
		await DataStorage.fileExists().then((value) async {
			if (value) {
				await DataStorage.readData().then((value) {
					if (value.isNotEmpty) {
						Map<String, dynamic> data = jsonDecode(value);

                        data['levels'].forEach((levelSize, levelData) {
                            SudokuGridView? sudokuGridView = getSudokuBySize(int.parse(levelSize));
                            sudokuGridView!.levelsTime = levelData['time'].cast<int>();
                            sudokuGridView.sudoku.generate(sudokuGridView.levelsTime.length + 1);
                        });

                        hints = data['hints'];
                    }
				});
			} else {
				DataStorage.createFile();
			}
		});
	}

    static void hideDetails() {
        sudokuList.forEach((sudoku) {
            sudoku.showThemes = false;
            sudoku.showLevels = false;
            sudoku.expandedLevelIdx = -1;
        });
    }

    static bool toShowDetails() {
        for (SudokuGridView sudoku in sudokuList) {
            if (sudoku.showThemes || sudoku.showLevels) return true;
        }
        return false;
    }
}

int hints = 23;

String displayCell(int number) {
    if (number == 0) return '';
    return number.toString();
}