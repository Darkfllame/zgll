const std = @import("std");

pub fn build(b: *std.Build) void {
    _ = b.addModule("gl", .{
        .root_source_file = b.path("src/GL.zig"),
    });
}
