const std = @import("std");
const builtin = @import("builtin");
const fs = std.fs;
const mem = std.mem;
const fmt = std.fmt;
const LazyPath = std.Build.LazyPath;

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

const HeaderType = enum(u8) {
    invalid = 0 << 0,
    h = 1 << 1,
    hpp = 1 << 2,
    empty = 1 << 3,

    fn getFromFilename(filename: []const u8) HeaderType {
        const extension = fs.path.extension(filename);
        if (mem.eql(u8, extension, ".h")) {
            return HeaderType.h;
        } else if (mem.eql(u8, extension, ".hpp")) {
            return HeaderType.hpp;
        } else if (mem.eql(u8, extension, "")) {
            return HeaderType.empty;
        } else {
            return HeaderType.invalid;
        }
    }

    fn isValidHeader(self: HeaderType, bitmask: u8) bool {
        return (@intFromEnum(self) & bitmask) != 0;
    }
};

const FileList = struct {
    sources: std.ArrayListUnmanaged([]const u8),
    headers: std.ArrayListUnmanaged([]const u8),
    source_bitmask: u8 = @intFromEnum(SourceType.invalid),
    header_bitmask: u8 = @intFromEnum(HeaderType.invalid),
    allocator: std.mem.Allocator,

    fn init(allocator: std.mem.Allocator, sbm: u8, hbm: u8) !FileList {
        return FileList{
            .allocator = allocator,
            .source_bitmask = sbm,
            .header_bitmask = hbm,
            .sources = .{},
            .headers = .{},
        };
    }

    fn findSources(self: *FileList, srcDir: []const u8) !void {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const dir = try fs.cwd().openDir(srcDir, .{ .iterate = true });
        var walker = try dir.walk(gpa.allocator());
        defer walker.deinit();

        while (try walker.next()) |entry| {
            if (entry.kind != fs.File.Kind.file) {
                continue;
            }
            const st = SourceType.getFromFilename(entry.basename);
            if (st == SourceType.invalid) {
                continue;
            } else if (st.isValidSource(self.source_bitmask)) {
                const fullpath = try fs.path.join(self.allocator, &[_][]const u8{ srcDir, entry.path });
                try self.sources.append(self.allocator, fullpath);
            }
        }
    }

    fn outputHeaders(targetDir: []const u8) !void {
        const t = try fs.cwd().openDir(".", .{ .iterate = true });
        t.makeDir(targetDir) catch @panic("Can't make include directory");
    }

    fn deinit(self: *FileList) void {
        for (self.sources.items) |entry| {
            self.allocator.free(entry);
        }
        for (self.headers.items) |entry| {
            self.allocator.free(entry);
        }
        self.sources.deinit(self.allocator);
        self.headers.deinit(self.allocator);
    }
};


pub const DiscoverCSourceFilesOptions = struct {    
    root: []const u8 = "",
    flags: []const []const u8 = &.{},
    /// File paths that end in any of these suffixes will be excluded from installation.
    exclude_extensions: []const []const u8 = &.{},
    /// Only file paths that end in any of these suffixes will be included in installation.
    /// `null` means that all suffixes will be included.
    /// `exclude_extensions` takes precedence over `include_extensions`.
    include_extensions: ?[]const []const u8 = &.{".c", ".cpp"},
};

/// Discover C/C++ source files of the given extensions in a root directory and implicitly add them to the Compile Step
pub fn discoverCSourceFiles(b: *std.Build, cs: *std.Build.Step.Compile, options: DiscoverCSourceFilesOptions) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var filelist = try FileList.init(
        gpa.allocator(),
        (@intFromEnum(SourceType.c) | @intFromEnum(SourceType.cpp) | @intFromEnum(SourceType.cc)),
        (@intFromEnum(HeaderType.h) | @intFromEnum(HeaderType.hpp))
    );
    defer filelist.deinit();
    std.debug.print("found {d} source files in directory {s}", .{filelist.sources.items.len, options.root});

    try filelist.findSources(options.root);
    cs.addCSourceFiles(.{
        .root = b.path(options.root),
        .files = filelist.sources.items,
        .flags = options.flags,
    });

}


test "check FileList for leaks" {
    var filelist = try FileList.init(std.testing.allocator);
    filelist.source_bitmask = (@intFromEnum(SourceType.c) | @intFromEnum(SourceType.cpp) | @intFromEnum(SourceType.cc));
    filelist.header_bitmask = (@intFromEnum(HeaderType.h) | @intFromEnum(HeaderType.hpp));
    defer filelist.deinit();

    try filelist.findFiles("./Source", "./Source");
}
