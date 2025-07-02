const std = @import("std");
const Compile = std.Build.Step.Compile;
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
        .file = b.path("src/app/main.cpp"),
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
    const enable_cdb = b.option(bool, "cdb", "attempt to test the generation of a `compile_commands.json` file") orelse false;

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
        try TestFindVulkan(b);
    }
    if (enable_cdb or enable_all) {
        try TestCompileCommandsGeneration(b, lib, exe);
    }
}


/// Attempt to traverse through a directory of source files and dynamically add them to a 
/// static library. This function also enables the build system to actually compile (install) 
/// the library and link it to the executable.
pub fn TestSourceDiscovery(b: *std.Build, artifact: *std.Build.Step.Compile) !void {
    try utilz.discover.discoverCSourceFiles(artifact, .{
        .root = b.path("src/lib")
    });
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


/// For Testing Integration of GoogleTest inside of the project.
pub fn TestFindVulkan(_: *std.Build) !void {    
    // TODO(anthony-j-g) : Add example calling of find_vulkan
}


/// For Testing Integration of GoogleTest inside of the project.
pub fn TestCompileCommandsGeneration(b: *std.Build, lib: *Compile, exe: *Compile) !void {
    try utilz.compile_commands.generateCompileCommands(b, &.{
        lib,
        exe
    });
}
