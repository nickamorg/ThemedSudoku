import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:launch_review/launch_review.dart';
import 'package:thematicsudoku/AppTheme.dart';
import 'package:thematicsudoku/library.dart';
import 'package:thematicsudoku/screens/GameScreen.dart';
import 'package:thematicsudoku/sudoku.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:numerus/numerus.dart';

class HomeScreen extends StatelessWidget {

	@override
	Widget build(BuildContext context) {
        return MaterialApp(
			home: Home()
		);
	}
}

class HomeState extends State<Home> {

    @override
    void initState() {
        super.initState();
        Levels.init().then((value) => setState((){ }));
        // AdManager.initGoogleMobileAds();
    }

	@override
    Widget build(BuildContext context) {
        return Scaffold(
            body: Container(
                decoration: BoxDecoration(
                    color: AppTheme.MAIN_COLOR
                ),
                child: Center(
                    child: TextButton(
                        onPressed: !Levels.toShowDetails() ? null : () {
                            setState(() {
                                Levels.hideDetails();
                            });
                        },
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            splashFactory: NoSplash.splashFactory
                        ),
                        child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                    Text(
                                        'SUDOKU',
                                        style: TextStyle(
                                            fontSize: 70,
                                            color: Colors.black
                                        )
                                    ),
                                    sudokuModes(),
                                    RatingCard()
                                ]
                            )
                        )
                    )
                )
            )
        );
    }

    sudokuModes() {
        return CarouselSlider(
            options: CarouselOptions(height: MediaQuery.of(context).size.height - 200),
            items: Levels.sudokuList.map((sudoku) {
                return Stack(
                    children: [
                        Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    sudokuStatus(sudoku),
                                    sudokuGrid(sudoku),
                                    sudokuTrailingText(sudoku)
                                ]
                            )
                        ),
                        sudokuLevelsCard(sudoku)
                    ]
                );
            }).toList()
        );
    }

    sudokuStatus(SudokuGridView sudokuGridView) {
        return TextButton(
            onPressed: sudokuGridView.showThemes ? null : () {
                setState(() {
                    Levels.hideDetails();
                    if (sudokuGridView.levelsTime.length == 0 || sudokuGridView.levelsTime.length == sudokuGridView.totalLevels) {
                        sudokuGridView.showThemes = true;
                    } else {
                        sudokuGridView.showLevels = true;
                    }
                });
            },
            style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                splashFactory: NoSplash.splashFactory
            ),
            child: Column(
                children: [
                    Padding(
                        padding: EdgeInsets.only(
                            bottom: 5
                        ),
                        child: SvgPicture.asset(
                            'assets/svg/star.svg',
                            height: 40
                        )
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            bottom: 5
                        ),
                        child: Text(
                            '${sudokuGridView.levelsTime.length}/${sudokuGridView.totalLevels}',
                            style: TextStyle(
                                fontSize: 30,
                                color: Colors.black
                            )
                        )
                    )
                ]
            )
        );
    }

    sudokuGrid(SudokuGridView sudokuGridView) {
        return Container(
            height: 250,
            width: 250,
            child: Center(
                child: Stack(
                    children: [
                        GestureDetector(
                            onTap: () => boardPressEvent(sudokuGridView),
                            onVerticalDragEnd: (dragEndDetails) => boardPressEvent(sudokuGridView),
                            child: Card(
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(width: sudokuGridView.size2BorderSize(), color: AppTheme.SECOND_COLOR),
                                    borderRadius: BorderRadius.circular(10)
                                ),
                                child: GridView.count(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    crossAxisCount: sudokuGridView.size,
                                    children: getSudokuBoard(sudokuGridView)
                                )
                            )
                        ),
                        Visibility(
                            visible: sudokuGridView.showThemes,
                            child: GestureDetector(
                                onTap: () {
                                    setState(() {
                                        sudokuGridView.showThemes = false;
                                    });
                                },
                                onVerticalDragEnd: (dragEndDetails) {
                                    setState(() {
                                        sudokuGridView.showThemes = false;
                                    });
                                },
                                child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: GridView.count(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        crossAxisCount: 3,
                                        children: getThemes(sudokuGridView)
                                    )
                                )
                            )
                        )
                    ]
                )
            )
        );
    }

    boardPressEvent(SudokuGridView sudokuGridView) {
        if (sudokuGridView.totalLevels == sudokuGridView.levelsTime.length) {
            sudokuGridView.showLevels = true;
        } else {
            sudokuGridView.showThemes = true;
        }
        setState(() { });
    }

    sudokuTrailingText(SudokuGridView sudokuGridView) {
        return Padding(
            padding: EdgeInsets.only(
                top: 5
            ),
            child: Text(
                sudokuGridView.showThemes ? 'Select Theme' : '${sudokuGridView.size} X ${sudokuGridView.size}',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontStyle: FontStyle.italic
                )
            )
        );
    }

    sudokuLevelsCard(SudokuGridView sudokuGridView) {
        return Visibility(
            visible: sudokuGridView.showLevels,
            child: Center(
                child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    ),
                    child: Container(
                        height: 400,
                        child: TextButton(
                            onPressed: () { },
                            style: TextButton.styleFrom(
                                enableFeedback: false,
                                splashFactory: NoSplash.splashFactory
                            ),
                            child: Column(
                                children: [
                                    TextButton(
                                        onPressed: () {
                                            setState(() {
                                                Levels.hideDetails();
                                                sudokuGridView.showLevels = false;
                                            });
                                        },
                                        style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            splashFactory: NoSplash.splashFactory
                                        ),
                                        child: Column(
                                            children: [
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 5,
                                                        top: 10.5
                                                    ),
                                                    child: SvgPicture.asset(
                                                        'assets/svg/star.svg',
                                                        height: 40
                                                    )
                                                ),
                                                Text(
                                                    '${sudokuGridView.levelsTime.length}/${sudokuGridView.totalLevels}',
                                                    style: TextStyle(
                                                        fontSize: 30,
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.w500
                                                    )
                                                )
                                            ]
                                        )
                                    ),
                                    sudokuLevels(sudokuGridView)
                                ]
                            )
                        )
                    )
                )
            )
        );
    }

    sudokuLevels(SudokuGridView sudokuGridView) {
        return Expanded(
            child: Padding(
                padding: EdgeInsets.fromLTRB(5, 15, 5, 5),
                child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: sudokuGridView.levelsTime.length,
                    separatorBuilder: (BuildContext context, int index) => SizedBox(height: 10), 
                    itemBuilder: (BuildContext context, int index) {
                        return Card(
                            color: Color(0xFF54E6C4),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: TextButton(
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero
                                ),
                                onPressed: sudokuGridView.expandedLevelIdx == index ? () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => GameScreen(size: sudokuGridView.size, level: index + 1, themeIdx: sudokuGridView.selectedLevelThemeIdx)
                                        )
                                    ).then((value) {
                                        popScreenRefresh();
                                    });
                                } : () { 
                                    setState(() {
                                        sudokuGridView.expandedLevelIdx = index;
                                        sudokuGridView.selectedLevelThemeIdx = 0;
                                    });
                                },
                                child: Container(
                                    height: 50,
                                    padding: EdgeInsets.symmetric(horizontal: 15),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                            sudokuLevelLabel(sudokuGridView, index),
                                            sudokuGridView.expandedLevelIdx == index ? sudokuLevelThemes(sudokuGridView) : sudokuLevelTime(sudokuGridView, index)
                                        ]
                                    )
                                )
                            )
                        );
                    }
                )
            )
        );
    }

    getThemes(SudokuGridView sudokuGridView) {
        List<Widget> themes = [];

        for (int i = 0; i < THEMES.length; i++) {
            int idx = 1 + Random().nextInt(THEMES.length);

            themes.add(
                TextButton(
                    onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GameScreen(size: sudokuGridView.size, level: sudokuGridView.levelsTime.length + 1, themeIdx: i)
                            )
                        ).then((value) {
                            popScreenRefresh();
                        });
                    },
                    child: Padding(
                        padding: EdgeInsets.all(5),
                        child: Container(
                            child: SvgPicture.asset(
                                'assets/categories/${THEMES[i]}/$idx.svg',
                                height: 50,
                            )
                        )
                    )
                )
            );
        }

        return themes;
    }

    popScreenRefresh() {
        Levels.sudokuList.forEach((sudokuGridView) {
            sudokuGridView.sudoku.generate(sudokuGridView.levelsTime.length + 1);
        });
        Levels.hideDetails();

        setState(() { });
    }

    sudokuLevelThemes(SudokuGridView sudokuGridView) {
        return Container(
            width: 100,
            child: Center(
                child: RotatedBox(
                    quarterTurns: 3,
                    child: ListWheelScrollView.useDelegate(
                        physics: FixedExtentScrollPhysics(),
                        perspective: 0.01,
                        itemExtent: 50,
                        childDelegate: ListWheelChildLoopingListDelegate(
                            children: getLevelThemes(sudokuGridView)
                        ),
                        onSelectedItemChanged: (index) {
                            setState(() {
                                sudokuGridView.selectedLevelThemeIdx = index;
                            });
                        }
                    )
                )
            )
        );
    }

    sudokuLevelLabel(SudokuGridView sudokuGridView, int index) {
        return RichText(
            text: TextSpan(
                children: [
                    TextSpan(
                        text: 'Level ',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 20
                        )
                    ),
                    TextSpan(
                        text: (index + 1).toRomanNumeralString(),
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold
                        )
                    )
                ]
            )
        );
    }

    sudokuLevelTime(SudokuGridView sudokuGridView, int index) {
        return Row(
            children: [
                Text(
                    getDurationInTime(sudokuGridView.levelsTime[index]),
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    )
                ),
                SizedBox(width: 10),
                SvgPicture.asset(
                    'assets/svg/time.svg',
                    height: 20
                )
            ]
        );
    }

    getLevelThemes(SudokuGridView sudokuGridView) {
        List<Widget> themes = [];

        for (int i = 0; i < THEMES.length; i++) {

            themes.add(
                RotatedBox(
                    quarterTurns: 1,
                    child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Container(
                            child: SvgPicture.asset(
                                'assets/categories/${THEMES[i]}/${sudokuGridView.levelThemes[i]}.svg',
                                height: 40
                            )
                        )
                    )
                )
            );
        }

        return themes;
    }

    getSudokuBoard(SudokuGridView sudokuGridView) {
        List<Container> cells = [];

        for (int i = 0; i < sudokuGridView.size; i++) {
            for (int j = 0; j < sudokuGridView.size; j++) {
                cells.add(
                    Container(
                        padding: EdgeInsets.all(5),
                        child: Center(
                            child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Padding(
                                    padding: EdgeInsets.all(1),
                                    child: sudokuGridView.sudoku.cells[i][j] == 0 ? Text('') : SvgPicture.asset(
                                        'assets/categories/${sudokuGridView.theme}/${sudokuGridView.sudoku.cells[i][j]}.svg',
                                        height: 40
                                    )
                                )
                            )
                        ),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            borderRadius: isCorner(i, j, sudokuGridView) ? BorderRadius.only(
                                topLeft: Radius.circular(i == 0 && j == 0 ? 10 : 0),
                                topRight: Radius.circular(i == 0 && j == sudokuGridView.sudoku.size - 1 ? 10 : 0),
                                bottomLeft: Radius.circular(i == sudokuGridView.sudoku.size - 1 && j == 0 ? 10 : 0),
                                bottomRight: Radius.circular(i == sudokuGridView.size - 1 && j == sudokuGridView.size - 1 ? 10 : 0),
                            ) : null,
                            border: !isCorner(i, j, sudokuGridView) ? Border(
                                left: BorderSide(width: j % sudokuGridView.sudoku.width == 0 ? sudokuGridView.size2BorderSize() : 1, color: AppTheme.SECOND_COLOR),
                                right: BorderSide(width: 1, color: AppTheme.SECOND_COLOR),
                                top: BorderSide(width: i % sudokuGridView.sudoku.height == 0 ? sudokuGridView.size2BorderSize() : 1, color: AppTheme.SECOND_COLOR),
                                bottom: BorderSide(width: 1, color: AppTheme.SECOND_COLOR)
                            ) : Border.all(color: AppTheme.SECOND_COLOR),
                        )
                    )
                );
            }
        }

        return cells;
    }

    isCorner(int row, int col, SudokuGridView sudokuGridView) {
        return (row == 0 && col == 0) || (row == 0 && col == sudokuGridView.size - 1) ||
            (row == sudokuGridView.size - 1 && col == 0) || (row == sudokuGridView.size - 1 && col == sudokuGridView.size - 1);
    }
}

class RatingCard extends StatelessWidget {

    @override
    Widget build(BuildContext context) {
        return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)
            ),
            child: Container(
                width: MediaQuery.of(context).size.width / 2,
                height: 60,
                child: TextButton(
                    onPressed: () => {
                       LaunchReview.launch(androidAppId: 'com.zirconworks.thematicsudoku')
                    },
                    child: Center(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                                Text(
                                    'Rate us',
                                    style: TextStyle(
                                        fontSize: 25,
                                        color: AppTheme.SECOND_COLOR,
                                        fontWeight: FontWeight.bold
                                    )
                                ),
                                SvgPicture.asset(
                                    'assets/svg/like.svg',
                                    height: 40
                                )
                            ]
                        )
                    )
                )
            )
        );
    }
}

class Home extends StatefulWidget {

	@override
	State createState() => HomeState();
}