const std = @import("std");
const epoch = std.time.epoch;

const testing = std.testing;

const DateError = error{
    InvalidDate,
};

const Date = struct {
    year: u16,
    month: u8,
    day: u8,
};

const MeacalDate = struct {
    year: u8,
    month: u8,
    day: u8,
};

pub fn convertDateStringToDate(date_string: []const u8) !Date {
    var it = std.mem.tokenize(u8, date_string, "-");

    const year = try std.fmt.parseInt(u16, it.next().?, 10);
    const month = try std.fmt.parseInt(u8, it.next().?, 10);
    const day = try std.fmt.parseInt(u8, it.next().?, 10);

    if (month < 1 or month > 12) {
        return DateError.InvalidDate;
    }

    const leap_kind: epoch.YearLeapKind = if (epoch.isLeapYear(year)) .leap else .not_leap;
    const days_in_month = epoch.getDaysInMonth(
        leap_kind,
        try std.meta.intToEnum(epoch.Month, month),
    );

    if (day < 1 or day > days_in_month) {
        return DateError.InvalidDate;
    }

    return Date{
        .year = year,
        .month = month,
        .day = day,
    };
}

pub fn convertDateStringToMeacal(date_string: []const u8, base_year: u16) !MeacalDate {
    const target_date = try convertDateStringToDate(date_string);

    var month: usize = 1;
    var days: usize = 0;

    while (month < target_date.month) : (month += 1) {
        days += epoch.getDaysInMonth(
            epoch.YearLeapKind.not_leap,
            try std.meta.intToEnum(epoch.Month, month),
        );
    }

    days += target_date.day - 1;

    var p1: u8 = @intCast(u8, target_date.year - base_year);
    var p2: u8 = @intCast(u8, 65 + @divFloor(days, 14));
    // End of year fix.
    if (p2 == '[') {
        p2 = '+';
    }
    var p3 = @intCast(u8, @mod(days, 14));

    // Leap day fix.
    if (target_date.month == 2 and target_date.day == 29) {
        p2 = '+';
        p3 = 1;
    }

    return MeacalDate{
        .year = p1,
        .month = p2,
        .day = p3,
    };
}

test "Not leap year" {
    var md = try convertDateStringToMeacal("1968-07-10", 1968);
    try testing.expect(std.meta.eql(md, MeacalDate{ .year = 0, .month = 'N', .day = 8 }));

    md = try convertDateStringToMeacal("2021-01-01", 2021);
    try testing.expect(std.meta.eql(md, MeacalDate{ .year = 0, .month = 'A', .day = 0 }));

    md = try convertDateStringToMeacal("2021-07-10", 2021);
    try testing.expect(std.meta.eql(md, MeacalDate{ .year = 0, .month = 'N', .day = 8 }));

    md = try convertDateStringToMeacal("2020-02-28", 2020);
    try testing.expect(std.meta.eql(md, MeacalDate{ .year = 0, .month = 'E', .day = 2 }));

    md = try convertDateStringToMeacal("2020-02-29", 2020);
    try testing.expect(std.meta.eql(md, MeacalDate{ .year = 0, .month = '+', .day = 1 }));

    if (convertDateStringToMeacal("2021-02-29", 2021)) {} else |err| {
        try testing.expect(err == DateError.InvalidDate);
    }
}
