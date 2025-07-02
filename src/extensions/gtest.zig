const std       = @import("std");
const Build     = std.Build;
const Step      = Build.Step;
const Module    = Build.Module;
const LazyPath  = Build.LazyPath;
const Dependency= Build.Dependency;

const internal = @import("../internal/testing.zig");

var gtest: *Dependency = null;


/// The `gtest` module depends on the calling client
    
fn ensureGoogleTest(_: *Build) void {
}


pub const TestOptions = struct {
    name: []const u8 = "test",
    max_rss: usize = 0,
    filters: []const []const u8 = &.{},
    test_runner: ?Step.Compile.TestRunner = null,
    use_llvm: ?bool = null,
    use_lld: ?bool = null,
    zig_lib_dir: ?LazyPath = null,
    root_module: ?*Module = null,    
};


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


/// Creates an executable containing unit tests.
///
/// Follows the public facing API that's implemented in std.Build.addTest
/// as closely as possible for parity with Zig's Standard Library.
///
/// **This step does not run the unit tests**. Typically, the result of this
/// function will be passed to `addRunArtifact`, creating a `Step.Run`. These
/// two steps are separated because they are independently configured and
/// cached.
pub fn addTest(_: *std.Build, _: TestOptions) *Step.Compile {
}


/// Creates an executable containing unit tests and adds a run step 
/// to the build script automatically.
///
/// Equivalent to adding a `std.Build.Compile.Step` manually via `gtest.addTest`
/// and then passing it to `addRunArtifact` after creating a `Step.Run`.
pub fn createTestStep(b: *std.Build, options: CreateTestStepOptions) *std.Build.Step.Compile {
    const googletest = b.dependency("googletest", .{});

    const name = options.name orelse "tests";
    const entry_point = options.entry_point orelse googletest.path("googletest/src/gtest_main.cc");
    const target = options.target;
    const optimize = options.optimize orelse std.builtin.OptimizeMode.Debug;

    const exe = b.addExecutable(.{
        .name = name,
        .target = target,
        .optimize = optimize,
    });
    exe.addCSourceFile(.{
        .file = entry_point,
        .flags = &.{"-std=c++17"} 
    });
    exe.addCSourceFile(.{
        .file = googletest.path("googletest/src/gtest-all.cc"),
        .flags = &.{"-std=c++17"}
    });
    exe.addIncludePath(googletest.path("googletest/include"));
    exe.addIncludePath(googletest.path("googletest"));
    exe.linkLibCpp();

    const run_unit_tests = b.addRunArtifact(exe);
    if (b.args) |args| {
        run_unit_tests.addArgs(args);
    }
    const test_step = b.step(name, "Run unit tests");
    run_unit_tests.step.dependOn(b.getInstallStep());
    test_step.dependOn(&run_unit_tests.step);

    return exe;
}






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
