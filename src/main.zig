const lib = @import("root.zig");
const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var world = try lib.World.build(600, 200, allocator);
    world.randomize();

    while (true) {
        try world.display();
        try world.update();

        std.Thread.sleep(1 * std.time.ns_per_ms);
    }
}
