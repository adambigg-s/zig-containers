const std = @import("std");

pub fn LinkedList(comptime T: type) type {
    return struct {
        head: ?*ListNode(T),
        tail: ?*ListNode(T),
        length: usize,
        allocator: std.mem.Allocator,

        const Self = @This();

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{ .head = null, .tail = null, .length = 0, .allocator = allocator };
        }

        pub fn deinit(self: *Self) void {
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

test "linked list testing" {
    var list = LinkedList(usize).init(std.testing.allocator);
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

pub fn Vec(comptime T: type) type {
    return struct {
        data: []T,
        length: usize,
        capacity: usize,
        allocator: std.mem.Allocator,

        const Self = @This();
        const ReallocCondition: usize = 2;
        const ReallocSize: usize = 2;

        pub fn init(allocator: std.mem.Allocator) Self {
            const data = [_]T{};
            return Self{ .data = &data, .length = 0, .capacity = 0, .allocator = allocator };
        }

        pub fn deiniet(self: *Self) void {
            self.allocator.free(self.data);
        }

        pub fn debugDisplay(self: *Self) void {
            std.debug.print("Vec:\n[ ", .{});
            for (0..self.length) |idx| {
                std.debug.print("{} ", .{self.data[idx]});
            }
            std.debug.print("]\n", .{});
        }

        pub fn initCapacity(self: *Self, capacity: usize) !void {
            self.data = try self.allocator.alloc(T, capacity);
            self.capacity = capacity;
        }

        pub fn pushBack(self: *Self, value: T) !void {
            self.data[self.length] = value;
            self.length += 1;

            if (self.length > self.capacity / ReallocCondition) {
                try self.realloc(@max(ReallocSize, 1));
            }
        }

        pub fn realloc(self: *Self, capacity: usize) !void {
            var replacement = try self.allocator.alloc(T, capacity);
            for (0..self.capacity, self.data) |idx, ele| {
                replacement[idx] = ele;
            }

            self.data = replacement;
        }
    };
}
