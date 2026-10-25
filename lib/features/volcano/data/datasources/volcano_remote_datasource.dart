import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/volcano_model.dart';

class VolcanoRemoteDataSource {
  final ApiClient client;

  VolcanoRemoteDataSource({ApiClient? client}) : client = client ?? ApiClient();

  Future<VolcanoListResponse> getVolcanoList({
    String? level,
    String? search,
    bool forceRefresh = false,
  }) async {
    final queryParams = <String, dynamic>{};
    if (level != null) queryParams['level'] = level;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (forceRefresh) queryParams['force_refresh'] = true;

    final response = await client.dio.get(
      ApiConstants.volcanoesEndpoint,
      queryParameters: queryParams,
    );

    return VolcanoListResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<VolcanoDetailResponse> getVolcanoDetail(
    String volcanoId, {
    bool forceRefresh = false,
  }) async {
    final response = await client.dio.get(
      '${ApiConstants.volcanoesEndpoint}/$volcanoId',
      queryParameters: {
        if (forceRefresh) 'force_refresh': true,
      },
    );

    return VolcanoDetailResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
