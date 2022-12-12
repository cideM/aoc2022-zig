const std = @import("std");
const Big_Int = std.math.big.int.Managed;

const Monkey = struct {
    count: usize,
    items: std.ArrayList(Big_Int),
    op: WorryAdjust,
    divisible_by: Big_Int,
    if_true: usize,
    if_false: usize,
};

const Op = enum { add, mul };
const WorryAdjust = struct {
    rhs: ?Big_Int,
    op: Op,
    fn run(self: WorryAdjust, alloc: std.mem.Allocator, n: Big_Int) !Big_Int {
        var left = n;
        var right: Big_Int = undefined;
        if (self.rhs) |num| {
            right = num;
        } else {
            right = left;
        }
        var result = try Big_Int.init(alloc);
        switch (self.op) {
            Op.add => {
                try Big_Int.add(&result, &left, &right);
            },
            Op.mul => {
                try Big_Int.mul(&result, &left, &right);
            },
        }
        return result;
    }
};

fn parseOperation(alloc: std.mem.Allocator, op_str: *const [1]u8, rhs_str: []const u8) !WorryAdjust {
    var op: Op = undefined;
    if (std.mem.eql(u8, op_str, "+")) {
        op = Op.add;
    } else if (std.mem.eql(u8, op_str, "*")) {
        op = Op.mul;
    } else {
        unreachable;
    }

    var rhs: ?Big_Int = undefined;
    if (std.mem.eql(u8, rhs_str, "old")) {
        rhs = null;
    } else {
        const rhs_usize = try std.fmt.parseInt(usize, rhs_str, 10);
        rhs = try Big_Int.initSet(alloc, rhs_usize);
    }

    return WorryAdjust{
        .rhs = rhs,
        .op = op,
    };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    const r = std.io.getStdIn().reader();
    const input = try r.readAllAlloc(alloc, 10000);

    var monkeys = std.ArrayList(Monkey).init(alloc);

    var monkey_iter = std.mem.split(u8, input, "\n\n");
    while (monkey_iter.next()) |line| {
        var line_iter = std.mem.split(u8, line, "\n");
        _ = line_iter.next();

        var items = std.ArrayList(Big_Int).init(alloc);
        const items_str = line_iter.next().?[18..];
        var items_iter = std.mem.split(u8, items_str, ", ");
        while (items_iter.next()) |item| {
            const item_num = try std.fmt.parseInt(usize, item, 10);
            const big_int = try Big_Int.initSet(alloc, item_num);
            try items.append(big_int);
        }

        var op_str = line_iter.next().?;
        const op = op_str[23..24];
        const rhs = op_str[25..];
        const worry_adjust = try parseOperation(alloc, op, rhs);
        const divisible_by = try std.fmt.parseInt(usize, line_iter.next().?[21..], 10);
        const divisible_by_big = try Big_Int.initSet(alloc, divisible_by);

        const if_true = try std.fmt.parseInt(usize, line_iter.next().?[29..], 10);
        const if_false = try std.fmt.parseInt(usize, line_iter.next().?[30..], 10);

        const m: Monkey = Monkey{
            .count = 0,
            .items = items,
            .op = worry_adjust,
            .divisible_by = divisible_by_big,
            .if_true = if_true,
            .if_false = if_false,
        };

        try monkeys.append(m);
    }

    var monkeys_1 = try monkeys.clone();
    for (monkeys_1.items) |*m| {
        m.items = try m.items.clone();
    }

    try simulate(alloc, 20, manageP1, monkeys_1);
    try monkeyBusiness(alloc, monkeys_1);

    var monkeys_2 = try monkeys.clone();
    for (monkeys_2.items) |*m| {
        m.items = try m.items.clone();
    }

    try simulate(alloc, 10000, manageP2, monkeys_2);
    try monkeyBusiness(alloc, monkeys_2);
}

const Errors = Big_Int.ConvertError || error{OutOfMemory};

const Manage_Fn = *const fn (std.mem.Allocator, *Big_Int) Errors!Big_Int;

fn simulate(alloc: std.mem.Allocator, rounds: usize, manageWorry: Manage_Fn, monkeys: std.ArrayList(Monkey)) !void {
    var round: usize = 1;
    while (round <= rounds) : (round += 1) {
        std.debug.print("{d}/{d}\n", .{ round, rounds });
        for (monkeys.items) |*m| {
            for (m.items.items) |worry, i| {
                m.count += 1;
                var new_worry = try m.op.run(alloc, worry);
                var managed_worry = try manageWorry(alloc, &new_worry);
                m.items.items[i] = managed_worry;

                var result = try Big_Int.init(alloc);
                var rem = try Big_Int.init(alloc);
                var zero = try Big_Int.initSet(alloc, 0);
                try Big_Int.divFloor(&result, &rem, &managed_worry, &m.divisible_by);
                const target_i = if (Big_Int.eq(rem, zero)) m.if_true else m.if_false;
                rem.deinit();
                zero.deinit();
                result.deinit();
                try monkeys.items[target_i].items.append(managed_worry);
            }
            m.items.clearAndFree();
        }
    }
}

fn manageP1(alloc: std.mem.Allocator, n: *Big_Int) !Big_Int {
    var result = try Big_Int.init(alloc);
    var rem = try Big_Int.init(alloc);
    defer rem.deinit();
    var three = try Big_Int.initSet(alloc, 3);
    defer three.deinit();
    try Big_Int.divFloor(&result, &rem, n, &three);
    n.deinit();
    return result;
}

fn manageP2(_: std.mem.Allocator, n: *Big_Int) !Big_Int {
    return n.*;
}

fn monkeyBusiness(alloc: std.mem.Allocator, monkeys: std.ArrayList(Monkey)) !void {
    var counts = std.ArrayList(usize).init(alloc);
    defer counts.deinit();
    for (monkeys.items) |m| {
        try counts.append(m.count);
    }
    std.sort.sort(usize, counts.items, {}, comptime std.sort.desc(usize));
    std.debug.print("{d}", .{counts.items[0] * counts.items[1]});
}
