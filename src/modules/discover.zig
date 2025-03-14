const std = @import("std");
const builtin = @import("builtin");
const fs = std.fs;
const mem = std.mem;
const fmt = std.fmt;
const LazyPath = std.Build.LazyPath;
const Cache = std.Build.Cache;

const SourceType = enum(u8) {
    invalid = 0 << 0,
    c = 1 << 1,
    cpp = 1 << 2,
    cxx = 1 << 3,
    cc = 1 << 4,
    C = 1 << 5,
    stub = 1 << 6,

    fn getFromFilename(filename: []const u8) SourceType {
        const extension = fs.path.extension(filename);
        if (mem.eql(u8, extension, ".c")) {
            return SourceType.c;
        } else if (mem.eql(u8, extension, ".cpp")) {
            return SourceType.cpp;
        } else if (mem.eql(u8, extension, ".cxx")) {
            return SourceType.cxx;
        } else if (mem.eql(u8, extension, ".cc")) {
            return SourceType.cc;
        } else if (mem.eql(u8, extension, ".C")) {
            return SourceType.C;
        } else if (mem.eql(u8, extension, ".stub")) {
            return SourceType.stub;
        } else {
            return SourceType.invalid;
        }
    }

    fn isValidSource(self: SourceType, bitmask: u8) bool {
        return (@intFromEnum(self) & bitmask) != 0;
    }
};


pub const DiscoverCSourceFilesOptions = struct {
    /// Path relative to the build directory
    root: ?LazyPath,
    flags: []const []const u8 = &.{},
    filters: SourceFilters = .{},
};


const SourceFilters = struct {
    include_pattern: []const u8 = "", // Currently does nothing, but hopefully will be able to compare against found files using regex
    exclude_pattern: []const u8 = "", // Currently does nothing, but hopefully will be able to compare against found files using regex
    /// File paths that end in any of these suffixes will be excluded from installation.
    exclude_extensions: []const []const u8 = &.{},
    /// Only file paths that end in any of these suffixes will be included in installation.
    /// `null` means that all suffixes will be included.
    /// `exclude_extensions` takes precedence over `include_extensions`.
    include_extensions: []const []const u8 = &.{ "c", "cpp", "cc", "cxx"},
};

/// TODO: Has a pretty naive implementation at the moment because I just want to get it working. This should be revisted sooner
/// rather than later.
fn findSources(allocator: std.mem.Allocator, srcDir: LazyPath, filters: SourceFilters) !std.ArrayListUnmanaged([]const u8) {
    const path = switch (srcDir) {
        .src_path => |sp| .{
            .root_dir = sp.owner.build_root,
            .sub_path = sp.sub_path,
        },
        .cwd_relative => |sub_path| .{
            .root_dir = Cache.Directory.cwd(),
            .sub_path = sub_path,
        },
        .dependency => |dep| .{
            .root_dir = dep.dependency.builder.build_root,
            .sub_path = dep.sub_path,
        },
        .generated => @panic("Invalid LazyPath `srcDir`"),
    };
    // std.debug.print("Searching -- root: {s}; subpath: {s}\n", .{path.root_dir.path orelse ".", path.sub_path});
    var dir = try path.root_dir.handle.openDir(path.sub_path, .{.iterate = true});
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
        if (should_exclude) { continue; }

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
    // std.debug.print("\nScanned: {d} files; found {d}\n", .{t, sources.items.len});

    return sources;
}


/// Discover C/C++ source files of the given extensions in a root 
/// directory and implicitly add them to the input Compile Step
pub fn discoverCSourceFiles(cs: *std.Build.Step.Compile, options: DiscoverCSourceFilesOptions) !void {
    const b = cs.root_module.owner;
    const search_root = options.root orelse b.path("");
    const sources = findSources(b.allocator, search_root, options.filters) catch @panic("OOM");

    cs.addCSourceFiles(.{
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

test "discover the correct amount of sources" {}
