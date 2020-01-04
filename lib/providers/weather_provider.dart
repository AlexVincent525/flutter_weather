///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-03 17:43
///
import 'package:flutter/material.dart';
import 'package:dartx/dartx.dart';

import 'package:weather/constants/constants.dart';

class WeatherProvider extends ChangeNotifier {
  final String province;
  final String city;
  final String county;

  WeatherProvider({
    @required this.province,
    @required this.city,
    this.county,
  }) : assert(
          province != null && city != null,
          'province or city cannot be null.',
        );

  /// Weather field.
  ///
  /// Fields below were generated by response.
  Air _air;
  Air get air => _air;
  set air(Air value) {
    _air = value;
    notifyListeners();
  }

  List<Alarm> _alarms;
  List<Alarm> get alarms => _alarms;
  set alarms(List<Alarm> value) {
    _alarms = List.from(value);
    notifyListeners();
  }

  List<ForecastPerHour> _forecastsPerHour;
  List<ForecastPerHour> get forecastsPerHour => _forecastsPerHour;
  set forecastsPerHour(List<ForecastPerHour> value) {
    _forecastsPerHour = List.from(value);
    notifyListeners();
  }

  List<ForecastPerDay> _forecastsPerDay;
  List<ForecastPerDay> get forecastsPerDay => _forecastsPerDay;
  set forecastsPerDay(List<ForecastPerDay> value) {
    _forecastsPerDay = List.from(value);
    notifyListeners();
  }

  FitnessIndex _fitnessIndex;
  FitnessIndex get fitnessIndex => _fitnessIndex;
  set fitnessIndex(FitnessIndex value) {
    _fitnessIndex = value;
    notifyListeners();
  }

  Limit _limit;
  Limit get limit => _limit;
  set limit(Limit value) {
    _limit = value;
    notifyListeners();
  }

  Observe _observe;
  Observe get observe => _observe;
  set observe(Observe value) {
    _observe = value;
    notifyListeners();
  }

  List<Rise> _rises;
  List<Rise> get rises => _rises;
  set rises(List<Rise> value) {
    _rises = List.from(value);
    notifyListeners();
  }

  /// Whether fields are all non-null;
  bool get isFull =>
      air != null &&
      alarms != null &&
      forecastsPerHour != null &&
      forecastsPerDay != null &&
      fitnessIndex != null &&
      limit != null &&
      observe != null &&
      rises != null;
  bool get isNotFull => !isFull;

  /// Methods.
  Future fetchWeather() async {
    print("Fetching weather: $province, $city");
    final response = await API.fetch(
      FetchType.get,
      API.weather,
      data: API.weatherRequestQuery(
        province: this.province,
        city: this.city,
        county: this.county,
      ),
    );
    final data = response['data'];

    _air = Air.fromJson(data['air']);
    _alarms = data['alarm'].values.map((alarm) => Alarm.fromJson(alarm)).toList().cast<Alarm>();
    _forecastsPerHour = data['forecast_1h']
        .values
        .map((forecast) => ForecastPerHour.fromJson(forecast))
        .toList()
        .cast<ForecastPerHour>();
    _forecastsPerDay = data['forecast_24h']
        .values
        .map((forecast) => ForecastPerDay.fromJson(forecast))
        .toList()
        .sublist(1, 8)
        .cast<ForecastPerDay>();
    _fitnessIndex = FitnessIndex.fromJson(data['index']);
    _limit = Limit.fromJson(data['limit']);
    _observe = Observe.fromJson(data['observe']);
    _rises = data['rise'].values.map((rise) => Rise.fromJson(rise)).toList().cast<Rise>();

    await Future.delayed(2.seconds);
    notifyListeners();
  }
}
