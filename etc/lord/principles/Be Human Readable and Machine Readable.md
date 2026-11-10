All writing is for communication.

1. With machines.
2. With humans (including yourself in the future).

Obfuscated code is 1 but not 2.

Documentation is 2 but not 1.

The best way to spend your time as a developer is by writing code and storing data in forms that are both 1 and 2.

This is the model of the `/etc` directory in Unix.

Files in the `/etc` directory are not all required to have a common format.

What they all share is that they're all both 1 and 2.

Unix teaches us two lessons about plain-text.

Lesson 1 is to be human readable, and [[Standardize on Plain Text]]

Lesson 2 is that when the user is a programmer, being human readable is not the same as being user friendly. As a programmer, we also want our human readable text to have just enough structure that it can be easily parsed by simple code, ideally one-liners that you can write without thinking. Since [[zero/principles/Documentation Always Lags Reality|Documentation Always Lags Reality]], the best documentation is the subset which is forced to keep itself up to date with a changing reality. The best way to achieve that is for the "documentation" to be constantly parsed and used by the code it's meant to document. A good example of this is the `.toml` file format, and this philosophy is reflected in [what TOML stands for](https://toml.io/en). In *The Elements of Programming Style*, Brian Kernighan expresses the same principle with the advice to [[Brian Kernighan - Elements of Programming Style|Make every comment count]].

So whenever possible, avoid wasting too much time writing in formats that are only 1, or only 2.

That means:
- Less time spent writing in Confluence and READMEs.
- More time spent writing simple tests and minimal working examples of how to use your code.
- Whenever possible, avoid binary data formats.
- Storing data in non-human-readable binary formats like databases is almost always a form of premature optimization.
- Until you're absolutely certain that your application is IO bound and rate limited by access time to a specific type of data, it is premature to put that data into a non-human-readable format.
