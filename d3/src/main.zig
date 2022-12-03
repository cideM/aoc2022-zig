const std = @import("std");
const io = std.io;

fn charScore(c: u8) usize {
    if (std.ascii.isLower(c)) {
        return c - 'a' + 1;
    } else {
        return c - 'A' + 27;
    }
}

pub fn main() !void {
    var buffer: [50000]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const alloc = fba.allocator();

    var score: usize = 0;
    var score_2: usize = 0;
    var triplet = std.ArrayList([]u8).init(alloc);
    defer triplet.deinit();

    const std_in_reader = io.getStdIn().reader();
    while (try std_in_reader.readUntilDelimiterOrEofAlloc(alloc, '\n', 10000)) |line| {
        const left = line[0 .. line.len / 2];
        const right = line[line.len / 2 ..];
        for (left) |c| {
            const needle = [_]u8{c};
            if (std.mem.indexOf(u8, right, &needle)) |_| {
                score += charScore(c);
                break;
            }
        }

        try triplet.append(line);

        if (triplet.items.len == 3) {
            for (triplet.items[0]) |c| {
                const needle = [_]u8{c};
                const found_1 = std.mem.containsAtLeast(u8, triplet.items[1], 1, &needle);
                const found_2 = std.mem.containsAtLeast(u8, triplet.items[2], 1, &needle);
                if (found_1 and found_2) {
                    score_2 += charScore(c);
                    break;
                }
            }
            triplet.clearAndFree();
        }
    }
    std.debug.print("{d};{d}\n", .{ score, score_2 });
}
