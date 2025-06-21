//! Builtin utility modules that are enabled by default and available to use out of the box.

pub fn standIn() void {}

pub const version = @import("default/version.zig");
pub const compile_command = @import("default/compile_commands.zig");
pub const tests = @import("default/tests.zig");
pub const autodoc = @import("default/autodoc.zig");

pub const discoverCSourceFiles = @import("default/discover.zig").discoverCSourceFiles;

test {
    _ = discoverCSourceFiles;
}
