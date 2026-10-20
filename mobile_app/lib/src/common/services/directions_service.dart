import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsService {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json';
  static const String _apiKey =
      'AIzaSyAPePrLwHCK8ngZkELSCvETUk-B5FDUvIk'; // From local.properties - in production, load from secure storage

  /// Get driving directions between two points
  static Future<DirectionsResult?> getDirections({
    required LatLng origin,
    required LatLng destination,
    String mode = 'driving',
  }) async {
    try {
      print(
          '🗺️ Getting directions from ${origin.latitude},${origin.longitude} to ${destination.latitude},${destination.longitude}');

      final url = Uri.parse(
          '$_baseUrl?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=$mode&key=$_apiKey');

      print('🔗 Directions API URL: $url');

      final response = await http.get(url);

      print('📡 Directions API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          return DirectionsResult.fromJson(data);
        } else {
          print(
              '❌ Directions API error: ${data['status']} - ${data['error_message'] ?? 'Unknown error'}');
          return null;
        }
      } else {
        print('❌ Directions API HTTP error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Directions API error: $e');
      return null;
    }
  }

  /// Get route polyline points from directions result
  static List<LatLng> getRoutePoints(DirectionsResult directions) {
    final List<LatLng> points = [];

    if (directions.routes.isNotEmpty) {
      final route = directions.routes.first;
      if (route.legs.isNotEmpty) {
        final leg = route.legs.first;
        for (final step in leg.steps) {
          points.addAll(step.polyline.decodedPoints);
        }
      }
    }

    return points;
  }

  /// Get route summary (distance, duration)
  static RouteSummary getRouteSummary(DirectionsResult directions) {
    if (directions.routes.isNotEmpty) {
      final route = directions.routes.first;
      if (route.legs.isNotEmpty) {
        final leg = route.legs.first;
        return RouteSummary(
          distance: leg.distance.value,
          duration: leg.duration.value,
          distanceText: leg.distance.text,
          durationText: leg.duration.text,
        );
      }
    }
    return RouteSummary(
        distance: 0, duration: 0, distanceText: '', durationText: '');
  }
}

class DirectionsResult {
  final String status;
  final List<Route> routes;

  DirectionsResult({
    required this.status,
    required this.routes,
  });

  factory DirectionsResult.fromJson(Map<String, dynamic> json) {
    return DirectionsResult(
      status: json['status'] ?? '',
      routes: (json['routes'] as List<dynamic>?)
              ?.map((route) => Route.fromJson(route))
              .toList() ??
          [],
    );
  }
}

class Route {
  final List<Leg> legs;
  final OverviewPolyline overviewPolyline;

  Route({
    required this.legs,
    required this.overviewPolyline,
  });

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      legs: (json['legs'] as List<dynamic>?)
              ?.map((leg) => Leg.fromJson(leg))
              .toList() ??
          [],
      overviewPolyline:
          OverviewPolyline.fromJson(json['overview_polyline'] ?? {}),
    );
  }
}

class Leg {
  final Distance distance;
  final RouteDuration duration;
  final List<Step> steps;

  Leg({
    required this.distance,
    required this.duration,
    required this.steps,
  });

  factory Leg.fromJson(Map<String, dynamic> json) {
    return Leg(
      distance: Distance.fromJson(json['distance'] ?? {}),
      duration: RouteDuration.fromJson(json['duration'] ?? {}),
      steps: (json['steps'] as List<dynamic>?)
              ?.map((step) => Step.fromJson(step))
              .toList() ??
          [],
    );
  }
}

class Step {
  final Distance distance;
  final RouteDuration duration;
  final PolylineData polyline;

  Step({
    required this.distance,
    required this.duration,
    required this.polyline,
  });

  factory Step.fromJson(Map<String, dynamic> json) {
    return Step(
      distance: Distance.fromJson(json['distance'] ?? {}),
      duration: RouteDuration.fromJson(json['duration'] ?? {}),
      polyline: PolylineData.fromJson(json['polyline'] ?? {}),
    );
  }
}

class Distance {
  final int value;
  final String text;

  Distance({
    required this.value,
    required this.text,
  });

  factory Distance.fromJson(Map<String, dynamic> json) {
    return Distance(
      value: json['value'] ?? 0,
      text: json['text'] ?? '',
    );
  }
}

class RouteDuration {
  final int value;
  final String text;

  RouteDuration({
    required this.value,
    required this.text,
  });

  factory RouteDuration.fromJson(Map<String, dynamic> json) {
    return RouteDuration(
      value: json['value'] ?? 0,
      text: json['text'] ?? '',
    );
  }
}

class PolylineData {
  final String points;

  PolylineData({
    required this.points,
  });

  factory PolylineData.fromJson(Map<String, dynamic> json) {
    return PolylineData(
      points: json['points'] ?? '',
    );
  }

  List<LatLng> get decodedPoints {
    return _decodePolyline(this.points);
  }

  /// Decode polyline string to list of LatLng points
  List<LatLng> _decodePolyline(String polyline) {
    final List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < polyline.length) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }
}

class OverviewPolyline {
  final String points;

  OverviewPolyline({
    required this.points,
  });

  factory OverviewPolyline.fromJson(Map<String, dynamic> json) {
    return OverviewPolyline(
      points: json['points'] ?? '',
    );
  }

  List<LatLng> get decodedPoints {
    return _decodePolyline(this.points);
  }

  /// Decode polyline string to list of LatLng points
  List<LatLng> _decodePolyline(String polyline) {
    final List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < polyline.length) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }
}

class RouteSummary {
  final int distance; // in meters
  final int duration; // in seconds
  final String distanceText;
  final String durationText;

  RouteSummary({
    required this.distance,
    required this.duration,
    required this.distanceText,
    required this.durationText,
  });
}
