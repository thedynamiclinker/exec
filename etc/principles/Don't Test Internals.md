- Documentation is a form of communication.
- The internals of a project should not need to be communicated outside the project.
- So, if you feel you need to test the internals of a project, that's your internals trying to tell you "Hey creator, I think I'm a library."
- Listen to your creation. Take those internals you wanted to test, and make them into the external (public) interface of a separate library. Now they're external, so you can test them. Now those internals are reusable in other projects too.

See: [[Write Executable Documentation]]