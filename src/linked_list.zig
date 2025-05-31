const std = @import("std");

pub fn LinkedList(comptime T: type) type {
    return struct {
        head: ?*ListNode(T),
        tail: ?*ListNode(T),
        length: usize,
        allocator: std.mem.Allocator,

        const Self = @This();

        pub fn new(allocator: std.mem.Allocator) Self {
            return LinkedList(T){ .head = null, .tail = null, .length = 0, .allocator = allocator };
        }

        pub fn free(self: *Self) void {
            var current = self.head;
            while (current) |node| {
                const next = node.next;
                self.allocator.destroy(node);
                current = next;
            }
            self.head = null;
            self.tail = null;
            self.length = 0;
        }

        pub fn debugDisplay(self: *Self) void {
            std.debug.print("LinkedList:\n[ ", .{});
            var current = self.head;
            while (current) |node| {
                std.debug.print("{} ", .{node.value});
                current = node.next;
            }
            std.debug.print("]\n", .{});
        }

        pub fn pushBack(self: *Self, value: T) !void {
            const node = try ListNode(T).build(value, self.allocator);

            if (self.length == 0) {
                self.head = node;
                self.tail = node;
            }
            self.tail.?.next = node;
            node.prev = self.tail;
            self.tail = node;

            self.length += 1;
        }

        pub fn pushFront(self: *Self, value: T) !void {
            const node = try ListNode(T).build(value, self.allocator);

            if (self.length == 0) {
                self.head = node;
                self.tail = node;
            }
            self.head.?.prev = node;
            node.next = self.head;
            self.head = node;

            self.length += 1;
        }

        pub fn popBack(self: *Self) ?T {
            if (self.length == 0) {
                return null;
            }

            const temp = self.tail.?;
            const value = self.tail.?.value;

            if (self.tail.?.prev) |prev| {
                prev.next = null;
                self.tail = prev;
            } else {
                self.head = null;
                self.tail = null;
            }

            self.allocator.destroy(temp);
            self.length -= 1;

            return value;
        }

        pub fn popFront(self: *Self) ?T {
            if (self.length == 0) {
                return null;
            }

            const temp = self.head.?;
            const value = self.head.?.value;

            if (self.head.?.next) |next| {
                next.prev = null;
                self.head = next;
            } else {
                self.head = null;
                self.tail = null;
            }

            self.allocator.destroy(temp);
            self.length -= 1;

            return value;
        }
    };
}

fn ListNode(comptime T: type) type {
    return struct {
        value: T,
        next: ?*ListNode(T),
        prev: ?*ListNode(T),

        const Self = @This();

        fn build(value: T, allocator: std.mem.Allocator) !*Self {
            const ptr = try allocator.create(Self);
            ptr.* = Self{ .value = value, .next = null, .prev = null };

            return ptr;
        }
    };
}
