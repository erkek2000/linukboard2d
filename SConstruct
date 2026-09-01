#!/usr/bin/env python

import os
import sys

local_env = Environment(tools=["default"], PLATFORM="")

if not os.path.isfile("godot-cpp/SConstruct"):
    print("godot-cpp is missing. Run: git submodule update --init --recursive")
    sys.exit(1)

env = SConscript("godot-cpp/SConstruct", {"env": local_env, "api_version": "4.7"})
env.Append(CPPPATH=["native/"])

sources = Glob("native/*.cpp")
if env["platform"] == "macos":
    library = env.SharedLibrary(
        "bin/liblinukboard_ai.{}.{}.framework/liblinukboard_ai.{}.{}".format(
            env["platform"], env["target"], env["platform"], env["target"]
        ),
        source=sources,
    )
else:
    library = env.SharedLibrary(
        "bin/liblinukboard_ai{}{}".format(env["suffix"], env["SHLIBSUFFIX"]),
        source=sources,
    )

test_env = Environment(tools=["default"])
core_tests = test_env.Program(
    "build/tests/minimax_core_test",
    ["tests/minimax_core_test.cpp", "native/minimax_core.cpp"],
)
Alias("tests", core_tests)

Default(library)
