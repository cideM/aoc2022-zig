const std = @import("std");

pub fn main() !void {
    var buffer: [50000]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    var dirs = std.StringHashMap(usize).init(allocator);
    var stack = std.ArrayList([]const u8).init(allocator);

    const r = std.io.getStdIn().reader();
    while (try r.readUntilDelimiterOrEofAlloc(allocator, '\n', 1000)) |line| {
        if (std.fmt.parseInt(u8, line[0..1], 10)) |_| {
            var path: []u8 = "";
            for (stack.items) |dir| {
                var iter = std.mem.tokenize(u8, line, " ");
                path = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ path, dir });
                const new_size = try std.fmt.parseInt(usize, iter.next().?, 10);
                const cur_size = dirs.get(path) orelse 0;
                try dirs.put(path, cur_size + new_size);
            }
            continue;
        } else |_| {}

        if (std.mem.eql(u8, line, "$ cd /")) {
            stack.clearAndFree();
            try stack.append("root");
            continue;
        }

        if (std.mem.eql(u8, line, "$ cd ..")) {
            _ = stack.pop();
            continue;
        }

        if (std.mem.startsWith(u8, line, "$ cd ")) {
            var iter = std.mem.tokenize(u8, line, " ");
            _ = iter.next();
            _ = iter.next();
            const dir = iter.next().?;
            try stack.append(dir);
            continue;
        }
    }

    var iter = dirs.iterator();
    var sum: usize = 0;
    var min: usize = std.math.maxInt(usize);
    const root_size = dirs.get("/root").?;
    while (iter.next()) |kv| {
        if (kv.value_ptr.* <= 100000) {
            sum += kv.value_ptr.*;
        }

        if (70000000 - root_size + kv.value_ptr.* > 30000000) {
            min = std.math.min(kv.value_ptr.*, min);
        }
    }
    std.debug.print("{d};{d}", .{ sum, min });
}
