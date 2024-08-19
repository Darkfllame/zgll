const std = @import("std");

pub fn build(b: *std.Build) void {
    _ = b.addModule("zgll", .{
        .root_source_file = b.path("src/lib.zig"),
    });
}
