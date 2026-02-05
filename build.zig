const std = @import("std");

pub const compiledb = @import("src/default/compiledb.zig");
pub const discover  = @import("src/default/discover.zig");

// pub const extensions = @import("extensions.zig");


pub fn build(b: *std.Build) void {
    _ = b;
    @panic("This dev dependency isn't meant to be build");

    // NOTE(anthony-j-g): Can maybe add a step back to build docs and run tests?
}
