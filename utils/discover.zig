const std = @import("std");
const Compile = std.Build.Step.Compile;
const Module = std.Build.Module;

/// Handy when you have many C/C++ source files and want them all to have the same flags.
pub fn addCSourceFiles(compile: *Compile, options: Module.AddCSourceFilesOptions) void {
    compile.root_module.addCSourceFiles(options);
}

/// Handy when you have many C/C++ source files and want them all to have the same flags.
pub fn discoverCSourceFiles(compile: *Compile, options: Module.AddCSourceFilesOptions) void {
    compile.root_module.addCSourceFiles(options);
}

pub fn allYour() void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try bw.flush(); // don't forget to flush!
}
