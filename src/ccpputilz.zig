// Default Modules (available by default)
pub const discover          = @import("default/discover.zig");
pub const version           = @import("default/version.zig");
pub const compile_commands  = @import("default/compile_commands.zig");
pub const tests             = @import("default/tests.zig");
pub const autodoc           = @import("default/autodoc.zig");


// Third Party Extension Modules (require additional dependencies)
pub const corrosion         = @import("extensions/corrosion.zig"); // TODO(anthony-j-g): Make it so that if a client tries to call this, they get a @panic error
pub const gtest             = @import("extensions/gtest.zig");
pub const find_vulkan       = @import("extensions/find_vulkan.zig");


/// Internal Modules (For internal use only)
// const tests = @import("internal/testing.zig");
const root = @import("root");


const testing = @import("std").testing;
test {
    testing.refAllDecls(@This());
}
