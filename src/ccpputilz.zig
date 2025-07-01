// Default Modules (available by without need for 3rd party libraries)
pub const default = @import("default.zig");

// Extension Modules (available only if client also fetches 3rd party libraries)
pub const extensions = @import("extensions.zig");

/// Internal Modules (For internal use only)
// const tests = @import("internal/testing.zig");
const root = @import("root");

const testing = @import("std").testing;
test {
    testing.refAllDecls(@This());
}
