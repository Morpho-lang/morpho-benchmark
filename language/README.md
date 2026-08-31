# language

Tests that isolate the cost of individual language features. Each folder is one hot operation; comparator ports use the same algorithm and iteration count. Python, Lua, Ruby, and Wren are included where the feature is like-for-like. Morpho-only features (metafunctions, typed locals, Array, Matrix) have no ports.

Run with:

```
python3 tools/benchmark.py language
python3 tools/benchmark.py -O language
```

The runner times the whole process. Use `-O` to also time morpho with `--eval "import bytecodeoptimizer" -O`.

## Isolates

* Arithmetic - monomorphic integer add
* ArrayLookup - hot Array index (morpho only)
* BoundMethod - stored method / invocation call
* Branch - unpredictable if/else
* Call - plain function call
* ClassInit - object construction
* Closure - upvalue read
* DictLookup - hot dictionary get
* For - for-in over a prebuilt list
* ForIn - nested range for-in with a function call
* InlineCall - tiny `add` in a loop (inlining candidate)
* ListAppend - list append / growth
* ListCreation - small list allocation
* ListLookup - hot list index
* Loop - tight C-style numeric loop
* Matrix - linear solve via Matrix (composite; morpho only)
* Metafunction / MetafunctionArity / MetafunctionMulti - overload dispatch (morpho only)
* MethodCall - Shootout Toggle (dispatch + inheritance)
* MethodLookup - typed receiver method call
* OptionalArgs - call with a default argument
* Pow - power operator
* Property - instance field read
* RangeForIn - `for (i in 1..N)`
* Slice - list slice
* StringConcat - fixed-string concatenation
* TryCatch - empty try around a hot increment
* TupleCreation / TupleLookup - tuple allocation and index
* TypedLocal - typed local + `OP_TYPECHECK` (morpho only)
* Variadic - variadic call
* While - same body as Loop, while instead of C-style for
