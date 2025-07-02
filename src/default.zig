//! Builtin utility modules that are enabled by default and available to use out of the box.


pub const compiledb = @import("default/compiledb.zig");
pub const discover  = @import("default/discover.zig");
// pub const version = @import("default/version.zig");
// pub const tests = @import("default/tests.zig");
// pub const autodoc = @import("default/autodoc.zig");
// pub const discoverCSourceFiles = @import("default/discover.zig").discoverCSourceFiles;

test {
//    _ = discoverCSourceFiles;
}
