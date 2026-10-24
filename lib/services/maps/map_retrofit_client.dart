import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'geoapify_response.dart';

part 'map_retrofit_client.g.dart';

@RestApi(baseUrl: "https://api.geoapify.com/v1")
abstract class MapRetrofitClient {
  factory MapRetrofitClient(Dio dio, {String baseUrl}) = _MapRetrofitClient;

  @GET("/geocode/autocomplete")
  Future<GeoapifyResponse> searchAddress(
    @Query("text") String text,
    @Query("apiKey") String apiKey,
  );

  @GET("/geocode/reverse")
  Future<GeoapifyResponse> reverseGeocode(
    @Query("lat") double lat,
    @Query("lon") double lon,
    @Query("apiKey") String apiKey,
  );

  @GET("/routing")
  Future<GeoapifyResponse> getRouting(
    @Query("waypoints") String waypoints,
    @Query("mode") String mode,
    @Query("apiKey") String apiKey,
  );
}
