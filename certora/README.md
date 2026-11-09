# ArithmeticLib.mulDiv verification

The proof checks [`ArithmeticLib.mulDiv`](../src/morpho-chainlink/libraries/ArithmeticLib.sol): it reverts exactly when the denominator is zero or the exact quotient is at least `2^256`; otherwise it returns `floor(x * y / denominator)`.

## Proof structure

- [`MulDivLemmas.spec`](specs/MulDivLemmas.spec) checks block correctness, non-reversion, and supporting arithmetic lemmas.
- [`BitsLemmas.spec`](specs/BitsLemmas.spec) checks powers of two, the inverse seed, and disjoint-digit OR with precise bitwise operations.
- [`MulDivEquivSteps.spec`](specs/MulDivEquivSteps.spec) checks that the split implementation matches the real library.
- [`MulDivSteps.spec`](specs/MulDivSteps.spec) composes the checked blocks into the exact revert and value properties.

All 28 rules must pass, including every supporting lemma and non-reversion rule; no arithmetic axioms remain.

## Running checks

Install the `certora-cli` package with `pip install certora-cli`.
To verify a spec, pass its configuration file in [`certora/confs`](confs) to `certoraRun`.
This requires a valid Certora key in the `CERTORAKEY` environment variable, Java 21, and `solc-0.8.28`.
Additional arguments can select a specific rule.
For example, from the repository root:

```sh
certoraRun certora/confs/MulDivEquivSteps.conf --rule mulDivStepsEquivalent
```
