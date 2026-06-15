This folder contains the verification of MorphoChainlinkOracleV2 using CVL, Certora's Verification Language.

# Getting started

Install the `certora-cli` package with `pip install certora-cli`.
The verification requires `solc-0.8.21` and the `CERTORAKEY` environment variable to be set to a valid Certora key.

To prove that every successful deployment has a non-zero scale factor, run from the repository root:

```bash
certoraRun certora/confs/MorphoChainlinkOracleV2.conf --rule scaleFactorCannotBeZero
```
