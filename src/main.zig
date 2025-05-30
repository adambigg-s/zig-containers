const std = @import("std");
const lib = @import("root.zig");

pub fn main() !void {}

test "vec testing" {
    var vec = lib.Vec(usize).init(std.testing.allocator);
    defer vec.deiniet();

    for (0..5) |i| {
        _ = try vec.pushBack(i);
    }
    vec.debugDisplay();
}
