const std = @import("std");

fn isLeapYear(year: u64) bool {
    return ((year) % 4 == 0 and ((year) % 100 != 0 or (year) % 400 == 0));
}

pub fn toMeaCal(base_year: u64, year: u64, month: u64, day: u64) void {
    var number_of_days: u64 = switch (month) {
        1 => 0,
        2 => 31,
        3 => 31 + 28,
        4 => 31 + 28 + 31,
        5 => 31 + 28 + 31 + 30,
        6 => 31 + 28 + 31 + 30 + 31,
        7 => 31 + 28 + 31 + 30 + 31 + 30,
        8 => 31 + 28 + 31 + 30 + 31 + 30 + 31,
        9 => 31 + 28 + 31 + 30 + 31 + 30 + 31 + 31,
        10 => 31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30,
        11 => 31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30 + 31,
        12 => 31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30 + 31 + 30,
        else => {
            std.debug.print("invalid month {}\n", .{month});
            return;
        },
    };

    // magic number - 0 index
    number_of_days += day - 1;

    var p1: u64 = @intCast(u64, year) - base_year;
    var p2: u8 = @intCast(u8, 65 + @divFloor(number_of_days, 14));
    if (p2 == '[') {
        p2 = '+';
    }
    var p3 = @intCast(u8, @mod(number_of_days, 14));

    if (isLeapYear(year) and (month == 2) and (day == 29)) {
        p2 = '+';
        p3 = 1;
    }

    std.debug.print("A{:0>2}{c}{:0>2}\n", .{ p1, p2, p3 });
}
