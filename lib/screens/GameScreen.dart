import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:thematicsudoku/AppTheme.dart';
import 'package:thematicsudoku/AudioPlayer.dart';
import 'package:thematicsudoku/library.dart';
import 'package:thematicsudoku/sudoku.dart';
import 'package:thematicsudoku/AdManager.dart';
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
                                                    onPressed: () => {
                                                        showHintsDialog(context)
                                                    },
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
                                        height: grid.size > 5 ? 130 : 80,
                                        width: MediaQuery.of(context).size.width,
                                        child: Stack(
                                            children: [
                                                SvgPicture.asset(
                                                    'assets/svg/${grid.size > 5 ? 'options_bg' : 'options_small_bg'}.svg',
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
            if(size % 2 == 0) firstRow.add(SizedBox(width: 15));
            rows.add(
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: firstRow
                )
            );
            if(size % 2 == 0) secondRow = []..add(SizedBox(width: 15))..addAll(secondRow);
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
                grid.revealedCells = [];
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
                            onDoubleTap: !grid.isReplaceable(i, j) ? null : () {
                                setState(() {
                                    grid.cells[i][j] = 0;
                                    grid.revealedCells = [];
                                });
                            },
                            onTap: !grid.isReplaceable(i, j) ? null : () {
                                grid.revealedCells = [];
                                if (grid.cells[i][j] == selectedOption) {
                                    grid.cells[i][j] = 0;
                                } else {
                                    grid.cells[i][j] = selectedOption;
                                    validateGrid();
                                }
                                setState(() { });
                            },
                            child: Container(
                                padding: EdgeInsets.all(6 + (isBorder(i, j, sudoku.size) ? isCorner(i, j, sudoku) ? 2 : 1 : (((i % sudoku.height == 0 || j % sudoku.width == 0)) ? 1 : 2.5))),
                                child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Padding(
                                        padding: EdgeInsets.all(1),
                                        child: sudoku.cells[i][j] == 0 ? Text('') : SvgPicture.asset(
                                            'assets/categories/${THEMES[themeIdx]}/${sudoku.cells[i][j]}.svg',
                                            height: 80,
                                        )
                                    )
                                ),
                                decoration: BoxDecoration(
                                    color: grid.revealedCells.contains(Cell(row: i, col: j)) ? Colors.green : grid.cells[i][j] != 0 && grid.hasConflict(i, j) ? grid.isReplaceable(i, j) ? Colors.red : AppTheme.WRONG_OPT_NOT_REPL : selectedOption != 0 && selectedOption == grid.cells[i][j] ? AppTheme.SELECTED_OPT : grid.isReplaceable(i, j) ? AppTheme.REPLACEABLE : Colors.white,
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
                int earnedHints = 1 + level ~/ 10;
                hints += earnedHints;

                final snackBar = SnackBar(
                    duration: Duration(milliseconds: 500),
                    content: Text("+$earnedHints hint${earnedHints > 1 ? 's' : ''}")
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
            } else {
                if (time < Levels.getSudokuBySize(size)!.levelsTime[level - 1]) Levels.getSudokuBySize(size)!.levelsTime[level - 1] = time;
            }
            Levels.storeData();

            Future.delayed(Duration(milliseconds: 1000), () {
                Navigator.of(context).pop();
            });
        }
    }

    isCorner(int row, int col, Grid sudoku) {
        return (row == 0 && col == 0) || (row == 0 && col == sudoku.size - 1) ||
            (row == sudoku.size - 1 && col == 0) || (row == sudoku.size - 1 && col == sudoku.size - 1);
    }

    isBorder(int row, int col, size) {
        return row == 0 || col == 0 || row == size - 1 || col == size - 1;
    }

    Future<void> showHintsDialog(BuildContext context) {
        return showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
            barrierColor: Colors.black54,
            transitionDuration: Duration(milliseconds: 200),
            pageBuilder: (BuildContext buildContext, Animation animation, Animation secondaryAnimation) {
                return WillPopScope(
                    onWillPop: () {
                        return Future.value(true);
                    },
                    child: StatefulBuilder(
                        builder: (context, setState) {
                            Widget hintButton(int minHints, String txt, Function action) {
                                return Padding(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: Opacity(
                                        opacity: hints >= minHints ? 1 : 0.6,
                                        child: TextButton(
                                            onPressed: hints >= minHints ? () {
                                                // hints -= minHints; 
                                                action();
                                                Levels.storeData();
                                                Navigator.pop(context);
                                            } : null,
                                            child: hintContainer(txt, null, minHints.toString())
                                        )
                                    )
                                );
                            }

                            Widget getModeHintsButton() {
                                return grid.isSudokuFilled() ? SizedBox.shrink() : Column(
                                    children: [
                                        hintButton(1, 'Reveal Cell', revealCell),
                                        hintButton(size - 1, 'Reveal Block', revealBlock),
                                        hintButton(size + 1, 'Reveal ${themeTrim(themeIdx)}', revealOption)
                                    ]
                                );
                            }

                            return Align(
                                alignment: Alignment.topCenter,
                                child: Padding(
                                    padding: EdgeInsets.fromLTRB(15, 22, 15, 0),
                                    child: Material(
                                        type: MaterialType.transparency,
                                        child: Container(
                                            width: MediaQuery.of(context).size.width,
                                            height: grid.isSudokuFilled() ? hasConflict() ? 270 : 170 : 500,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(15),
                                                color: AppTheme.MAIN_COLOR
                                            ),
                                            child: Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                    Row(
                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                        children: [
                                                            Container(
                                                                padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
                                                                height: 35,
                                                                child: Row(
                                                                    children: [
                                                                        SizedBox(
                                                                            width: 20,
                                                                            child: Image(image: AssetImage('assets/png/hint.png'), fit: BoxFit.contain)
                                                                        ),
                                                                        SizedBox(
                                                                            width: 10
                                                                        ),
                                                                        Text(
                                                                            hints.toString(),
                                                                            style: TextStyle(
                                                                                fontFamily: 'Segoe UI',
                                                                                fontSize: 20,
                                                                                color: Color(0xFFFFD517),
                                                                                fontWeight: FontWeight.w700,
                                                                            )
                                                                        )
                                                                    ]
                                                                ),
                                                                decoration: BoxDecoration(
                                                                    color: Colors.white,
                                                                    shape: BoxShape.rectangle,
                                                                    borderRadius: BorderRadius.all(Radius.circular(30))
                                                                )
                                                            )
                                                        ]
                                                    ),
                                                    !hasConflict() ? SizedBox.shrink() : Padding(
                                                        padding: EdgeInsets.all(15),
                                                        child: hintButton(0, 'Clear Red Cells', clearWrongPlaced),
                                                    ),
                                                    Padding(
                                                        padding: EdgeInsets.all(15),
                                                        child: getModeHintsButton()
                                                    ),
                                                    Padding(
                                                        padding: EdgeInsets.all(15),
                                                        child: TextButton(
                                                            onPressed: () {
                                                                setState(() {
                                                                    getReward(RewardedAd rewardedAd, RewardItem rewardItem) {
                                                                        hints += size + 1;
                                                                        Levels.storeData();
                                                                    }
                                                                    AdManager.showRewardedAd(getReward);
                                                                });
                                                            },
                                                            child: hintContainer(null, Icons.video_call, '+${size + 1}')
                                                        )
                                                    )
                                                ]
                                            )
                                        )
                                    )
                                )
                            );
                        }
                    )
                );
            }
        ).then((value) => setState(() { }));
    }

    revealCell() {
        int row = 0;
        int col = 0;
        do {
            row = Random().nextInt(size);
            col = Random().nextInt(size);
        } while (grid.cells[row][col] != 0);

        grid.cells[row][col] = grid.solvedSudoku[row][col];
        grid.emptyCells.remove(Cell(row: row, col: col));
        grid.revealedCells.add(Cell(row: row, col: col));
    }

    revealOption() {
        int count = size;

        do {
            count = size;
            int idx = 1 + Random().nextInt(size);
            for (int i = 0; i < size; i++) {
                for (int j = 0; j < size; j++) {
                    if (grid.cells[i][j] == idx) count--;
                }
            }

            if (count > 0) {
                for (int i = 0; i < size; i++) {
                    for (int j = 0; j < size; j++) {
                        if (grid.solvedSudoku[i][j] == idx) grid.cells[i][j] = idx;
                    }
                }
                break;
            }
        } while (true);
    }

    revealBlock() {
        int choice = Random().nextInt(2);

        if (choice == 0) {
            int row = 0;
            do {
                row = Random().nextInt(size);
            } while (grid.remainingRowCells(row) == 0);
            grid.revealRow(row);
        } else if (choice == 1) {
            int col = 0;
            do {
                col = Random().nextInt(size);
            } while (grid.remainingColCells(col) == 0);
            grid.revealCol(col);
        }
    }

    clearWrongPlaced() {
        for (int i = 0; i < size; i++) {
            for (int j = 0; j < size; j++) {
                if (grid.hasConflict(i, j) && grid.isReplaceable(i, j)) {
                    grid.cells[i][j] = 0;
                }
            }
        }
    }

    bool hasConflict() {
        for (int i = 0; i < size; i++) {
            for (int j = 0; j < size; j++) {
                if (grid.hasConflict(i, j)) return true;
            }
        }
        return false;
    }

    

    Widget hintContainer(String? txt, IconData? icon, String hints) {
        return Container(
            height: 50,
            width: double.infinity,
            alignment: Alignment.center,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        txt != null ?
                        Text(
                            txt,
                            style: TextStyle(
                                fontFamily: 'Segoe UI',
                                fontSize: 20,
                                color: Color(0xFF876603),
                                fontWeight: FontWeight.w700
                            )
                        )
                        :
                        Icon(
                            icon,
                            color: Color(0xFF876603),
                            size: 40,
                        ),
                        Row(
                            children: [
                                Text(
                                    hints,
                                    style: TextStyle(
                                        fontFamily: 'Segoe UI',
                                        fontSize: 20,
                                        color: Color(0xFFFFD517),
                                        fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.center
                                ),
                                SizedBox( width: 5 ),
                                SizedBox(
                                    width: 20,
                                    child: Image(image: AssetImage('assets/png/hint.png'), fit: BoxFit.contain)
                                ),
                            ]
                        )
                    ]
                )
            ),
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(30))
            )
        );
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