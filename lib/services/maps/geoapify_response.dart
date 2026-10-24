import 'package:json_annotation/json_annotation.dart';

part 'geoapify_response.g.dart';

@JsonSerializable(explicitToJson: true)
class GeoapifyResponse {
  @JsonKey(name: 'features')
  final List<Feature>? features;

  GeoapifyResponse({this.features});

  factory GeoapifyResponse.fromJson(Map<String, dynamic> json) =>
      _$GeoapifyResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GeoapifyResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Feature {
  @JsonKey(name: 'properties')
  final Properties? properties;

  @JsonKey(name: 'geometry')
  final Geometry? geometry;

  Feature({
    this.properties,
    this.geometry,
  });

  factory Feature.fromJson(Map<String, dynamic> json) => _$FeatureFromJson(json);

  Map<String, dynamic> toJson() => _$FeatureToJson(this);
}

@JsonSerializable()
class Geometry {
  @JsonKey(name: 'type')
  final String? type;

  @JsonKey(name: 'coordinates')
  final dynamic coordinates;

  Geometry({
    this.type,
    this.coordinates,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) => _$GeometryFromJson(json);

  Map<String, dynamic> toJson() => _$GeometryToJson(this);
}

@JsonSerializable()
class Properties {
  @JsonKey(name: 'formatted')
  final String? formatted;

  @JsonKey(name: 'distance')
  final double? distance;

  @JsonKey(name: 'time')
  final double? time;

  Properties({
    this.formatted,
    this.distance,
    this.time,
  });

  factory Properties.fromJson(Map<String, dynamic> json) =>
      _$PropertiesFromJson(json);

  Map<String, dynamic> toJson() => _$PropertiesToJson(this);
}
