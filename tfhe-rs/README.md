# CPA<sup>D</sup> key recovery attack on TFHE-rs

Attack implementations against TFHE-rs:

A slightly modified copy of the attack proof of concept against TFHE-rs presented in Section 5 of the paper [*Attacks Against the INDCPA-D Security of Exact FHE Schemes*](https://eprint.iacr.org/2024/127)

To collect decryption failures run:
```bash
$ cargo run --release > ../failures.out
```

To plot the resulting graph:
```bash
$ python mainplot.py failures.out
```
