///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-01 23:35
///
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:weather/constants/constants.dart';

class WeatherPage extends StatefulWidget {
  @override
  WeatherPageState createState() => WeatherPageState();
}

class WeatherPageState extends State<WeatherPage> {
  static final sectionMargin = const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0);
  static final sectionPadding = const EdgeInsets.all(16.0);
  static final sectionContentWidth =
      Screens.width - sectionMargin.horizontal - sectionPadding.horizontal;

  final _scrollController = ScrollController();

  TextStyle get weekDetailTextStyle => TextStyle(
        fontSize: 10.0,
      );

  WeatherProvider provider = WeatherProvider(province: "上海", city: "上海");
  DateTime today = DateTime.now();
  double weekDetailTransform = 0.0;

  @override
  void initState() {
    provider = WeatherProvider(province: "上海", city: "上海");
    _scrollController.addListener(scrollTransformListener);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      provider.fetchWeather();
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _scrollController
      ..removeListener(scrollTransformListener)
      ..addListener(scrollTransformListener);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _scrollController.removeListener(scrollTransformListener);
    _scrollController.dispose();
    super.dispose();
  }

  void scrollTransformListener() {
    final _transform = math.max(
      0.0,
      math.min(1.0, _scrollController.offset / Screens.height * 2),
    );
    if (_transform != weekDetailTransform) {
      setState(() {
        weekDetailTransform = _transform;
      });
    }
  }

  Widget sectionHeader(context, String title) {
    return Container(
      height: 50.0,
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 8.0),
            width: 3.0,
            height: 12.0,
            color: Colors.white,
          ),
          Expanded(child: Text(title, style: TextStyle(fontSize: 12.0))),
        ],
      ),
    );
  }

  Widget get topBar => Selector<WeatherProvider, String>(
        selector: (_, provider) => provider.city,
        builder: (_, city, __) => Container(
          margin: EdgeInsets.only(top: Screens.topSafeHeight),
          height: 40.0,
          child: Center(
            child: Text(
              city,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                fontFamily: "Lexend Exa",
              ),
            ),
          ),
        ),
      );

  Widget get status => Selector<WeatherProvider, Observe>(
        selector: (_, provider) => provider.observe,
        builder: (_, observe, __) => SizedBox(
          height: 20.0,
          child: Center(
            child: Text(
              observe.weather,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.normal,
                fontSize: 12.0,
              ),
            ),
          ),
        ),
      );

  Widget get temperature => SizedBox.fromSize(
        size: Size.square(Screens.width / 3.5),
        child: Row(
          children: <Widget>[
            Spacer(),
            Selector<WeatherProvider, Observe>(
              selector: (_, provider) => provider.observe,
              builder: (_, observe, __) => Text(
                observe.degree,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 72.0,
                  fontFamily: "Lexend Exa",
                ),
              ),
            ),
            Expanded(
              child: Text(
                "°",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 66.0,
                  fontFamily: "Lexend Exa",
                ),
              ),
            ),
          ],
        ),
      );

  Widget get airCondition => SizedBox(
        height: 50.0,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Screens.width),
              color: Colors.white10,
            ),
            padding: EdgeInsets.symmetric(
              vertical: 6.0,
              horizontal: 16.0,
            ),
            child: Selector<WeatherProvider, Air>(
              selector: (_, provider) => provider.air,
              builder: (_, air, __) => Text(
                "空气${air.aqiName}",
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12.0,
                ),
              ),
            ),
          ),
        ),
      );

  Widget _weekDetailPainter(List<ForecastPerDay> forecasts) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 50.0),
      child: CustomPaint(
        painter: WeekDetailPainter(
          maxDegrees: forecasts.map((f) => f.maxDegree).toList(),
          minDegrees: forecasts.map((f) => f.minDegree).toList(),
        ),
        child: Container(width: Screens.width, height: 100.0),
      ),
    );
  }

  Widget _weekDetailInfo(List<ForecastPerDay> forecasts) {
    return SizedBox(
      height: 80.0,
      child: Row(
        children: List<Widget>.generate(math.max(7, forecasts.length), (index) {
          final _forecast = forecasts.elementAt(index);
          final weekday = DateTime.parse(_forecast.time).weekday;
          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  weekday != today.weekday ? weekdayString[weekday] : '今天',
                  style: weekDetailTextStyle,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  child: Image.asset(
                    "assets/icons/weather/w_${weatherIconsMap[_forecast.dayWeather]}.png",
                    width: Screens.width / forecasts.length / 2,
                  ),
                ),
                Text(
                  _forecast.dayWeather,
                  style: weekDetailTextStyle,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget get weekDetail => Selector<WeatherProvider, List<ForecastPerDay>>(
        selector: (_, provider) => provider.forecastsPerDay,
        builder: (_, forecasts, __) => Container(
          margin: EdgeInsets.symmetric(vertical: 10.0),
          padding: EdgeInsets.only(
            top: Screens.height - Screens.topSafeHeight - 140.0 - Screens.width / 3.5 - 280.0,
          ),
          height: Screens.height - Screens.topSafeHeight - 140.0 - Screens.width / 3.5,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: sectionMargin.left * weekDetailTransform),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white.withOpacity(0.1 * weekDetailTransform),
            ),
            child: Column(children: [_weekDetailPainter(forecasts), _weekDetailInfo(forecasts)]),
          ),
        ),
      );

  Widget _hoursLinePainter(List<ForecastPerHour> forecasts) {
    return Padding(
      padding: EdgeInsets.only(top: 35.0, bottom: 25.0),
      child: CustomPaint(
        painter: HoursDetailPainter(
          degrees: forecasts.map((f) => f.degree).toList(),
        ),
        child: SizedBox(
          width: sectionContentWidth / 6 * forecasts.length,
          height: 50.0,
        ),
      ),
    );
  }

  Widget _hoursInfo(List<ForecastPerHour> forecasts) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: List<Widget>.generate(forecasts.length, (index) {
          final _forecast = forecasts.elementAt(index);
          final _indexHour = today.hour + index;
          final hour = _indexHour - (_indexHour ~/ 24) * 24;
          return SizedBox(
            width: sectionContentWidth / 6,
            height: 70.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  "$hour时",
                  style: TextStyle(fontSize: 12.0),
                ),
                Image.asset(
                  "assets/icons/weather/w_${weatherIconsMap[_forecast.weather]}.png",
                  width: Screens.width / 16,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget get hoursDetail => Selector<WeatherProvider, List<ForecastPerHour>>(
        selector: (_, provider) => provider.forecastsPerHour,
        builder: (_, forecasts, __) => Container(
          margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          height: 240.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.white.withOpacity(0.1),
          ),
          child: Column(
            children: [
              sectionHeader(context, "每小时预报"),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children: <Widget>[_hoursLinePainter(forecasts), _hoursInfo(forecasts)],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _lifeIndexDetailIcon(Fitness fitness) {
    return SizedBox(
      width: 64.0,
      child: Center(
        child: Image.asset(
          "assets/icons/index/${fitness.name}.png",
          width: 36.0,
          height: 36.0,
        ),
      ),
    );
  }

  Widget _lifeIndexDetailName(Fitness fitness) {
    return Text(
      fitness.name,
      style: TextStyle(fontSize: 14.0),
    );
  }

  Widget _lifeIndexDetailInfo(Fitness fitness) {
    return Container(
      margin: EdgeInsets.only(left: 6.0),
      padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        color: Colors.white24,
      ),
      child: Center(
        child: Text(
          fitness.info,
          style: TextStyle(fontSize: 10.0),
        ),
      ),
    );
  }

  Widget _lifeIndexDetailsDetail(Fitness fitness) {
    return Container(
      margin: EdgeInsets.only(right: 10.0),
      child: Text(
        "${fitness.detail.split("。")[0]}。",
        style: TextStyle(
          color: Colors.white70,
          fontSize: 12.0,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _lifeIndexDetail(Fitness fitness) {
    return SizedBox(
      height: 50.0,
      child: Row(
        children: <Widget>[
          _lifeIndexDetailIcon(fitness),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _lifeIndexDetailName(fitness),
                    _lifeIndexDetailInfo(fitness),
                  ],
                ),
                _lifeIndexDetailsDetail(fitness),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget get lifeIndexesDetail => Selector<WeatherProvider, FitnessIndex>(
        selector: (_, provider) => provider.fitnessIndex,
        builder: (_, fitnessIndex, __) {
          final indexes = [
            fitnessIndex.ultraviolet,
            fitnessIndex.sports,
            fitnessIndex.clothes,
            fitnessIndex.carWash,
            fitnessIndex.diffusion,
          ];
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            padding: EdgeInsets.only(bottom: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white.withOpacity(0.1),
            ),
            child: Column(
              children: [
                sectionHeader(context, "生活指数"),
                ListView.separated(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  separatorBuilder: (_, __) => Container(
                    margin: EdgeInsets.only(left: 64.0),
                    child: Divider(),
                  ),
                  itemCount: indexes.length,
                  itemBuilder: (_, index) => _lifeIndexDetail(indexes[index]),
                ),
              ],
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(6, 19, 35, 1.0),
      body: ChangeNotifierProvider(
        create: (_) => provider,
        child: Column(
          children: <Widget>[
            topBar,
            Expanded(
              child: Consumer<WeatherProvider>(
                builder: (_, provider, __) {
                  return AnimatedSwitcher(
                    duration: kTabScrollDuration,
                    child: provider.isFull
                        ? ListView(
                            controller: _scrollController,
                            padding: EdgeInsets.only(bottom: Screens.bottomSafeHeight),
                            children: <Widget>[
                              status,
                              temperature,
                              airCondition,
                              weekDetail,
                              hoursDetail,
                              lifeIndexesDetail,
                            ],
                          )
                        : Center(child: CupertinoActivityIndicator()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
