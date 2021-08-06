import 'dart:math';

class Grid {
    List<List<int>> cells = [];
    List<List<int>> solvedSudoku = [];
    int size;
    int height = 2;
    int width = 2;
    List<Cell> emptyCells = [];
    int emptyCellsCount = 0;

    Grid({required this.size}) {
        cells = List.generate(size, (i) => List.filled(size, 0, growable: true), growable: true);
        width = size % 2 == 0 ? size ~/ 2 : sqrt(size).toInt() * sqrt(size).toInt() == size ? sqrt(size).toInt() : size;
        height = size % 2 == 0 ? 2 : sqrt(size).toInt() * sqrt(size).toInt() == size ? sqrt(size).toInt() : 1;
    }

    @override
    String toString() {
        String str = "\n";
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
        generateSudoku(0, 0);
        solvedSudoku = cloneSudoku(cells);
        emptyCellsCount = clearedCells;
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
            isValidSolution = cellRow.toSet().length == size;
        });
        if (!isValidSolution) return false;

        for (int j = 0; j < size; j++) {
            Set values = { };
            for (int i = 0; i < size; i++) {
                values.add(cells[i][j]);
            }
            if (values.length != size) return false;
        }

        for (int i = 0; i < size; i += height) {
            for (int j = 0; j < size; j += width) {
                Set values = { };
                for (int col = i; col < i + height; col++) {
                    for (int row = j; row < j + width; row++) {
                        values.add(cells[col][row]);
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

    
}

class Cell {
    int row;
    int col;

    Cell({required this.row, required this.col});
}