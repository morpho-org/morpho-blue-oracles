# ArithmeticLib.mulDiv verification

The proof checks [`ArithmeticLib.mulDiv`](../src/morpho-chainlink/libraries/ArithmeticLib.sol): it reverts exactly when the denominator is zero or the exact quotient is at least `2^256`; otherwise it returns `floor(x * y / denominator)`.

## Proof structure

- [`MulDivHarness.sol`](harnesses/MulDivHarness.sol) puts the `mulDiv` function in a contract, and add `mulDivSteps` which splits the implementation of `mulDiv` into a sequence of steps.
- [`MulDivEquivSteps.spec`](specs/MulDivEquivSteps.spec) checks that the split implementation `mulDivSteps` matches the actual `mulDiv` implementation.
- [`MulDivSteps.spec`](specs/MulDivSteps.spec) proves the exact revert and value properties.
  It relies on arithmetic lemmas and summaries proved in [`MulDivLemmas.spec`](specs/MulDivLemmas.spec) and [`BitsLemmas.spec`](specs/BitsLemmas.spec) (needed for the exact bitwise operations).

## Running checks

Install the `certora-cli` package with `pip install certora-cli`.
To verify a spec, pass its configuration file in [`certora/confs`](confs) to `certoraRun`.
This requires a valid Certora key in the `CERTORAKEY` environment variable, Java 21, and `solc-0.8.28`.
