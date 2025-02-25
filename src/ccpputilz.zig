const testing = @import("std").testing;


pub const discoverCSourceFiles = discover.discoverCSourceFiles;



pub const discover = @import("modules/discover.zig");
pub const corrosion = @import("modules/corrosion.zig");
pub const version = @import("modules/version.zig");
pub const compiledb = @import("modules/compile_commands.zig");
// pub const find_vulkan = @import("modules/find_vulkan.zig");
// pub const autodoc = @import("modules/autodoc.zig")
pub const gtest = @import("modules/gtest.zig");

/// For internal use only
const tests = @import("internal/testing.zig");
const root = @import("root");



test {
    testing.refAllDecls(@This());
}
