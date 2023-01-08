const std = @import("std");

const WINDOW_SIZE = 4;

// What I tried here is to solve the day in O(n) time and O(window_size) space.
// Meaning we only keep as many characters in memory as the size of the packet
// we're looking for. And we don't do any nested loops. I suspect that many
// people will just read the string into memory, use a window iterator and
// check if each window has only unique letters by iterating through the
// letters in some way. This code avoids this nested iteration by keeping track
// of how often any letter was seen.

pub fn main() !void {
    const stdin = std.io.getStdIn();
    // An array with as many slots as the alphabet has letters. The values are
    // the counts how often we've seen the given letter in the window.
    var seen = std.mem.zeroes([26]u8);
    var window = std.mem.zeroes([WINDOW_SIZE]u8);
    var i: u32 = 0;

    while (true) {
        const b = try stdin.reader().readByte();
        // If you "echo 'abc'" there will be a newline at the end, which is
        // effectively end-of-stream with regards to letters.
        if (b < 97 or b > 122) {
            return error.EndOfStream;
        }

        // At the start, we can just fill the window
        if (i < WINDOW_SIZE - 1) {
            window[i] = b;
        }

        seen[b - 'a'] += 1;

        if (i >= WINDOW_SIZE - 1) {
            var pass = true;
            comptime var window_j: usize = 0;
            inline while (window_j < WINDOW_SIZE - 1) : (window_j += 1) {
                if (seen[window[window_j] - 'a'] != 1) {
                    pass = false;
                    break;
                }
            }

            if (pass) {
                std.debug.print("{d}", .{i + 1});
                return;
            }

            seen[window[0] - 'a'] -= 1;
            // Shift window left. How can I verify that this inline is useful?
            comptime var window_i: usize = 0;
            inline while (window_i < WINDOW_SIZE - 2) : (window_i += 1) {
                window[window_i] = window[window_i + 1];
            }
            window[WINDOW_SIZE - 2] = b;
        }
        i += 1;
    }
}
