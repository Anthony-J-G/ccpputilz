const std = @import("std");




pub fn generateDocumentation(step: *std.Build.Step.Compile) !void {
    _ = step.root_module.link_objects;
}


test "aaaaaa" {

}
