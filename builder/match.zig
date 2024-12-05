const std = @import("std");
const string = []const u8;
const ArrayList = std.ArrayList;

pub fn Glob(pattern: string) !ArrayList(string) {
    return globWithLimit(pattern, 0);
}

fn globWithLimit(pattern: string, depth: u32) !ArrayList(string) {
    const pathSeparatorsLimit = 10000;
    if (depth == pathSeparatorsLimit) {
        return error.InvalidChar;
    }
}
