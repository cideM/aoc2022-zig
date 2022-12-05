const std = @import("std");

pub fn main() !void {
    var buffer: [30000]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();
    const r = std.io.getStdIn().reader();

    var stacks = std.ArrayList(std.ArrayList(u8)).init(allocator);
    var stacks_2 = std.ArrayList(std.ArrayList(u8)).init(allocator);

    while (try r.readUntilDelimiterOrEofAlloc(allocator, '\n', 100)) |line| {
        if (stacks.items.len == 0) {
            const num_crates = ((line.len - 3) / 4) + 1;
            var i: u8 = 0;
            while (i < num_crates) : (i += 1) {
                var stack = std.ArrayList(u8).init(allocator);
                try stacks.append(stack);
                try stacks_2.append(stack);
            }
        }

        if (std.mem.containsAtLeast(u8, line, 1, "[")) {
            var stack_idx: u8 = 0;
            var i: u8 = 1;
            while (i <= line.len) : (i += 4) {
                const c: u8 = line[i];
                if (c != ' ') {
                    var stack = &stacks.items[stack_idx];
                    try stack.insert(0, c);

                    var stack_2 = &stacks_2.items[stack_idx];
                    try stack_2.insert(0, c);
                }
                stack_idx += 1;
            }
        }

        if (std.mem.containsAtLeast(u8, line, 1, "move")) {
            var split_iter = std.mem.split(u8, line, " ");
            _ = split_iter.next();
            const amount = try std.fmt.parseInt(usize, split_iter.next().?, 10);
            _ = split_iter.next();
            var from = try std.fmt.parseInt(usize, split_iter.next().?, 10);
            _ = split_iter.next();
            var to = try std.fmt.parseInt(usize, split_iter.next().?, 10);
            from -= 1;
            to -= 1;

            var source = &stacks.items[from];
            var dest = &stacks.items[to];
            var items = source.items[source.items.len - amount ..];
            std.mem.reverse(u8, items);
            try dest.appendSlice(items);
            source.shrinkAndFree(source.items.len - amount);

            var source_2 = &stacks_2.items[from];
            var dest_2 = &stacks_2.items[to];
            var items_2 = source_2.items[source_2.items.len - amount ..];
            try dest_2.appendSlice(items_2);
            source_2.shrinkAndFree(source_2.items.len - amount);
        }
    }

    std.debug.print("p1:\n", .{});
    for (stacks.items) |*stack| {
        std.debug.print("{c}", .{stack.pop()});
    }

    std.debug.print("\np2:\n", .{});
    for (stacks_2.items) |*stack| {
        std.debug.print("{c}", .{stack.pop()});
    }
}
