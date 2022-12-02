const std = @import("std");

const map_one = std.ComptimeStringMap(u8, .{
    .{ "A X", 4 },
    .{ "A Y", 8 },
    .{ "A Z", 3 },
    .{ "B X", 1 },
    .{ "B Y", 5 },
    .{ "B Z", 9 },
    .{ "C X", 7 },
    .{ "C Y", 2 },
    .{ "C Z", 6 },
});

const map_two = std.ComptimeStringMap(u8, .{
    .{ "A X", 3 },
    .{ "A Y", 4 },
    .{ "A Z", 8 },
    .{ "B X", 1 },
    .{ "B Y", 5 },
    .{ "B Z", 9 },
    .{ "C X", 2 },
    .{ "C Y", 6 },
    .{ "C Z", 7 },
});

pub fn main() void {
    var buffer: [10000]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();
    const reader = std.io.getStdIn().reader();

    var score_one: usize = 0;
    var score_two: usize = 0;
    while (reader.readUntilDelimiterOrEofAlloc(allocator, '\n', 1000) catch |err| {
        std.debug.print("Awww {any}\n", .{err});
        return;
    }) |line| {
        score_one += map_one.get(line) orelse {
            std.debug.print("Map key missing: {s}!\n", .{line});
            return;
        };

        score_two += map_two.get(line) orelse {
            std.debug.print("Map key missing: {s}!\n", .{line});
            return;
        };
    }
    std.debug.print("{d};{d}", .{score_one, score_two});
}
