const std = @import("std");
const lib = @import("add.zig");
const testing = std.testing;

export fn multiply(a: i32, b: i32) i32 {
    var sum: i32 = 0;
    const result: u64 = if (a < 0) @intCast(-a) else @intCast(a);
    for (0..result) |_| {
        sum = lib.add(sum, b);
    }

    return sum;
}

test "basic add functionality" {
    try testing.expect(lib.add(3, 7) == 10);
}
