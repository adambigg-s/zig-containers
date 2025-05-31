pub const vector = @import("vector.zig");
pub const linkedlist = @import("linked_list.zig");
pub const std = @import("std");

test "vec testing" {
    var vec = vector.Vec(usize).new(std.testing.allocator);
    defer vec.free();

    vec.debugDisplay();

    for (0..30) |i| {
        try vec.pushBack(i);
    }
    vec.debugDisplay();

    // this is just to see if it ever fails to allocate
    for (0..100_000_000) |_| {
        try vec.pushBack(1);
    }
    std.debug.print("value at 99 million: {}\n", .{vec.data[99_000_000]});
}

test "linked list testing" {
    var list = linkedlist.LinkedList(usize).new(std.testing.allocator);
    defer list.free();

    for (0..5) |i| {
        try list.pushBack(i * 1);
    }
    list.debugDisplay();

    for (0..5) |i| {
        try list.pushFront(i * 3);
    }
    list.debugDisplay();

    std.debug.print("head value: {any}\n", .{list.popFront()});
    std.debug.print("tail value: {any}\n", .{list.popBack()});
    list.debugDisplay();
}

pub const World = struct {
    width: usize,
    height: usize,
    curr: Buffer,
    next: Buffer,

    const Self = @This();
    const Dead: u8 = ' ';
    const Alive: u8 = '*';

    pub fn build(width: usize, height: usize, allocator: std.mem.Allocator) !Self {
        return World{
            .width = width,
            .height = height,
            .curr = try Buffer.build(width, height, allocator),
            .next = try Buffer.build(width, height, allocator),
        };
    }

    pub fn display(self: *Self) !void {
        try self.curr.display();
    }

    pub fn randomize(self: *Self) void {
        var rng = std.Random.DefaultPrng.init(0);
        for (0..self.height) |y| {
            for (0..self.width) |x| {
                const data: u8 = if (rng.next() % 2 == 0) Dead else Alive;
                self.curr.buffer.data[self.curr.index(x, y)] = data;
            }
        }
    }

    pub fn update(self: *Self) !void {
        for (0..self.height) |y| {
            for (0..self.width) |x| {
                const neighbors = self.countNeighbors(x, y);
                const here = self.curr.get(x, y);
                const replacement: u8 = switch (here.?) {
                    Alive => switch (neighbors) {
                        2, 3 => Alive,
                        else => Dead,
                    },
                    Dead => switch (neighbors) {
                        3 => Alive,
                        else => Dead,
                    },
                    else => Dead,
                };

                try self.next.set(x, y, replacement);
            }
        }

        self.flipGrids();
    }

    fn countNeighbors(self: *Self, x: usize, y: usize) usize {
        var count: usize = 0;

        var dx: isize = -1;
        while (dx <= 1) : (dx += 1) {
            var dy: isize = -1;
            while (dy <= 1) : (dy += 1) {
                if (dx == 0 and dy == 0) {
                    continue;
                }
                const idx = self.indexDelta(x, y, dx, dy);
                if (idx == null) {
                    continue;
                }
                if (self.curr.buffer.data[idx.?] == Alive) {
                    count += 1;
                }
            }
        }

        return count;
    }

    fn indexDelta(self: *Self, x: usize, y: usize, dx: isize, dy: isize) ?usize {
        const xisize: isize, const yisize: isize = .{ @intCast(x), @intCast(y) };
        const nx: isize, const ny: isize = .{ xisize + dx, yisize + dy };
        const xp: usize, const yp: usize = .{ @bitCast(nx), @bitCast(ny) };

        if (!self.curr.inbounds(xp, yp)) {
            return null;
        }
        return self.curr.index(xp, yp);
    }

    fn flipGrids(self: *Self) void {
        const next, const curr = .{ self.next, self.curr };
        self.next, self.curr = .{ curr, next };
    }
};

pub const Buffer = struct {
    width: usize,
    height: usize,
    buffer: vector.Vec(u8),

    const Self = @This();

    const BufferError = error{
        OutOfBounds,
    };

    pub fn build(width: usize, height: usize, allocator: std.mem.Allocator) !Self {
        var out = Buffer{
            .width = width,
            .height = height,
            .buffer = vector.Vec(u8).new(allocator),
        };
        _ = try out.buffer.initCapacity(out.width * out.height);
        out.clear();

        return out;
    }

    pub fn display(self: *Self) !void {
        const stdout = std.io.getStdOut().writer();
        var buffered_writer = std.io.bufferedWriter(stdout);
        const writer = buffered_writer.writer();

        try writer.print("\x1b[0H", .{});
        for (0..self.height) |y| {
            for (0..self.width) |x| {
                try writer.writeByte(self.buffer.data[self.index(x, y)]);
            }
            try writer.writeByte('\n');
        }

        try buffered_writer.flush();
    }

    pub fn clear(self: *Self) void {
        self.buffer.splat(' ');
    }

    pub fn get(self: *Self, x: usize, y: usize) ?u8 {
        if (!self.inbounds(x, y)) {
            return null;
        }
        return self.buffer.data[self.index(x, y)];
    }

    pub fn set(self: *Self, x: usize, y: usize, data: u8) !void {
        if (!self.inbounds(x, y)) {
            return BufferError.OutOfBounds;
        }
        self.buffer.data[self.index(x, y)] = data;
    }

    fn inbounds(self: *Self, x: usize, y: usize) bool {
        return x < self.width and y < self.height;
    }

    fn index(self: *Self, x: usize, y: usize) usize {
        return self.width * y + x;
    }
};
