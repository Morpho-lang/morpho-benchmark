# Problems

This folder contains a few selected problems intended to reproduce typical morpho use cases. Shape-optimization problems use [optimize4](https://github.com/Morpho-lang/morpho-optimize4):

    morphopm install optimize4

* Adhesion - Elastic sphere adhering to a plane (PGD, equality contact on a growing attach set).
* ImplicitMesh - Generation of a toroidal mesh.
* MeshGen - Creation of a square mesh.
* RelaxCube - Area at fixed volume on a refined cube (PGD). Distinct from Cube, which uses SQP.
* Tactoid - Coupled mesh + director tactoid (SQP).
* Filament - Elastic filament on a sphere (penalty method, fixed top vertex).
* Cube - Area at fixed volume, in-memory cube, five refines, then one SQP.
* Qtensor / QTensorTyped - Landau + anchoring + GradSq on a disk (L-BFGS, always `W` steps). Typed kernels vs untyped.
* LCECone - LCE azimuthal cone (`AreaIntegral` of `cgtensor()`) (L-BFGS).

```
python3 tools/benchmark.py problems
python3 tools/benchmark.py problems/Cube
python3 tools/benchmark.py -w 4 problems/Qtensor
python3 tools/benchmark.py -w sweep problems/Cube
```
