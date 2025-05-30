const std = @import("std");

pub fn LinkedList(comptime T: type) type {
    return struct {
        head: ?*ListNode(T),
        length: usize,
        allocator: std.mem.Allocator,

        const Self = @This();

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{ .head = null, .length = 0, .allocator = allocator };
        }

        pub fn debugDisplay(self: *Self) void {
            std.debug.print("[", .{});
            while (self.head != null) : (self.head = self.head.?.next) {
                std.debug.print("{}, ", .{self.head.?.data});
            }
            std.debug.print("]", .{});
        }

        pub fn push(self: *Self, value: T) !void {
            var node = try ListNode(T).build(self.allocator);
            node.data = value;

            if (self.head != null) {
                self.head.?.next = node;
            } else {
                self.head = node;
            }
            self.length += 1;
        }
    };
}

fn ListNode(comptime T: type) type {
    return struct {
        data: T,
        next: ?*ListNode(T),

        const Self = @This();

        fn build(allocator: std.mem.Allocator) !*Self {
            return try allocator.create(Self);
        }
    };
}
