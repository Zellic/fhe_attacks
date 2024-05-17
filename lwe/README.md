# CPA<sup>D</sup> key recovery attack on LWE

Sage implementation of the attack described in section 3 of the paper [*On the practical CPAD security of “exact” and threshold FHE schemes and libraries*](https://eprint.iacr.org/2024/116). Slightly improved by not discarding the absolute value of errors with a different sign.

To run the attack:
```python
sage: attach("binary_attack.sage")
sage: s = lwe.keygen()
sage: s_recovered = binary_attack(s)
sage: s_recovered == s
True
```