# other

Interesting problems used for language comparison or scientific kernels. Several are written as scalar, allocation-free loops (useful for partial evaluation / `-O`); those kernels are sized for about 1s unoptimized.

Python, Lua, and Wren ports use the same algorithm and iteration count as morpho. DeltaBlue has no Lua port (it is a large class hierarchy already covered by Python and Wren).

* DeltaBlue is a one-way constraint solver, often used as a benchmark for dynamic languages.
* Fibonacci is a recursive Fibonacci number generator.
* Ising is a Monte Carlo simulation of the 2D Ising model.
* RungeKutta integrates a 3-body gravitational system with fourth-order Runge-Kutta.
* GaussKronrod integrates `1/(1+x^2)` with the Gauss-Kronrod 7/15 quadrature rule.
* Raytrace casts rays at a sphere and shades the intersection.
* IterativeMap iterates the Mandelbrot map `z -> z^2+c` until the orbit escapes or hits the iteration limit.
