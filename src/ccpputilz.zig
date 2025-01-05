const std = @import("std");
const testing = std.testing;

pub const discover = @import("discover.zig");
pub const corrosion = @import("corrosion.zig");
pub const version = @import("version.zig");
pub const cdb = @import("compile_commands.zig");
// pub const find_vulkan = @import("find_vulkan.zig");
pub const gtest = @import("gtest.zig");

/// For internal use only
const tests = @import("internal/testing.zig");


test {
    testing.refAllDecls(@This());
}
