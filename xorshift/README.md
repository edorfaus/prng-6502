# Xorshift

Xorshift is a class of simple PRNGs that was invented by George
Marsaglia in 2003. They are a subset of LFSRs that allow fast software
implementation, but they do not pass all statistical tests on their own.
(Marsaglia suggested combining them with a non-linear function.)

If I'm reading [the Wikipedia article][WP] correctly, Marsaglia provided
variants with 32-bit, 64-bit, and 128-bit state.

Then, in 2017, John Metcalf posted [a 16-bit variant][JM], or more
accurately, 4 variants that only differ in the shift amounts. He says
they all pass a series of lightweight randomness tests, but I don't know
enough about the subject to really understand what exactly he means.
Since his goal was implementation in Z80 assembly, he picked one of them
for being easier to implement on such systems, with shift amounts 7,9,8.

My implementation here uses those same shift amounts, since his reasons
are also valid for 6502 assembly. However, my implementation is my own,
based on the concepts shown in his C implementation, and then optimized.

I note that this implementation does not combine the Xorshift PRNG core
with any non-linear function. However, I expect the small state to be
enough on its own to make it fail various statistical tests, and the
limitations of the target system makes it seem unlikely to be a problem.

This 16-bit xorshift returns all possible 16-bit values, except for 0,
unless the given seed was 0 - in which case it returns nothing but 0.

## References

- Wikipedia, [Xorshift][WP]
- John Metcalf, ["16-Bit Xorshift Pseudorandom Numbers in Z80
  Assembly"][JM]

[WP]: https://en.wikipedia.org/wiki/Xorshift
[JM]: http://www.retroprogramming.com/2017/07/xorshift-pseudorandom-numbers-in-z80.html
