const std = @import("std");
const ccpputilz = @import("src/ccpputilz.zig");
pub usingnamespace ccpputilz;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const module = b.addStaticLibrary(.{
        .name = "utilz",
        .root_source_file = b.path("src/ccpputilz.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Generate Docs
    const install_docs = b.addInstallDirectory(.{
        .source_dir = module.getEmittedDocs(),
        .install_dir = .{ .custom = "" },
        .install_subdir = "docs",
    });
    const docs_step = b.step("docs", "Install docs into zig-out/docs");
    docs_step.dependOn(&install_docs.step);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const unit_tests = b.addTest(.{
        .root_source_file = b.path("src/ccpputilz.zig"),
        .target = target,
        .optimize = optimize,
    });
    const unit_tests_cmd = b.addRunArtifact(unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&unit_tests_cmd.step);
}
