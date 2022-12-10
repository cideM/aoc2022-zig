const std = @import("std");

const Grid = struct {
    rows: std.ArrayList(std.ArrayList(u8)),
    fn get(self: Grid, x: isize, y: isize) usize {
        return self.rows.items[@bitCast(usize, y)].items[@bitCast(usize, x)];
    }
};

pub fn main() !void {
    var buffer: [30000]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const alloc = fba.allocator();
    const r = std.io.getStdIn().reader();

    var grid = Grid{ .rows = std.ArrayList(std.ArrayList(u8)).init(alloc) };
    while (try r.readUntilDelimiterOrEofAlloc(alloc, '\n', 1000)) |line| {
        var row = std.ArrayList(u8).init(alloc);
        for (line) |c| {
            try row.append(try std.fmt.parseInt(u8, &[1]u8{c}, 10));
        }
        try grid.rows.append(row);
    }

    var trees_visible: usize = 0;
    var max_view: usize = 0;

    var row_num: isize = 0;
    while (row_num < grid.rows.items.len) : (row_num += 1) {
        // So why cast isize to usize here?
        // Let's say we're looking at a tree in the 1th row (0-based arrays). I
        // need to now check the tree above it, so I'll start at row - 1 and
        // then keep going up. I want to stop iterating **after** I've looked
        // at the top most row, which here has index 0.
        // while (row > 0) : (row -= 1) {}
        // But what if you're looking at a tree in the 0th row? You'll get a
        // panic because of integer overflow when you look at the row above and
        // do row - 1
        // I've tried various approaches but could never find something elegant
        // :(
        const row_num_signed = @bitCast(usize, row_num);
        var col_num: isize = 0;
        while (col_num < grid.rows.items[row_num_signed].items.len) : (col_num += 1) {
            const height = grid.get(col_num, row_num);
            var num_directions_visible: u8 = 4;

            var top: usize = 0;
            var top_row = row_num - 1;
            while (top_row >= 0) : ({
                top_row -= 1;
                top += 1;
            }) {
                if (grid.get(col_num, top_row) >= height) {
                    num_directions_visible -= 1;
                    break;
                }
            }

            var bottom: usize = 0;
            var bottom_row = row_num + 1;
            while (bottom_row < grid.rows.items.len) : ({
                bottom_row += 1;
                bottom += 1;
            }) {
                if (grid.get(col_num, bottom_row) >= height) {
                    num_directions_visible -= 1;
                    break;
                }
            }

            var left: usize = 0;
            var left_col = col_num - 1;
            while (left_col >= 0) : ({
                left_col -= 1;
                left += 1;
            }) {
                if (grid.get(left_col, row_num) >= height) {
                    num_directions_visible -= 1;
                    break;
                }
            }

            var right: usize = 0;
            var right_col = col_num + 1;
            while (right_col < grid.rows.items[row_num_signed].items.len) : ({
                right_col += 1;
                right += 1;
            }) {
                if (grid.get(right_col, row_num) >= height) {
                    num_directions_visible -= 1;
                    break;
                }
            }

            trees_visible += if (num_directions_visible > 0) 1 else 0;
            max_view = std.math.max(max_view, top * bottom * left * right);
        }
    }

    std.debug.print("{d};{d}", .{ trees_visible, max_view });
}
