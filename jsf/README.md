# Jenkins Small Fast

JSF is [a small noncryptographic PRNG][bobj] designed by Bob Jenkins in
2007, who placed it in the public domain.

He did not give it a name, but people seem to follow Doty-Humphrey's
naming convention in [PractRand][], where it was called JSF (Jenkins
Small Fast), so I will do the same. PractRand is also public-domain.

Apparently, it is better studied than other similar PRNGs, and it seems
that [it passes a bunch of statistical tests][meo], up to quite a lot of
output data (as compared to the state size), so it seems to be a fairly
good PRNG even at small sizes.

## Variants

### 32-bit and 64-bit

Jenkins provides several variants of the PRNG, for 32-bit and 64-bit,
using 2 or 3 rotates, and several different rotation amounts that
achieve the same levels of avalanche.

As far as I can tell, the choice of rotation amounts is the main choice
that matters for quality, with the other variants mainly just limiting
which rotation amounts are actually available. (2-rotate fixes the third
amount at 0, while 32-bit forces amounts to be below 32; otherwise the
variants seem to be the same, except for the word size.)

For the 32-bit variant of the PRNG, Jenkins chose to use the rotation
amounts (27,17), as the 3-rotate variants are slower and no test he knew
of could detect nonrandomness in either.

For the 64-bit variants, Jenkins writes that the proper rotate amounts
are (39,11) for the 2-rotate version, or (7,13,37) for the 3-rotate
version, and that he'd go with the 3-rotate version for that.

I note that PractRand uses the 2-rotate variants for both 32-bit and
64-bit, with the amounts (27,17) and (39,11) respectively.

### 8-bit and 16-bit

Jenkins did not provide 8-bit or 16-bit variants of JSF, but he did give
a lot of documentation on how JSF was designed, and the tools he used to
develop the magic constants.

M.E. O'Neill [used those resources][meo], with a few changes, to produce
a pair of smaller-sized variants, for 8-bit and 16-bit word sizes.

Both of them are 2-rotate variants, with the 16-bit one using the rotate
amounts (13,8), and the 8-bit one using the amounts (1,4).

Additionally, PractRand has a 16-bit JSF under "other/simple", with the
rotate amounts (13,9). As far as I can find, it does not have 8-bit JSF.

## References

- Bob Jenkins, ["A small noncryptographic PRNG"][bobj]
- M.E. O'Neill, ["Bob Jenkins's Small PRNG Passes PractRand (And More!)"][meo]
- Chris Doty-Humphrey, [Practically Random][PractRand] (PractRand)
- [filterpaper notes on PRNGs][filterpaper]

[bobj]: http://burtleburtle.net/bob/rand/smallprng.html
[meo]: https://www.pcg-random.org/posts/bob-jenkins-small-prng-passes-practrand.html
[PractRand]: https://pracrand.sourceforge.net/
[filterpaper]: https://filterpaper.github.io/prng.html
