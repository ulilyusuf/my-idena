import 'dart:async';
import 'package:my_idena/pages/screens/validation_session_screen.dart';

import 'package:flutter/material.dart';
import 'package:my_idena/beans/rpc/dna_getBalance_response.dart';
import 'package:my_idena/beans/rpc/flip_shortHashes_response.dart';
import 'package:my_idena/beans/rpc/httpService.dart';
import 'package:my_idena/beans/validation,_session_infos.dart';
import 'package:my_idena/main.dart';
import 'package:my_idena/utils/app_localizations.dart';
import 'package:my_idena/utils/epoch_period.dart' as EpochPeriod;
import 'package:my_idena/main.dart';

import 'package:my_idena/myIdena_app/myIdena_app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

DnaGetBalanceResponse dnaGetBalanceResponse;
HttpService httpService = HttpService();
ValidationSessionInfo validationSessionInfo;
bool launchLongSession;

FlipShortHashesResponse flipShortHashesResponse;

class ValidationListView extends StatefulWidget {
  const ValidationListView(
      {Key key, this.mainScreenAnimationController, this.mainScreenAnimation})
      : super(key: key);

  final AnimationController mainScreenAnimationController;
  final Animation<dynamic> mainScreenAnimation;

  @override
  _ValidationListViewState createState() => _ValidationListViewState();
}

class _ValidationListViewState extends State<ValidationListView>
    with TickerProviderStateMixin {
  AnimationController animationController;
  AnimationController controllerChrono;

  String get timerString {
    Duration duration = controllerChrono.duration * controllerChrono.value;
    return '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  List selectionFlipList = new List();
  int index = 0;

  SharedPreferences sharedPreferences;
  bool simulationMode;

  void getSimulationMode() async {
    simulationMode = true;
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      if (sharedPreferences.getBool("simulation_mode") != null) {
        simulationMode = sharedPreferences.getBool("simulation_mode");
      }
    });
  }

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    super.initState();

    getSimulationMode();

    launchLongSession = true;
    if (simulationMode) {
      if (launchLongSession == true) {
        dnaAll.dnaGetEpochResponse.result.currentPeriod =
            EpochPeriod.LongSession;
      } else {
        dnaAll.dnaGetEpochResponse.result.currentPeriod =
            EpochPeriod.ShortSession;
      }
    }

    // Init choice
    int nbFlips;
    if (dnaAll.dnaGetEpochResponse.result.currentPeriod ==
        EpochPeriod.ShortSession) {
      nbFlips = 7;
      controllerChrono = AnimationController(
          vsync: this,
          duration: Duration(
              seconds: dnaAll
                  .dnaCeremonyIntervalsResponse.result.shortSessionDuration));
    }
    if (dnaAll.dnaGetEpochResponse.result.currentPeriod ==
        EpochPeriod.LongSession) {
      nbFlips = 14;
      controllerChrono = AnimationController(
          vsync: this,
          duration: Duration(
              seconds: dnaAll
                  .dnaCeremonyIntervalsResponse.result.longSessionDuration));
    }

    for (int i = 0; i < nbFlips; i++) {
      selectionFlipList.add(0);
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    controllerChrono.dispose();
    super.dispose();
  }

  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );
  void pageChanged(int index) {
    setState(() {
      index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.mainScreenAnimationController,
      builder: (BuildContext context, Widget child) {
        return Column(
          children: <Widget>[
            SizedBox(height: 30),
            FadeTransition(
              opacity: widget.mainScreenAnimation,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - widget.mainScreenAnimation.value), 0.0),
                child: Container(
                  height: 350,
                  width: 1000,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                        top: 0, bottom: 0, right: 16, left: 16),
                    itemCount: selectionFlipList.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      final int count = selectionFlipList.length > 25
                          ? 30
                          : selectionFlipList.length;
                      final Animation<double> animation =
                          Tween<double>(begin: 0.0, end: 1.0).animate(
                              CurvedAnimation(
                                  parent: animationController,
                                  curve: Interval((1 / count) * index, 1.0,
                                      curve: Curves.fastOutSlowIn)));
                      animationController.forward();
                      return AnimatedBuilder(
                        animation: animationController,
                        builder: (BuildContext context, Widget child) {
                          return FutureBuilder(
                              // TODO: Short/Long
                              future: getValidationSessionInfo(
                                  dnaAll
                                      .dnaGetEpochResponse.result.currentPeriod,
                                  validationSessionInfo),
                              builder: (BuildContext context,
                                  AsyncSnapshot<ValidationSessionInfo>
                                      snapshot) {
                                if (snapshot.hasData) {
                                  validationSessionInfo = snapshot.data;
                                  if (validationSessionInfo == null) {
                                    return Text("");
                                  } else {
                                    if (validationSessionInfo
                                            .listSessionValidationFlip ==
                                        null) {
                                      return Text("");
                                    } else {
                                      List<ValidationSessionInfoFlips>
                                          listSessionValidationFlip =
                                          validationSessionInfo
                                              .listSessionValidationFlip;
                                      shortSessionCharged = true;
                                      return FadeTransition(
                                        opacity: animation,
                                        child: Transform(
                                          transform: Matrix4.translationValues(
                                              100 * (1.0 - animation.value),
                                              0.0,
                                              0.0),
                                          child: SizedBox(
                                            width: 400,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  decoration: selectionFlipList[
                                                              index] ==
                                                          1
                                                      ? new BoxDecoration(
                                                          color: Colors.green,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                          border: new Border
                                                                  .all(
                                                              color:
                                                                  Colors.green,
                                                              width: 5))
                                                      : new BoxDecoration(
                                                          border:
                                                              new Border
                                                                      .all(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          255,
                                                                          255,
                                                                          255,
                                                                          0),
                                                                  width: 5)),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        selectionFlipList[
                                                            index] = 1;
                                                      });
                                                    },
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Image(
                                                            image: ResizeImage(
                                                                MemoryImage(
                                                                    listSessionValidationFlip[index]
                                                                            .listImagesLeft[
                                                                        0]),
                                                                height: ((MediaQuery.of(context).size.height -
                                                                            350) ~/
                                                                        4)
                                                                    .toInt())),
                                                        Image(
                                                            image: ResizeImage(
                                                                MemoryImage(
                                                                    listSessionValidationFlip[index]
                                                                            .listImagesLeft[
                                                                        1]),
                                                                height: ((MediaQuery.of(context).size.height -
                                                                            350) ~/
                                                                        4)
                                                                    .toInt())),
                                                        Image(
                                                            image: ResizeImage(
                                                                MemoryImage(
                                                                    listSessionValidationFlip[index]
                                                                            .listImagesLeft[
                                                                        2]),
                                                                height: ((MediaQuery.of(context).size.height -
                                                                            350) ~/
                                                                        4)
                                                                    .toInt())),
                                                        Image(
                                                            image: ResizeImage(
                                                                MemoryImage(
                                                                    listSessionValidationFlip[index]
                                                                            .listImagesLeft[
                                                                        3]),
                                                                height: ((MediaQuery.of(context).size.height -
                                                                            350) ~/
                                                                        4)
                                                                    .toInt())),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                    child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    CircleAvatar(
                                                      radius: 30,
                                                      child: Text(
                                                        (index +
                                                                    1)
                                                                .toString() +
                                                            "/" +
                                                            listSessionValidationFlip
                                                                .length
                                                                .toString(),
                                                        style: TextStyle(
                                                            fontFamily:
                                                                MyIdenaAppTheme
                                                                    .fontName,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 20,
                                                            letterSpacing: -0.1,
                                                            color:
                                                                MyIdenaAppTheme
                                                                    .darkText),
                                                      ),
                                                      foregroundColor:
                                                          Colors.red,
                                                    )
                                                  ],
                                                )),
                                                Container(
                                                  decoration: selectionFlipList[
                                                              index] ==
                                                          2
                                                      ? new BoxDecoration(
                                                          color: Colors.green,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                          border: new Border
                                                                  .all(
                                                              color:
                                                                  Colors.green,
                                                              width: 5))
                                                      : new BoxDecoration(
                                                          border:
                                                              new Border
                                                                      .all(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          255,
                                                                          255,
                                                                          255,
                                                                          0),
                                                                  width: 5)),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        selectionFlipList[
                                                            index] = 2;
                                                      });
                                                    },
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Image(
                                                            image: ResizeImage(
                                                                MemoryImage(
                                                                    listSessionValidationFlip[index]
                                                                            .listImagesRight[
                                                                        0]),
                                                                height: ((MediaQuery.of(context).size.height -
                                                                            350) ~/
                                                                        4)
                                                                    .toInt())),
                                                        Image(
                                                            image: ResizeImage(
                                                                MemoryImage(
                                                                    listSessionValidationFlip[index]
                                                                            .listImagesRight[
                                                                        1]),
                                                                height: ((MediaQuery.of(context).size.height -
                                                                            350) ~/
                                                                        4)
                                                                    .toInt())),
                                                        Image(
                                                            image: ResizeImage(
                                                                MemoryImage(
                                                                    listSessionValidationFlip[index]
                                                                            .listImagesRight[
                                                                        2]),
                                                                height: ((MediaQuery.of(context).size.height -
                                                                            350) ~/
                                                                        4)
                                                                    .toInt())),
                                                        Image(
                                                            image: ResizeImage(
                                                                MemoryImage(
                                                                    listSessionValidationFlip[index]
                                                                            .listImagesRight[
                                                                        3]),
                                                                height: ((MediaQuery.of(context).size.height -
                                                                            350) ~/
                                                                        4)
                                                                    .toInt())),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                } else {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }
                              });
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(child: getChrono()),
            Container(child: getStartCheckingKeywordsButton()),
          ],
        );
      },
    );
  }

  Widget getStartCheckingKeywordsButton() {
    if (dnaAll.dnaGetEpochResponse.result.currentPeriod ==
        EpochPeriod.LongSession) {
      for (int i = 0; i < selectionFlipList.length; i++) {
        if (selectionFlipList[i] == 0) {
          return SizedBox();
        }
      }

      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          RaisedButton(
            elevation: 5.0,
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => SimpleDialog(
                        contentPadding: EdgeInsets.zero,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  AppLocalizations.of(context).translate(
                                      "Your answers are not yet submitted"),
                                  style: TextStyle(
                                      fontFamily: MyIdenaAppTheme.fontName,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: -0.1,
                                      color: MyIdenaAppTheme.darkText),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  AppLocalizations.of(context).translate(
                                      "Please qualify the keywords relevance and submit the answers."),
                                  style: TextStyle(
                                      fontFamily: MyIdenaAppTheme.fontName,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      letterSpacing: -0.1,
                                      color: MyIdenaAppTheme.darkText),
                                ),
                                Text(
                                  AppLocalizations.of(context).translate(
                                      "The flips with relevant keywords will be penalized"),
                                  style: TextStyle(
                                      fontFamily: MyIdenaAppTheme.fontName,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      letterSpacing: -0.1,
                                      color: MyIdenaAppTheme.darkText),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                RaisedButton(
                                  elevation: 5.0,
                                  onPressed: () {
                                    // TODO
                                  },
                                  padding: EdgeInsets.all(5.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                  color: Colors.white,
                                  child: Text(
                                      AppLocalizations.of(context)
                                          .translate("Ok, I understand"),
                                      style: TextStyle(
                                        color: Colors.black,
                                        letterSpacing: 1.5,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'OpenSans',
                                      )),
                                ),
                              ],
                            ),
                          )
                        ],
                      ));
            },
            padding: EdgeInsets.all(5.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            color: Colors.white,
            child: Text(
                AppLocalizations.of(context)
                    .translate("Start checking keywords"),
                style: TextStyle(
                  color: Colors.black,
                  letterSpacing: 1.5,
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'OpenSans',
                )),
          ),
        ],
      );
    } else {
      return SizedBox();
    }
  }

  Widget getChrono() {
    /*controllerChrono.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        if (dnaAll.dnaGetEpochResponse.result.currentPeriod ==
            EpochPeriod.ShortSession) {
          launchLongSession = true;
          setState(() {
          ValidationSessionScreen(animationController: animationController);
            
          });
        }
      }
    });*/
    controllerChrono.reverse(
        from: controllerChrono.value == 0.0 ? 1.0 : controllerChrono.value);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        AnimatedBuilder(
            animation: controllerChrono,
            builder: (BuildContext context, Widget child) {
              return Text(
                timerString,
                style: TextStyle(
                  fontFamily: MyIdenaAppTheme.fontName,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  letterSpacing: -0.1,
                  color: Colors.red,
                ),
              );
            }),
      ],
    );
  }
}
