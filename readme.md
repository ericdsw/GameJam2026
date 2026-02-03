# Global Gamejam 2026 submission.

Simple game submitted to the global gamejam 2026 where you run a beauty shop where absolutely nothing bad happens ever...


# Code style used

To make code easier to read, I divided it into multiple sections with the following snippet template:

```gdscript
# ================================ [SECTION NAME] ================================ #
```

Note that this is not part of the godot's official codign standard, it's just something I like to do to break up the code visually.

And I'm the following sections:

## Lifecycle

```gdscript
# ================================ Lifecycle ================================ #
```

Where I define all the methods that are automatically called by Godot when it runs the node's regular lifecycle logic, such as `_ready`, `_process`, `_input`, etc.

Most of these methods are defined in the official documentation, and are marked as "virtual": https://docs.godotengine.org/en/stable/classes/class_node.html


## Public
```gdscript
# ================================= Public ================================== #
```

Where I define the public API for the node. External nodes should ideally only call these methods

## Private
```gdscript
# ================================= Private ================================= #
```

Where I define internal methods for the node. Note that I start all private methods with an underscore as a naming convention, which makes them easier to identify as godot has no access level support (`public`, `private`, etc).

## Callbacks
```gdscript
# ================================ Callbacks ================================ #
```

Methods that are (ideally) called exclusively by emitted signals.


# Additional documentation

I'd recommend reading up on the following documentation pages to better understand certain patterns I'm using:

Understanding the `@tool` keyword:
https://docs.godotengine.org/en/stable/tutorials/plugins/running_code_in_the_editor.html

Documentation for the `tween` class (instantiated by the `create_tween` method):
https://docs.godotengine.org/en/stable/classes/class_tween.html

Understanding how `@export` properties work:
https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html

Understanding the `await` keyword (coroutines):
https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#awaiting-signals-or-coroutines

Understanding lambda functions (inline functions with the `func()` definition):
https://docs.godotengine.org/en/latest/tutorials/scripting/gdscript/gdscript_basics.html#lambda-functions

Understanding callables (and how the `bind` method works):
https://docs.godotengine.org/en/stable/classes/class_callable.html