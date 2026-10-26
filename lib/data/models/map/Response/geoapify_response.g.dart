// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geoapify_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeoapifyResponse _$GeoapifyResponseFromJson(Map<String, dynamic> json) =>
    GeoapifyResponse(
      features: (json['features'] as List<dynamic>?)
          ?.map((e) => Feature.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GeoapifyResponseToJson(GeoapifyResponse instance) =>
    <String, dynamic>{
      'features': instance.features?.map((e) => e.toJson()).toList(),
    };

Feature _$FeatureFromJson(Map<String, dynamic> json) => Feature(
      properties: json['properties'] == null
          ? null
          : Properties.fromJson(json['properties'] as Map<String, dynamic>),
      geometry: json['geometry'] == null
          ? null
          : Geometry.fromJson(json['geometry'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FeatureToJson(Feature instance) => <String, dynamic>{
      'properties': instance.properties?.toJson(),
      'geometry': instance.geometry?.toJson(),
    };

Geometry _$GeometryFromJson(Map<String, dynamic> json) => Geometry(
      type: json['type'] as String?,
      coordinates: json['coordinates'],
    );

Map<String, dynamic> _$GeometryToJson(Geometry instance) => <String, dynamic>{
      'type': instance.type,
      'coordinates': instance.coordinates,
    };

Properties _$PropertiesFromJson(Map<String, dynamic> json) => Properties(
      formatted: json['formatted'] as String?,
      distance: (json['distance'] as num?)?.toDouble(),
      time: (json['time'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PropertiesToJson(Properties instance) =>
    <String, dynamic>{
      'formatted': instance.formatted,
      'distance': instance.distance,
      'time': instance.time,
    };
