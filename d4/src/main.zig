const std = @import("std");
const io = std.io;

pub fn main() !void {
    var buffer: [15000]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const alloc = fba.allocator();

    var score: usize = 0;
    var score2: usize = 0;
    const std_in_reader = io.getStdIn().reader();
    while (try std_in_reader.readUntilDelimiterOrEofAlloc(alloc, '\n', 10000)) |line| {
        var pairs_iter = std.mem.split(u8, line, ",");
        const left = pairs_iter.next().?;
        const right = pairs_iter.next().?;

        var left_pair_iter = std.mem.split(u8, left, "-");
        const a1 = try std.fmt.parseInt(u8, left_pair_iter.next().?, 10);
        const a2 = try std.fmt.parseInt(u8, left_pair_iter.next().?, 10);

        var right_pair_iter = std.mem.split(u8, right, "-");
        const b1 = try std.fmt.parseInt(u8, right_pair_iter.next().?, 10);
        const b2 = try std.fmt.parseInt(u8, right_pair_iter.next().?, 10);

        if ((a1 <= b1 and a2 >= b2) or (b1 <= a1 and b2 >= a2)) {
            score = score + 1;
        }

        if (a1 <= b2 and b1 <= a2) {
            score2 = score2 + 1;
        }
    }
    std.debug.print("{d};{d}\n", .{ score, score2 });
}
