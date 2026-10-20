import '../../domain/settings/appearance.dart';
import 'glass/glass_design.dart';
import 'material/material_design.dart';
import 'prism_design.dart';

/// All available styles. Adding a third style = one enum value in
/// [PrismStyleId] + one [PrismDesign] implementation registered here.
const Map<PrismStyleId, PrismDesign> prismDesigns = {
  PrismStyleId.glass: GlassDesign(),
  PrismStyleId.material: MaterialDesign(),
};

PrismDesign designFor(PrismStyleId id) => prismDesigns[id]!;
