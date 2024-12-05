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
