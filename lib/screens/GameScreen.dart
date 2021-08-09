import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thematicsudoku/AppTheme.dart';
import 'package:thematicsudoku/AudioPlayer.dart';
import 'package:thematicsudoku/library.dart';
import 'package:thematicsudoku/sudoku.dart';
import 'dart:async';

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
    Timer? timer;
    int time = 0;
    bool isSolved = false;

    @override
	void initState() {
		super.initState();

        size = widget.size;
        level = widget.level;
        themeIdx = widget.themeIdx;
        grid = Grid(size: size);
        grid.generate(level);

        startTimer();
    }

    @override
    void dispose() {
        super.dispose();

        timer!.cancel();
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
                    selectedOption != 0 ?  SvgPicture.asset(
                        'assets/categories/${THEMES[themeIdx]}/$selectedOption.svg',
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.cover
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
                                                                        timer!.cancel();
                                                                        startTimer();
                                                                        grid.generate(level);
                                                                    });
                                                                },
                                                                child: SvgPicture.asset(
                                                                    'assets/svg/time.svg',
                                                                    height: 70
                                                                )
                                                            ),
                                                            SizedBox(height: 5),
                                                            Text(
                                                                getDurationInTime(time),
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
                                                    onPressed: () => { },
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
                                        height: MediaQuery.of(context).size.width - 10,
                                        width: MediaQuery.of(context).size.width - 10,
                                        child: Card(
                                            shape: RoundedRectangleBorder(
                                                side: BorderSide(width: 6, color: AppTheme.SECOND_COLOR),
                                                borderRadius: BorderRadius.circular(10)
                                            ),
                                            child: GridView.count(
                                                physics: NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                crossAxisCount: size,
                                                children: getSudokuBoard(grid)
                                            )
                                        )
                                    ),
                                    Container(
                                        height: 130,
                                        width: MediaQuery.of(context).size.width,
                                        child: Stack(
                                            children: [
                                                SvgPicture.asset(
                                                    'assets/svg/options_bg.svg',
                                                    alignment: Alignment.center,
                                                    width: MediaQuery.of(context).size.width,
                                                    height: MediaQuery.of(context).size.height,
                                                    fit: BoxFit.fill,
                                                ),
                                                Center(
                                                    child: AbsorbPointer(
                                                        absorbing: isSolved,
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
                                ]
                            )
                        )
                    )
                ]
            )
        );
    }

    void startTimer() {
        time = 0;
        const oneSec = const Duration(seconds: 1);
        timer = Timer.periodic(
            oneSec,
            (Timer timer) { 
                if (mounted) { 
                    setState(() {
                        time++;
                    });
                }
            }
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
        List<Widget> cells = [];

        for (int i = 0; i < sudoku.size; i++) {
            for (int j = 0; j < sudoku.size; j++) {
                cells.add(
                    AbsorbPointer(
                        absorbing: isSolved,
                        child: GestureDetector(
                            onDoubleTap: !isReplaceable(i, j) ? null : () {
                                setState(() {
                                    grid.cells[i][j] = 0;
                                });
                            },
                            onTap: !isReplaceable(i, j) ? null : () {
                                if (grid.cells[i][j] == selectedOption) {
                                    grid.cells[i][j] = 0;
                                } else {
                                    grid.cells[i][j] = selectedOption;
                                    validateGrid();
                                }
                                setState(() { });
                            },
                            child: Container(
                                padding: EdgeInsets.all(6),
                                child: Center(
                                    child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Padding(
                                            padding: EdgeInsets.all(1),
                                            child: sudoku.cells[i][j] == 0 ? Text('') : SvgPicture.asset(
                                                'assets/categories/${THEMES[themeIdx]}/${sudoku.cells[i][j]}.svg',
                                                height: 80,
                                            )
                                        )
                                    )
                                ),
                                decoration: BoxDecoration(
                                    color: grid.cells[i][j] != 0 && grid.hasConflict(i, j) ? isReplaceable(i, j) ? Colors.red : AppTheme.WRONG_OPT_NOT_REPL : selectedOption != 0 && selectedOption == grid.cells[i][j] ? AppTheme.SELECTED_OPT : isReplaceable(i, j) ? AppTheme.REPLACEABLE : Colors.white,
                                    shape: BoxShape.rectangle,
                                    borderRadius: isCorner(i, j, sudoku) ? BorderRadius.only(
                                        topLeft: Radius.circular(i == 0 && j == 0 ? 10 : 0),
                                        topRight: Radius.circular(i == 0 && j == sudoku.size - 1 ? 10 : 0),
                                        bottomLeft: Radius.circular(i == sudoku.size - 1 && j == 0 ? 10 : 0),
                                        bottomRight: Radius.circular(i == sudoku.size - 1 && j == sudoku.size - 1 ? 10 : 0),
                                    ) : null,
                                    border: !isCorner(i, j, sudoku) ? Border(
                                        left: BorderSide(width: j % sudoku.width == 0 ? 6 : 1, color: AppTheme.SECOND_COLOR),
                                        right: BorderSide(width: 1, color: AppTheme.SECOND_COLOR),
                                        top: BorderSide(width: i % sudoku.height == 0 ? 6 : 1, color: AppTheme.SECOND_COLOR),
                                        bottom: BorderSide(width: 1, color: AppTheme.SECOND_COLOR)
                                    ) : Border.all(color: AppTheme.SECOND_COLOR),
                                )
                            )
                        )
                    )
                );
            }
        }

        return cells;
    }

    validateGrid() {
        isSolved = grid.isValidSolution();
        if (isSolved) {
            timer!.cancel();
            AudioPlayer.play(AudioList.WIN);
            if (level - 1 >= Levels.getSudokuBySize(size)!.levelsTime.length) {
                Levels.getSudokuBySize(size)!.levelsTime.add(time);
            } else {
                Levels.getSudokuBySize(size)!.levelsTime[level - 1] = time;
            }
            Levels.storeData();

            Future.delayed(Duration(milliseconds: 1000), () {
                Navigator.of(context).pop();
            });
        }
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