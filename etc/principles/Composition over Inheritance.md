On first encounter with the inheritance model of code re-use, the majority of developers find it beautiful and intuitive.

But in practice, whenever we try to make code re-usable by inheritance or subclassing, a small empirical tragedy occurs.

As elegant as the idea feels when imagined, the fundamental problem with subclassing is expressed by the following principle, obvious once articulated:

_If two code blocks A and B are each written without knowledge of each other, then A and B should not share a namespace._

This is completely obvious and unobjectionable once stated.

Now, many successful languages don't abide by this principle, and they have found ways to ensure it doesn't matter. C does just fine with a global namespace, as long as each library author follows the convention to name their library's functions by prefixing them with the library's name: the foo library's functions being called `foo_funcname` and the bar library's functions being called `bar_funcname`. This simple convention gives nearly all the benefits of namespaces or modules, in a language where all functions are global by default. 

However, the distinction between:
* libraries (within-process code reuse) and
* executables (between-process code reuse)
is less strong in the OO world than it is in the world of ELF binaries.

The closest analogue to shared libraries in OO is probably the concept of a mixin class.

But mixins do not generally have to follow the name prefixing convention that prevents name collisions in languages like C.

As a result, while code re-use via subclassing feels nice when imagined, in practice it leads to an uncomfortable uncertainty about whether and when the shared names will collide.

This is solved by specifying some method resolution order so that inheritance diamonds can be collapsed and unique names can be assigned, but the programmer who writes:

```python
class A(B, C)
```

needs to keep actively in mind the entire namespace worth of methods of `B` and `C` in order to know which methods will run when, and which attributes will be used by them.

As a result, composition is a better strategy in practice, though it arguably feels less elegant when imagined.

Rather than `A` trying to _be_ both a `B` and `C`, `A` _has_ a `B` and `C`.

This solves all the above problems of namespacing, though it often leaves the user with the feeling that life would be simpler if only we could somehow make subclassing work.