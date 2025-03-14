const std = @import("std");
const builtin = @import("builtin");
const utilz = @import("ccpputilz");


pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "example",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    exe.addCSourceFile(.{
        .file = b.path("app/main.cpp"),
        .flags = &.{},
    });
    b.installArtifact(exe);

    const lib = b.addStaticLibrary(.{
        .name = "sample",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    
    const enable_all = b.option(bool, "all", "attempt to test the autodoc") orelse false;
    const enable_discover = b.option(bool, "discover", "attempt to test C/C++ source file discovery") orelse false;
    const enable_autodoc = b.option(bool, "autodoc", "attempt to test the autodoc") orelse false;
    const enable_gtest = b.option(bool, "gtest", "attempt to test the gtest integration") orelse false;
    const enable_vulkan = b.option(bool, "vulkan", "attempt to test finding the system version of Vulkan") orelse false;

    if (enable_discover or enable_all) {
        try TestSourceDiscovery(b, lib);
    }
    if (enable_autodoc or enable_all) {
        try TestAutodocGeneration(b);
    }
    if (enable_gtest or enable_all) {
        try TestGoogleTestIntegration(b);
    }
    if (enable_vulkan or enable_all) {
        // TODO(anthony-j-g) : Add testing example
    }
}


/// For Testing discovery of source files to be compiled into the sample library
pub fn TestSourceDiscovery(b: *std.Build, artifact: *std.Build.Step.Compile) !void {
    try utilz.discover.discoverCSourceFiles();
    for (artifact.)
    b.installArtifact(artifact);
}


/// For Testing The ability of the project to automatically generate C/C++ documentation.
pub fn TestAutodocGeneration(_: *std.Build) !void {
    // TODO(anthony-j-g) : Add testing example
}


/// For Testing Integration of GoogleTest inside of the project.
pub fn TestGoogleTestIntegration(_: *std.Build) !void {    
    // TODO(anthony-j-g) : Add testing example
}