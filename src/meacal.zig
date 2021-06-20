const std = @import("std");

const MeaCalDate = struct {
    year: u8,
    month: u8,
    day: u8,
};

fn isLeapYear(year: u64) bool {
    return ((year) % 4 == 0 and ((year) % 100 != 0 or (year) % 400 == 0));
}

pub fn toMeaCalWithOffset(base_year: u64, year: u64, month: u64, day: u64, offset: u64) MeaCalDate {
    var adjusted_year = year;

    var meacal_date: MeaCalDate = .{
        .year = 0,
        .month = 'A',
        .day = 0,
    };

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
            return meacal_date;
        },
    };

    // magic number - 0 index
    number_of_days += day - 1 + offset;

    if (number_of_days >= 365) {
        number_of_days -= 365;
        adjusted_year += 1;
    }

    var p1: u8 = @intCast(u8, adjusted_year - base_year);
    var p2: u8 = @intCast(u8, 65 + @divFloor(number_of_days, 14));
    if (p2 == '[') {
        p2 = '+';
    }
    var p3 = @intCast(u8, @mod(number_of_days, 14));

    if (isLeapYear(adjusted_year) and (month == 2) and (day == 29)) {
        p2 = '+';
        p3 = 1;
    }

    meacal_date.year = p1;
    meacal_date.month = p2;
    meacal_date.day = p3;

    return meacal_date;
}

pub fn toMeaCal(base_year: u64, year: u64, month: u64, day: u64) MeaCalDate {
    return toMeaCalWithOffset(base_year, year, month, day, 0);
}
