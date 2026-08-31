# Functionals

Morpho-only map kernels (`total` / `gradient` / `fieldgradient`) on realistic meshes and fields. One folder is one hot operation; the runner times the whole process. No optimize4.

These are distilled from the Morpho-core Phase 5 map-load suite. Setup is a constructed mesh (and a randomized Field where needed), not an optimizer warmup.

| Folder | Map |
|--------|-----|
| Area | `Area.gradient` on a refined cube |
| AreaEnclosed | `AreaEnclosed.gradient` on a closed ellipse |
| LinearElasticity | `LinearElasticity.gradient` on a stretched clone of the reference |
| Curvature | `MeanCurvatureSq.gradient` on an implicit sphere, then `EquiElement.gradient` on a stretched disk |
| Landau | `AreaIntegral` of a Landau polynomial (`total`) |
| LandauFieldgrad | chain-rule `fieldgradient` of that Landau integral |
| Jump | `Jump(jumpdn(q)^2).gradient` |
| Nematic | `Nematic.fieldgradient` |
| GradIntegral | `LineIntegral` `fieldgradient` of an integrand that calls `grad()` |

```
python3 tools/benchmark.py functionals
python3 tools/benchmark.py functionals/Landau
python3 tools/benchmark.py -w 4 functionals
python3 tools/benchmark.py -w sweep functionals
```
