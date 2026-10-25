import '../datasources/volcano_remote_datasource.dart';
import '../models/volcano_model.dart';

class VolcanoRepository {
  final VolcanoRemoteDataSource remoteDataSource;

  VolcanoRepository({VolcanoRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? VolcanoRemoteDataSource();

  Future<VolcanoListResponse> getVolcanoList({
    ActivityLevel? level,
    String? search,
    bool forceRefresh = false,
  }) {
    return remoteDataSource.getVolcanoList(
      level: level?.code,
      search: search,
      forceRefresh: forceRefresh,
    );
  }

  Future<VolcanoDetailResponse> getVolcanoDetail(
    String volcanoId, {
    bool forceRefresh = false,
  }) {
    return remoteDataSource.getVolcanoDetail(
      volcanoId,
      forceRefresh: forceRefresh,
    );
  }
}
