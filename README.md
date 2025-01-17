# PRNGs in 6502 assembly

This repository is a collection of my implementations of various PRNGs
in 6502 assembly (using [ca65][] from the [cc65][] suite).

[ca65]: https://cc65.github.io/doc/ca65.html
[cc65]: https://cc65.github.io/

Currently included:

- [JSF](/jsf/) : Jenkins Small Fast
- [Xorshift](/xorshift/)

Of these, I currently believe that JSF is the best choice for most
relevant purposes, but as it depends on your use case, you will have to
make your own choices.

## Related non-PRNG algorithms

In addition to the actual PRNGs, some other [related](/related/)
algorithms are also included. In particular ones that are useful but can
be a bit tricky to get right, such as shuffling a list or picking a
random number within a given range in an unbiased way.
