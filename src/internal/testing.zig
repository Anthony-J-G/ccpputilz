const std = @import("std");

/// TODO: Figure out how to get the Host's resolved target WITHOUT *std.Build.
/// This is so that when testing the build script's functionality it can be tested
/// on loads that are as close to production as possible and not dummy structs/functions
fn getNativeTarget() std.Build.ResolvedTarget {
    return std.Build.ResolvedTarget{};
}

/// Useful for streamlining testing to avoid recreating bulky Step.Compile structs 
/// in every test
pub fn makeTestCompileStep(name: []const u8, kind: std.Build.Step.Compile.Kind) std.Build.Step.Compile {
    const exe_options = std.Build.ExecutableOptions{
        .name = name,
        .target = getNativeTarget(),
    };
    _ = std.Build.StaticLibraryOptions{
        .name = name,
        .target = getNativeTarget(),
        .optimize = .Debug,
    };
    _ = std.Build.SharedLibraryOptions{
        .name = name,
        .target = getNativeTarget(),
        .optimize = .Debug,
    };

    switch (kind) {
        .exe => {
            return std.Build.Step.Compile{
                .name = exe_options.name,
                .root_module = .{
                    .root_source_file = exe_options.root_source_file,
                    .target = exe_options.target,
                    .optimize = exe_options.optimize,
                    .link_libc = exe_options.link_libc,
                    .single_threaded = exe_options.single_threaded,
                    .pic = exe_options.pic,
                    .strip = exe_options.strip,
                    .unwind_tables = exe_options.unwind_tables,
                    .omit_frame_pointer = exe_options.omit_frame_pointer,
                    .sanitize_thread = exe_options.sanitize_thread,
                    .error_tracing = exe_options.error_tracing,
                    .code_model = exe_options.code_model,
                },
                .version = exe_options.version,
                .kind = .exe,
                .linkage = exe_options.linkage,
                .max_rss = exe_options.max_rss,
                .use_llvm = exe_options.use_llvm,
                .use_lld = exe_options.use_lld,
                .zig_lib_dir = exe_options.zig_lib_dir,
                .win32_manifest = exe_options.win32_manifest,
            };
        },
        else => { unreachable; }
    }    
}
