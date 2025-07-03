const std = @import("std");
const builtin = @import("builtin");
const fs = std.fs;
const mem = std.mem;
const fmt = std.fmt;

const Build = std.Build;
const Step = Build.Step;
const Module = Build.Module;
const LazyPath = std.Build.LazyPath;
const Cache = std.Build.Cache;
const CSourceFiles = std.Build.Module.CSourceFiles;
const CSourceLanguage = std.Build.Module.CSourceLanguage;


pub const DiscoverCSourceFilesOptions = struct {
    /// Path relative to the build directory
    root: ?LazyPath,
    flags: []const []const u8 = &.{},
    language: ?CSourceLanguage = null, 
    filters: SourceFilters = .{},
};

const Path = struct {
    root_dir: Cache.Directory,
    sub_path: []const u8,
};

const SourceFilters = struct {
    include_pattern: []const u8 = "", // Currently does nothing, but hopefully will be able to compare against found files using regex
    exclude_pattern: []const u8 = "", // Currently does nothing, but hopefully will be able to compare against found files using regex
    /// File paths that end in any of these suffixes will be excluded from installation.
    exclude_extensions: []const []const u8 = &.{},
    /// Only file paths that end in any of these suffixes will be included in installation.
    /// `null` means that all suffixes will be included.
    /// `exclude_extensions` takes precedence over `include_extensions`.
    include_extensions: []const []const u8 = &.{ "c", "cpp", "cc", "cxx" },
};


/// Start in the root of the target directory and walk all the files, searching for any that match the currently selected language.
fn findSources(allocator: std.mem.Allocator, srcDir: LazyPath, _: ?CSourceLanguage, filters: SourceFilters) !std.ArrayListUnmanaged([]const u8) {
    // properly handle LazyPath union options
    const path: Path = switch (srcDir) {
        .src_path => |sp| Path{
            .root_dir = sp.owner.build_root,
            .sub_path = sp.sub_path,
        },
        .cwd_relative => |sub_path| Path{
            .root_dir = Cache.Directory.cwd(),
            .sub_path = sub_path,
        },
        .dependency => |dep| Path{
            .root_dir = dep.dependency.builder.build_root,
            .sub_path = dep.sub_path,
        },
        .generated => @panic("Invalid LazyPath `srcDir`"), // Don't allow searching generated paths
    };
   
    var dir = try path.root_dir.handle.openDir(path.sub_path, .{ .iterate = true });
    defer dir.close();

    var walker = try dir.walk(allocator);
    defer walker.deinit();

    var sources = std.ArrayListUnmanaged([]const u8){};
    var t: u32 = 0;
    while (try walker.next()) |entry| {
        t += 1;
        if (entry.kind != fs.File.Kind.file) {
            continue; // Continue if entry is NOT a file
        }

        var it = std.mem.splitBackwardsScalar(u8, entry.basename, '.');
        const split = it.first();
        const file_extension = if (mem.eql(u8, split, entry.basename)) "" else split; // Handle case where there is no file extension

        var should_exclude = false;
        for (filters.exclude_extensions) |ext| {
            if (mem.eql(u8, file_extension, ext)) {
                should_exclude = true;
                break;
            }
        }
        if (should_exclude) {
            continue;
        }

        var should_include = false;
        for (filters.include_extensions) |ext| {
            if (mem.eql(u8, file_extension, ext)) {
                should_include = true;
                break;
            }
        }
        if (should_include) {
            const fullpath = try fs.path.join(allocator, &[_][]const u8{entry.path});
            try sources.append(allocator, fullpath);
        }
    }

    return sources;
}


/// Discover C/C++ source files in a source directory and make them available to the buildsystem.
///
/// Because both `std.Build.Step.Compile` and `std.Build.Module` structures support the insertion
/// of `std.Build.Module.CSourceFiles` via their respective `addCSourceFiles` functions, we use a
/// comptime parameter to explcitly tell the function which version to use.
pub fn discoverCSourceFiles(ptr: anytype, options: DiscoverCSourceFilesOptions) void {
    comptime {
        if (@TypeOf(ptr) != *Step.Compile and @TypeOf(ptr) != *Module) {
            @panic("Error: function `discoverCSourceFiles` requires a pointer input of type `std.Build.Step.Compile` or `std.Build.Module`");
        }
    }
    switch (@TypeOf(ptr)) {
        *std.Build.Step.Compile => {
            discoverCSourceFilesForCompileStep(ptr, options);
        },
        *std.Build.Module => {
            discoverCSourceFilesForModule(ptr, options);
        },
        else => {
            unreachable;
        },
    }
}


/// Search the source directroy and add them directly to the *Step.Compile struct
fn discoverCSourceFilesForCompileStep(cs: *std.Build.Step.Compile, options: DiscoverCSourceFilesOptions) void {
    const b = cs.root_module.owner;
    const allocator = b.allocator;

    const search_root = options.root orelse b.path("");
    const sources = findSources(allocator, search_root, options.language, options.filters) catch @panic("OOM");

    cs.addCSourceFiles(.{
        .root = search_root,
        .files = sources.items,
        .flags = options.flags,
    });
}


fn discoverCSourceFilesForModule(module: *std.Build.Module, options: DiscoverCSourceFilesOptions) void {
    const b = module.owner;
    const allocator = b.allocator;

    const search_root = options.root orelse b.path("");
    const sources = findSources(allocator, search_root, options.language, options.filters) catch @panic("OOM");

    module.addCSourceFiles(.{
        .root = search_root,
        .files = sources.items,
        .flags = options.flags,
    });
}


test "check FileList for leaks" {
    //    var filelist = try FileList.init(std.testing.allocator, @intFromEnum(SourceType.c), @intFromEnum(HeaderType.h));
    //    filelist.source_bitmask = (@intFromEnum(SourceType.c) | @intFromEnum(SourceType.cpp) | @intFromEnum(SourceType.cc));
    //    filelist.header_bitmask = (@intFromEnum(HeaderType.h) | @intFromEnum(HeaderType.hpp));
    //    defer filelist.deinit();
    //
    //    try filelist.findSources(
    //        "tests/discover",
    //    );
}

test discoverCSourceFiles {
    inline for ([_]type{ Build.Module, Build.Step.Compile }) |_| {}
}
