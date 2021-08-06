import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:launch_review/launch_review.dart';
import 'package:themedsudoku/AppTheme.dart';
import 'package:themedsudoku/sudoku.dart';
import 'package:carousel_slider/carousel_slider.dart';

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

        // AdManager.initGoogleMobileAds();
    }

	@override
    Widget build(BuildContext context) {
        Grid grid = Grid(size: 4);
        // grid.generate(30);
        // print(grid);
        // grid.clearCells(50);
        // print(grid);
        // grid.isSolutionAmbiguous();
        grid.generate(8);
        grid.cells[3][3] = 3;
        print(grid);
        print(grid.isSudokuFilled());
        print("VALID ${grid.isValidSolution()}");

        return Scaffold(
            body: Container(
                decoration: BoxDecoration(
                    color: AppTheme.MAIN_COLOR
                ),
                child: Column(
                    children: [
                        Text(
                            "SUDOKU",
                            style: TextStyle(
                                fontSize: 70
                            )
                        ),
                        Expanded(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                    CarouselSlider(
                                    options: CarouselOptions(height: MediaQuery.of(context).size.height - 300),
                                    items: [1,2,3,4,5].map((i) {
                                        return Column(
                                            children: [
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 10
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
                                                        "20/30",
                                                        style: TextStyle(
                                                            fontSize: 35
                                                        )
                                                    )
                                                ),
                                                Container(
                                                    height: 300,
                                                    child: Card(
                                                        shape: RoundedRectangleBorder(
                                                            side: BorderSide(width: 3, color: Color(0xFF2FB898)),
                                                            borderRadius: BorderRadius.circular(10)
                                                        ),
                                                        child: GridView.builder(
                                                            scrollDirection: Axis.horizontal,
                                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                                crossAxisCount: grid.size,
                                                                childAspectRatio: 1
                                                            ),
                                                            shrinkWrap: true,
                                                            itemCount: grid.size * grid.size,
                                                            itemBuilder: (BuildContext context, int index) {
                                                                return Container(
                                                                    height: 5,
                                                                    width: 5,
                                                                    child: Center(
                                                                        child: FittedBox(
                                                                            fit: BoxFit.scaleDown,
                                                                            child: Padding(
                                                                                padding: EdgeInsets.all(5),
                                                                                child: Text(
                                                                                    (index + 1).toString(),
                                                                                    style: TextStyle(
                                                                                        fontSize: 35
                                                                                    )
                                                                                )
                                                                            )
                                                                        )
                                                                    ),
                                                                    decoration: BoxDecoration(
                                                                        color: Colors.white,
                                                                        shape: BoxShape.rectangle,
                                                                        borderRadius: BorderRadius.only(
                                                                            topLeft: Radius.circular(index == 0 ? 10 : 0),
                                                                            topRight: Radius.circular(index == grid.size * grid.size - grid.size ? 10 : 0),
                                                                            bottomLeft: Radius.circular(index == grid.size - 1 ? 10 : 0),
                                                                            bottomRight: Radius.circular(index == grid.size * grid.size - 1 ? 10 : 0),
                                                                        ),
                                                                        border: Border.all(color: Color(0xFF2FB898))
                                                                    )
                                                                );
                                                            })
                                                        )
                                                    )
                                                ]
                                            );
                                        }).toList(),
                                    ),
                                    ButtonCard(
                                        height: 60,
                                        width: MediaQuery.of(context).size.width / 2,
                                        cardContent: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                                Text(
                                                    'Rate us',
                                                    style: TextStyle(
                                                        fontSize: 25,
                                                        color: AppTheme.MAIN_COLOR
                                                    )
                                                ),
                                                SvgPicture.asset(
                                                    'assets/like.svg',
                                                    height: 40
                                                )
                                            ]
                                        ),
                                        callback: () => LaunchReview.launch(androidAppId: "com.zirconworks.themedsudoku")
                                    )
                                ]
                            )
                        )
                    ]
                )
            )
        );
    }
}

class ButtonCard extends StatelessWidget {
    final double height;
    final double width;
    final Widget cardContent;
    final Function? screen;
    final Function? callback;
    
    ButtonCard({required this.height, required this.width, required this.cardContent, this.screen, this.callback});

    @override
    Widget build(BuildContext context) {
        return Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)
            ),
            child: Container(
                width: width,
                height: height,
                child: TextButton(
                    onPressed: () => {
                        screen != null ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => screen!()
                            )
                        ) : callback!()
                    },
                    child: Center(
                        child: cardContent
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