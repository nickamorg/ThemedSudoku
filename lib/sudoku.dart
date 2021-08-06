import 'dart:math';

class Grid {
    List<List<int>> cells = [];
    int size;
    int height = 2;
    int width = 2;

    Grid({required this.size}) {
        cells = List.generate(size, (i) => List.filled(size, 0, growable: true), growable: true);
        width = size % 2 == 0 ? size ~/ 2 : size % 3 == 0 ? size ~/ 3 : size;
        height = size % 2 == 0 ? 2 : sqrt(size).toInt() * sqrt(size).toInt() == size ? sqrt(size).toInt() : 1;
    }

    @override
    String toString() {
        String str = "\n";
        cells.forEach((element) { str += element.toString() + '\n'; });

        return str;
    }

    void generate() {
        generateSudoku(0, 0);
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
}