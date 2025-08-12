#!/usr/bin/python3

"""unix which for python modules"""

__all__ = [
    'which',
]

import os
import sys
import inspect
import importlib

def which(module_name):

    """unix which command for python modules."""

    try:
        module = importlib.import_module(module_name)
        result = inspect.getfile(module)
        if os.path.basename(result) == '__init__.py':
            result = os.path.dirname(result)
    except Exception as err:
        result = err
    finally:
        return result


if __name__ == '__main__':

    if len(sys.argv) == 1:
        print("usage: which <python-module>", file=sys.stderr)
    elif len(sys.argv) == 2:
        print(which(sys.argv[1]))
    else:
        print("usage: which <python-module>", file=sys.stderr)

else:

    sys.modules['which'] = which
