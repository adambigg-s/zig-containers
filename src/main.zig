const std = @import("std");
const lib = @import("root.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var list = lib.LinkedList(i32).init(allocator);
    _ = try list.push(10);
    list.debugDisplay();
}
