const std = @import("std");

fn all_different(chars: []u8) bool {
    for (chars) |a, i| {
        for (chars[i + 1 ..]) |b| {
            if (a == b) {
                return false;
            }
        }
    }
    return true;
}

pub fn main() !void {
    var buf: [10000]u8 = undefined;
    const bytes_read = try std.io.getStdIn().reader().readAll(&buf);
    const line = buf[0..bytes_read];
    var p1: usize = 0;
    var p2: usize = 0;
    for (line) |_, i| {
        if (p1 == 0 and i >= 4 and all_different(line[i - 4 .. i])) {
            p1 = i;
        }
        if (p2 == 0 and i >= 14 and all_different(line[i - 14 .. i])) {
            p2 = i;
        }
    }
    std.debug.print("{d};{d}", .{ p1, p2 });
}
