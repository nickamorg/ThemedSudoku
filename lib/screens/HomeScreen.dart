import 'package:flutter/material.dart';
import 'package:themedsudoku/AppTheme.dart';

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
        return Scaffold(
            body: Container(
                decoration: BoxDecoration(
                    color: AppTheme.MAIN_COLOR
                ),
                child: Padding(
                    padding: EdgeInsets.all(20)   
                )
            )
        );
    }
}

class Home extends StatefulWidget {

	@override
	State createState() => HomeState();
}