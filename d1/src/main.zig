const std = @import("std");
const io = std.io;

pub fn main() !void {
    var buffer: [5000]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const alloc = fba.allocator();

    var sums = std.ArrayList(usize).init(alloc);
    try sums.append(0);

    var line_buffer: [50]u8 = undefined;
    while (try io.getStdIn().reader().readUntilDelimiterOrEof(&line_buffer, '\n')) |line| {
        if (std.mem.eql(u8, line, "")) {
            try sums.append(0);
            continue;
        }
        var last = sums.pop();
        const num = try std.fmt.parseInt(usize, line, 10);
        try sums.append(last + num);
    }

    std.sort.sort(usize, sums.items, {}, comptime std.sort.desc(usize));
    std.debug.print("{d}\n", .{sums.items[0]});
    std.debug.print("{d}\n", .{sums.items[0] + sums.items[1] + sums.items[2]});
}
