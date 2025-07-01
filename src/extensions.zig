//! Extension modules with APIs that are available by default, but require 3rd-party libraries to be fetched before they can be used.

pub const gtest = @import("extensions/gtest.zig");
// pub const corrosion = @import("extensions/corrosion.zig"); // TODO(anthony-j-g): Make it so that if a client tries to call this, they get a @panic error
// pub const find_vulkan = @import("extensions/find_vulkan.zig");

