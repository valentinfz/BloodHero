import '../entities/center_detail_entity.dart';
import '../entities/center_entity.dart';

abstract class CentersRepository {
  /// Obtiene la lista de todos los centros de donación.
  Future<List<CenterEntity>> getCenters();

  /// Obtiene el detalle (horarios, servicios) de un centro específico.
  Future<CenterDetailEntity> getCenterDetails(String centerIdentifier);
}
