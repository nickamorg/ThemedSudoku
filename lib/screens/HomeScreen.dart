import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:launch_review/launch_review.dart';
import 'package:themedsudoku/AppTheme.dart';
import 'package:themedsudoku/library.dart';
import 'package:themedsudoku/sudoku.dart';
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
    Levels levels = Levels();
    Grid grid = Grid(size: 4);

    @override
    void initState() {
        super.initState();

        // AdManager.initGoogleMobileAds();
    }

	@override
    Widget build(BuildContext context) {
        return Scaffold(
            body: TextButton(
                onPressed: !levels.toShowDetails() ? null : () {
                    setState(() {
                        levels.hideDetails();
                    });
                },
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero
                ),
                child: Container(
                    decoration: BoxDecoration(
                        color: AppTheme.MAIN_COLOR
                    ),
                    child: Column(
                        children: [
                            Padding(
                                padding: EdgeInsets.only(top: 20),
                                child: Text(
                                    'SUDOKU',
                                    style: TextStyle(
                                        fontSize: 70,
                                        color: Colors.black
                                    )
                                )
                            ),
                            Expanded(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                        sudokuModes(),
                                        RatingCard()
                                    ]
                                )
                            )
                        ]
                    )
                )
            )
        );
    }

    sudokuModes() {
        return CarouselSlider(
            options: CarouselOptions(height: MediaQuery.of(context).size.height - 250),
            items: levels.sudokuList.map((sudoku) {
                return Stack(
                    children: [
                        Center(
                            child: Column(
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

    sudokuStatus(Grid sudoku) {
        return TextButton(
            onPressed: () {
                setState(() {
                    levels.hideDetails();
                    sudoku.showLevels = true;
                });
            },
            style: TextButton.styleFrom(
                padding: EdgeInsets.zero
            ),
            child: Column(
                children: [
                    Padding(
                        padding: EdgeInsets.only(
                            bottom: 10,
                            top: 25
                        ),
                        child: SvgPicture.asset(
                            'assets/star.svg',
                            height: 40
                        )
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            bottom: 20
                        ),
                        child: Text(
                            "${sudoku.solvedLevels}/${sudoku.totalLevels}",
                            style: TextStyle(
                                fontSize: 30,
                                color: Colors.black,
                            )
                        )
                    )
                ]
            )
        );
    }

    sudokuGrid(Grid sudoku) {
        return Container(
            height: 250,
            width: 250,
            child: Stack(
                children: [
                    GestureDetector(
                        onTap: () {
                            setState(() {
                                sudoku.showThemes = true;
                            });
                        },
                        onVerticalDragEnd: (dragEndDetails) {
                            setState(() {
                                sudoku.showThemes = true;
                            });
                        },
                        child: Card(
                            shape: RoundedRectangleBorder(
                                side: BorderSide(width: 3, color: Color(0xFF2FB898)),
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: GridView.count(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                crossAxisCount: sudoku.size,
                                children: getSudokuBoard(sudoku)
                            )
                        )
                    ),
                    Visibility(
                        visible: sudoku.showThemes,
                        child: GestureDetector(
                            onTap: () {
                                setState(() {
                                    sudoku.showThemes = false;
                                });
                            },
                            onVerticalDragEnd: (dragEndDetails) {
                                setState(() {
                                    sudoku.showThemes = false;
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
                                    children: getThemes()
                                )
                            )
                        )
                    )
                ]
            )
        );
    }

    sudokuTrailingText(Grid sudoku) {
        return Padding(
            padding: EdgeInsets.only(
                top: 10
            ),
            child: Text(
                sudoku.showThemes ? 'Select Theme' : '${sudoku.size} X ${sudoku.size}',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontStyle: FontStyle.italic
                )
            )
        );
    }

    sudokuLevelsCard(Grid sudoku) {
        return Visibility(
            visible: sudoku.showLevels,
            child: Center(
                child: Card(
                    shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                    child: TextButton(
                        onPressed: () { },
                        style: TextButton.styleFrom(
                            enableFeedback: false,
                            splashFactory: NoSplash.splashFactory
                        ),
                        child: Container(
                            width: 300,
                            child: Column(
                                children: [
                                    TextButton(
                                        onPressed: () {
                                            setState(() {
                                                levels.hideDetails();
                                                sudoku.showLevels = false;
                                            });
                                        },
                                        style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero
                                        ),
                                        child: Column(
                                            children: [
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 10,
                                                        top: 13
                                                    ),
                                                    child: SvgPicture.asset(
                                                        'assets/star.svg',
                                                        height: 40
                                                    )
                                                ),
                                                Text(
                                                    "${sudoku.solvedLevels}/${sudoku.totalLevels}",
                                                    style: TextStyle(
                                                        fontSize: 30,
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.w500
                                                    )
                                                )
                                            ]
                                        )
                                    ),
                                    sudokuLevels(sudoku)
                                ]
                            )
                        )
                    )
                )
            )
        );
    }

    sudokuLevels(Grid sudoku) {
        return Expanded(
            child: Padding(
                padding: EdgeInsets.all(20),
                child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: sudoku.levelsTime.length,
                    separatorBuilder: (BuildContext context, int index) => SizedBox(height: 10), 
                    itemBuilder: (BuildContext context, int index) {
                        return Card(
                            color: Color(0xFF54E6C4),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: TextButton(
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.all(0)
                                ),
                                onPressed: sudoku.expandedLevelIdx == index ? () {
                                    print("SELECTED THEME: " + sudoku.selectedLevelThemeIdx.toString());
                                    // Navigate to Game Screen
                                } : ()  { 
                                    setState(() {
                                        sudoku.expandedLevelIdx = index;
                                        sudoku.selectedLevelThemeIdx = 0;
                                    });
                                },
                                child: Container(
                                    height: 50,
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                            sudokuLevelLabel(sudoku, index),
                                            sudoku.expandedLevelIdx == index ? sudokuLevelThemes(sudoku) : sudokuLevelTime(sudoku, index)
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

    getThemes() {
        List<Widget> themes = [];

        for (int i = 0; i < THEMES.length; i++) {
            int idx = 1 + Random().nextInt(THEMES.length);

            themes.add(
                Padding(
                    padding: EdgeInsets.all(15),
                    child: Container(
                        child: SvgPicture.asset(
                            'assets/categories/${THEMES[i]}/$idx.svg',
                            height: 40
                        )
                    )
                )
            );
        }

        return themes;
    }

    sudokuLevelThemes(Grid sudoku) {
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
                            children: getLevelThemes()
                        ),
                        onSelectedItemChanged: (index) {
                            setState(() {
                                sudoku.selectedLevelThemeIdx = index;
                            });
                        }
                    )
                )
            )
        );
    }

    sudokuLevelLabel(Grid sudoku, int index) {
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

    sudokuLevelTime(Grid sudoku, int index) {
        return Row(
            children: [
                Text(
                    getDurationInTime(sudoku.levelsTime[index]),
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    )
                ),
                SizedBox(width: 10),
                SvgPicture.asset(
                    'assets/time.svg',
                    height: 20
                )
            ]
        );
    }

    getLevelThemes() {
        List<Widget> themes = [];

        for (int i = 0; i < THEMES.length; i++) {
            int idx = 1 + Random().nextInt(THEMES.length);

            themes.add(
                RotatedBox(
                    quarterTurns: 1,
                    child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Container(
                            child: SvgPicture.asset(
                                'assets/categories/${THEMES[i]}/$idx.svg',
                                height: 40
                            )
                        )
                    )
                )
            );
        }

        return themes;
    }

    getSudokuBoard(Grid sudoku) {
        String theme = THEMES[Random().nextInt(THEMES.length)];

        List<Container> cells = [];

        for (int i = 0; i < sudoku.size; i++) {
            for (int j = 0; j < sudoku.size; j++) {
                cells.add(
                    Container(
                        height: 40,
                        child: Center(
                            child: Padding(
                                padding: EdgeInsets.all(5),
                                child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: sudoku.cells[i][j] == 0 ? Text('') : SvgPicture.asset(
                                        'assets/categories/$theme/${sudoku.cells[i][j]}.svg',
                                        height: 40
                                    )
                                )
                            )
                        ),
                        decoration: BoxDecoration(
                            color: Colors.white,
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
                );
            }
        }

        return cells;
    }

    isCorner(int row, int col, Grid sudoku) {
        return (row == 0 && col == 0) || (row == 0 && col == sudoku.size - 1) ||
            (row == sudoku.size - 1 && col == 0) || (row == sudoku.size - 1 && col == sudoku.size - 1);
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
                       LaunchReview.launch(androidAppId: "com.zirconworks.themedsudoku")
                    },
                    child: Center(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                                Text(
                                    'Rate us',
                                    style: TextStyle(
                                        fontSize: 25,
                                        color: Color(0xFF2FB898),
                                        fontWeight: FontWeight.bold
                                    )
                                ),
                                SvgPicture.asset(
                                    'assets/like.svg',
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