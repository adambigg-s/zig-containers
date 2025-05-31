const std = @import("std");

pub fn Vec(comptime T: type) type {
    return struct {
        data: []T,
        length: usize,
        capacity: usize,
        allocator: std.mem.Allocator,

        const Self = @This();
        const ReallocCondition: usize = 2;
        const ReallocSize: usize = 2;

        pub fn new(allocator: std.mem.Allocator) Self {
            return Vec(T){ .data = &[_]T{}, .length = 0, .capacity = 0, .allocator = allocator };
        }

        pub fn free(self: *Self) void {
            self.allocator.free(self.data);
        }

        pub fn initCapacity(self: *Self, capacity: usize) !*Self {
            self.data = try self.allocator.alloc(T, capacity);
            self.capacity = capacity;
            return self;
        }

        pub fn debugDisplay(self: *Self) void {
            std.debug.print("Vec:\n[ ", .{});
            for (0..self.length) |idx| {
                std.debug.print("{} ", .{self.data[idx]});
            }
            std.debug.print("]\n", .{});
        }

        pub fn splat(self: *Self, value: T) void {
            @memset(self.data, value);
        }

        pub fn pushBack(self: *Self, value: T) !void {
            if (self.length >= self.capacity / ReallocCondition) {
                try self.realloc(@max(ReallocSize * self.capacity, 1));
            }

            self.data[self.length] = value;
            self.length += 1;
        }

        fn realloc(self: *Self, capacity: usize) !void {
            const replacement = try self.allocator.alloc(T, capacity);
            @memcpy(replacement[0..self.length], self.data[0..self.length]);

            self.allocator.free(self.data);
            self.data = replacement;
            self.capacity = capacity;
        }
    };
}
