# ArithmeticLib.mulDiv verification

The proof checks `ArithmeticLib.mulDiv` in [`ArithmeticLib.sol`](../src/morpho-chainlink/libraries/ArithmeticLib.sol): it reverts exactly when the denominator is zero or the exact quotient is at least `2^256`; otherwise it returns `floor(x * y / denominator)`.
It does not specify the revert payload.

## Proof structure

[`MulDivHarness.sol`](helpers/MulDivHarness.sol) calls the real library and exposes an implementation split into product, subtraction, powers-of-two, shift, inverse, and final-product blocks.
The split implementation uses the same `MathOverflowedMulDiv()` error as the library.

- [`MulDivSummary.spec`](specs/MulDivSummary.spec) checks the unsummarized `stepsEquivalent` rule and the product, subtraction, six fixed-precision Newton updates, shift block, shift arithmetic, and final-product rules.
  It also proves modular normalization, divisibility of products, and modular inverse cancellation using explicit integer division witnesses.
- [`MulDivSummaryBits.spec`](specs/MulDivSummaryBits.spec) checks the twos, flipped-twos power-of-two fact, inverse seed, and disjoint-digit OR identity using precise bitwise operations.
- [`MulDivSummarySteps.spec`](specs/MulDivSummarySteps.spec) composes the separately checked blocks in `stepsReverts` and `stepsValue`.

The final result is `stepsEquivalent` + `stepsReverts` + `stepsValue`, with every supporting rule cited by a summary.
All 21 rules must pass; a composition result alone does not establish soundness of its supporting summaries.

## Arithmetic lemmas

No arithmetic axioms remain.
The `modularPolynomial`, `divisibleProducts`, and `cancelModularInverse` helpers cite the standalone `modular_polynomial`, `divisible_products`, and `cancel_modular_inverse` rules in `MulDivSummary.spec`.
The main conf runs each arithmetic rule as a separate job in CI.
Modular normalization and inverse cancellation are specialized to the word modulus `B = 2^256` used by every call site.
Divisibility of products is proved for every positive modulus.
The final revert and value properties are unchanged.

## Running checks

From the repository root, with Java 21, `certora-cli`, and `solc-0.8.28` installed:

```sh
certoraRun certora/confs/MulDivSummary.conf
certoraRun certora/confs/MulDivSummaryBits.conf
certoraRun certora/confs/MulDivSummarySteps.conf
```

Set `CERTORAKEY` for cloud verification.
Add `--compilation_steps_only` to check compilation and CVL typechecking without submitting a proof.
The GitHub Actions workflow runs each conf independently and checks JSON and CVL formatting.
