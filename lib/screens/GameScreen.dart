import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:themedsudoku/AppTheme.dart';
import 'package:themedsudoku/library.dart';
import 'package:themedsudoku/sudoku.dart';

class GameScreen extends StatelessWidget {
    final int size;
    final int level;
    final int themeIdx;

    GameScreen({ Key? key, required this.size, required this.level, required this.themeIdx}) : super(key: key);

	@override
	Widget build(BuildContext context) {
        return Game(size: size, level: level, themeIdx: themeIdx);
	}
}

class GameState extends State<Game> with TickerProviderStateMixin {
    Grid grid = Grid(size: 4);
    int size = 4;
    int level = 1;
    int themeIdx = 0;
    int selectedOption = 0;

    @override
	void initState() {
		super.initState();

        size = widget.size;
        level = widget.level;
        themeIdx = widget.themeIdx;
        grid = Grid(size: size);
        grid.generate(level);
    }

	@override
    Widget build(BuildContext context) {
        return Scaffold(
            body: Stack(
                children: [
                    Container(
                        decoration: BoxDecoration(
                            color: AppTheme.MAIN_COLOR
                        )
                    ),
                    selectedOption != -1 ?  SvgPicture.asset(
                        'assets/categories/${THEMES[themeIdx]}/$selectedOption.svg',
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.cover,
                    ) : SizedBox.shrink(),
                    Container(
                        child: Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                    Padding(
                                        padding: EdgeInsets.all(10),
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                                TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    style: TextButton.styleFrom(
                                                        padding: EdgeInsets.zero,
                                                        splashFactory: NoSplash.splashFactory
                                                    ),
                                                    child: SvgPicture.asset(
                                                        'assets/svg/back.svg',
                                                        height: 40
                                                    )
                                                ),
                                                Padding(
                                                    padding: EdgeInsets.only(top: 20),
                                                    child: Column(
                                                        children: [
                                                            GestureDetector(
                                                                onDoubleTap: () {
                                                                    setState(() {
                                                                        selectedOption = 0;
                                                                        grid.generate(level);
                                                                    });
                                                                },
                                                                child: SvgPicture.asset(
                                                                    'assets/svg/time.svg',
                                                                    height: 90
                                                                )
                                                            ),
                                                            SizedBox(height: 5),
                                                            Text(
                                                                getDurationInTime(67),
                                                                style: TextStyle(
                                                                    color: Colors.black,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 20
                                                                )
                                                            )
                                                        ]
                                                    )
                                                ),
                                                TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    style: TextButton.styleFrom(
                                                        padding: EdgeInsets.zero,
                                                        splashFactory: NoSplash.splashFactory
                                                    ),
                                                    child: SvgPicture.asset(
                                                        'assets/svg/hint.svg',
                                                        height: 40
                                                    )
                                                )
                                            ]
                                        )
                                    ),
                                    Container(
                                        height: MediaQuery.of(context).size.height - 350,
                                        width: MediaQuery.of(context).size.height - 350,
                                        child: Card(
                                            shape: RoundedRectangleBorder(
                                                side: BorderSide(width: 3, color: Color(0xFF2FB898)),
                                                borderRadius: BorderRadius.circular(10)
                                            ),
                                            child: GridView.count(
                                                physics: NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                crossAxisCount: size,
                                                children: getSudokuBoard(grid)
                                            )
                                        ),
                                    ),
                                    Container(
                                        height: 150,
                                        width: MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage('assets/png/options_bg.png'),
                                                // colorFilter: ColorFilter.linearToSrgbGamma(),
                                                fit: BoxFit.fill
                                            )
                                        ),
                                        child: Center(
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: optionsWidget()
                                            )
                                        )
                                    )
                                ]
                            )
                        )
                    )
                ]
            )
        );
    }

    List<Widget> optionsWidget() {
        List<Widget> rows = [];
        List<Widget> firstRow = [];
        List<Widget> secondRow = [];

        if (size <= 5) {
            for (int i = 1; i <= size; i++) {
                firstRow.add(optionButton(i));
            }
            rows.add(
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: firstRow
                )
            );
        } else {
            for (int i = 1; i <= size; i += 2) {
                firstRow.add(optionButton(i));
                if ( i + 1 <= size) secondRow.add(optionButton(i + 1));
            }
            rows.add(
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: firstRow
                )
            );
            rows.add(
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: secondRow
                )
            );
        }

        return rows;
    }

    TextButton optionButton(int idx) {
        return TextButton(
            style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: selectedOption == idx ? 0 : 10)
            ),
            onPressed: () {
                if (selectedOption == idx) {
                    selectedOption = 0;
                } else {
                    selectedOption = idx;
                }

                setState(() { });
                print(idx);
            },
            child: selectedOption == idx ? 
            Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/png/option_bg.png'),
                    )
                ),
                child: Center(
                    child: SvgPicture.asset(
                        'assets/categories/${THEMES[themeIdx]}/$idx.svg',
                        height: 40,
                        fit: BoxFit.scaleDown,
                    )
                )
            ) : SvgPicture.asset(
                'assets/categories/${THEMES[themeIdx]}/$idx.svg',
                height: 40
            )
        );
    }

    getSudokuBoard(Grid sudoku) {
        List<GestureDetector> cells = [];

        for (int i = 0; i < sudoku.size; i++) {
            for (int j = 0; j < sudoku.size; j++) {
                cells.add(
                    GestureDetector(
                        onDoubleTap: !isReplaceable(i, j) ? null : () {
                            setState(() {
                                grid.cells[i][j] = 0;
                            });
                        },
                        onTap: !isReplaceable(i, j) ? null : () {
                            setState(() {
                                grid.cells[i][j] = selectedOption;
                            });
                        },
                        child: Container(
                            padding: EdgeInsets.all(5),
                            child: Center(
                                child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Padding(
                                        padding: EdgeInsets.all(1),
                                        child: sudoku.cells[i][j] == 0 ? Text('') : SvgPicture.asset(
                                            'assets/categories/${THEMES[themeIdx]}/${sudoku.cells[i][j]}.svg',
                                            height: 40
                                        )
                                    )
                                )
                            ),
                            decoration: BoxDecoration(
                                color: grid.cells[i][j] != 0 && grid.hasConflict(i, j) ? isReplaceable(i, j) ? Colors.red : Color(0xFFFF6767) : selectedOption != 0 && selectedOption == grid.cells[i][j] ? Color(0xFFFFD11B) : isReplaceable(i, j) ? Color(0xFFE4E1E1) : Colors.white,
                                shape: BoxShape.rectangle,
                                borderRadius: isCorner(i, j, sudoku) ? BorderRadius.only(
                                    topLeft: Radius.circular(i == 0 && j == 0 ? 10 : 0),
                                    topRight: Radius.circular(i == 0 && j == sudoku.size - 1 ? 10 : 0),
                                    bottomLeft: Radius.circular(i == sudoku.size - 1 && j == 0 ? 10 : 0),
                                    bottomRight: Radius.circular(i == sudoku.size - 1 && j == sudoku.size - 1 ? 10 : 0),
                                ) : null,
                                border: !isCorner(i, j, sudoku) ? Border(
                                    left: BorderSide(width: j % sudoku.width == 0 ? 3 : 1, color: Color(0xFF2FB898)),
                                    right: BorderSide(width: 1, color: Color(0xFF2FB898)),
                                    top: BorderSide(width: i % sudoku.height == 0 ? 3 : 1, color: Color(0xFF2FB898)),
                                    bottom: BorderSide(width: 1, color: Color(0xFF2FB898))
                                ) : Border.all(color: Color(0xFF2FB898)),
                            )
                        )
                    )
                );
            }
        }

        return cells;
    }

    isReplaceable(int row, int col) {
        for (Cell cell in grid.emptyCells) {
            if (cell.row == row && cell.col == col) return true;
        }

        return false;
    }

    isCorner(int row, int col, Grid sudoku) {
        return (row == 0 && col == 0) || (row == 0 && col == sudoku.size - 1) ||
            (row == sudoku.size - 1 && col == 0) || (row == sudoku.size - 1 && col == sudoku.size - 1);
    }
}

class Game extends StatefulWidget {
    final int size;
    final int level;
    final int themeIdx;

    Game({ Key? key, required this.size, required this.level, required this.themeIdx}) : super(key: key);

	@override
	State createState() => GameState();
}