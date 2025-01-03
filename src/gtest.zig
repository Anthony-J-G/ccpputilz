const std = @import("std");
const LazyPath = std.Build.LazyPath;


const CreateTestStepOptions = struct {
    name: ?[]const u8 = "tests",
    entry_point: ?LazyPath = null,
    target: std.Build.ResolvedTarget,
    optimize: ?std.builtin.OptimizeMode = null,
};


pub fn createTestStep(b: *std.Build, options: CreateTestStepOptions) *std.Build.Step.Compile {
    const googletest = b.dependency("googletest", .{});

    const name = options.name orelse "tests";
    const entry_point = options.entry_point orelse googletest.path("googletest/gtest/src/gtest_main.cc");
    const target = options.target;
    const optimize = options.optimize orelse std.builtin.OptimizeMode.Debug;

    const exe = b.addExecutable(.{
        .name = name,
        .target = target,
        .optimize = optimize,
    });
    exe.addCSourceFile(.{
        .file = entry_point,
        .flags = &.{} 
    });
    exe.addCSourceFile(.{
        .file = googletest.path("googletest/src/gtest-all.cc"),
        .flags = &.{}
    });
    exe.addIncludePath(googletest.path("googletest/include"));
    exe.addIncludePath(googletest.path("googletest"));
    exe.linkLibCpp();

    const run_unit_tests = b.addRunArtifact(exe);
    if (b.args) |args| {
        run_unit_tests.addArgs(args);
    }
    const test_step = b.step(name, "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);

    return exe;
}