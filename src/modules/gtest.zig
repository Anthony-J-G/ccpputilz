const std = @import("std");
const internal = @import("../internal/testing.zig");
const LazyPath = std.Build.LazyPath;


const CreateTestStepOptions = struct {
    name: ?[]const u8 = "tests",
    entry_point: ?LazyPath = null,
    target: std.Build.ResolvedTarget,
    optimize: ?std.builtin.OptimizeMode = null,
};
const MakeAllTestsOptions = struct {
    output_prefix: ?[]const u8 = "tests",
    entry_point: ?LazyPath,
    compile_steps: []const *std.Build.Step.Compile,
};

/// Make all tests
fn makeAllTests(b: *std.Build, options: MakeAllTestsOptions) void {
    const googletest = comptime { b.dependency("googletest", .{}); };

    const output_prefix = options.output_prefix orelse "tests";
    const entry_point = options.entry_point orelse googletest.path("googletest/gtest/src/gtest_main.cc");

    for (options.compile_steps) |step| {
        _ = output_prefix.len + 1 + step.name.len;
        
        switch (step.kind) {
            .exe => {
                step.addCSourceFile(.{
                    .file = entry_point,
                    .flags = &.{"-fsanitize=address"} 
                });
            }
        }
        b.installArtifact(step);
    }

}



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

// Testing
test "dupe artifact pointers" {
    const cs1 = internal.makeTestCompileStep("Exe1", .lib);
    const cs2 = internal.makeTestCompileStep("Exe2", .lib);

    _ = std.testing.allocator.dupe(std.Build.Step.Compile, &.{
        cs1,
        cs2
    }) catch @panic("OOM");
}

test "append prefix to tests" {
    try std.testing.expect(false);
    try std.testing.expect(true);
    try std.testing.expect(true);
    try std.testing.expect(false);
}