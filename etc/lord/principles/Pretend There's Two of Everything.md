When writing code, always assume there are two instances of everything outside your code, even if one instance is imaginary.

This automatically turns:

```python
def foo():
	return open('/path/to/thing').read()
```

into

```python
def foo(path):
	return open(path).read()
```

The `foo` refactor is trivial, but as code becomes more complex The Right Decision becomes less obvious.

By imagining there are two of everything, we automatically make reusable code. We make decisions that none of us is smart enough to make when we only focus on the task at hand.

Mastering the skill of Always Two leads you to develop reusable tools entirely by accident, even if you only set out to write a quick one-off script in limited time.

The difference between one-off code and reusable code is NOT planning, bureaucracy, kanban boards, and formal process.

The difference between one-off code and reusable code is ONLY the single detail of whether you imagined there are two of everything your code touches, at the time that code was written.

It is NOT slower to move specifics up the stack, and pass them into a more general function. Both the function body and the function call need to be typed either way.

None of us is smart enough to feel the weight and significance of this difference when there's truly only one X that our code touches.

To become smart enough to tell the difference, just imagine there are two Xs, even if one is entirely pretend.