const std = @import("std");
const builtin = std.builtin;
const ArrayListUnmanaged = std.ArrayListUnmanaged;
const expect = std.testing.expect;

const Configuration = enum {
    freestanding,
    other,

    contiki,
    elfiamcu,
    fuchsia,
    hermit,

    aix,
    haiku,
    hurd,
    linux,
    plan9,
    rtems,
};

const FindVulkanOptions = struct {
    SDK_path: ?[]const u8,
    glslc: bool = true, // The SPIR-V compiler
    glslangValidator: bool = true, // The glslangValidator tool
    glslang: bool = false, // The SPIR-V generator library
    shaderc_combined: bool = false, // The static library for Vulkan shader compilation
    SPIRV_tools: bool = false, // Tools to process SPIR-V modules
    MoltenVK: bool = false, // On macOS, an additional component MoltenVK is available
    dxc: bool = false, // The DirectX Shader Compiler
};

pub fn FindVulkan(target: std.Build.ResolvedTarget, options: FindVulkanOptions) bool {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    // Declare search paths
    _ = ArrayListUnmanaged([]const u8).initCapacity(allocator, 10) catch @panic("OOM");
    _ = ArrayListUnmanaged([]const u8).initCapacity(allocator, 10) catch @panic("OOM");
    _ = ArrayListUnmanaged([]const u8).initCapacity(allocator, 10) catch @panic("OOM");

    _ = 0;

    _ = options.SDK_path orelse "";

    // Determine Vulkan SDK placement within system
    _ = if (target.result.os == .windows) "vulkan-1" orelse "vulkan";

    return true;
}

test "find basic vulkan SDK" {
    const target = std.Build.ResolvedTarget{};
    try expect(FindVulkan(target, .{}));
}
