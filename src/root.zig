const vector = @import("vector.zig");
const linkedlist = @import("linked_list.zig");
const std = @import("std");

test "vec testing" {
    var vec = vector.Vec(usize).init(std.testing.allocator);
    defer vec.deiniet();

    for (0..30) |i| {
        _ = try vec.pushBack(i);
    }
    vec.debugDisplay();
}

test "linked list testing" {
    var list = linkedlist.LinkedList(usize).init(std.testing.allocator);
    defer _ = list.deinit();

    for (0..5) |i| {
        _ = try list.pushBack(i * 1);
    }
    list.debugDisplay();
    for (0..5) |i| {
        _ = try list.pushFront(i * 3);
    }
    list.debugDisplay();

    std.debug.print("head value: {any}\n", .{list.popFront()});
    std.debug.print("tail value: {any}\n", .{list.popBack()});
    list.debugDisplay();
}
