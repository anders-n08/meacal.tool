const std = @import("std");
const epoch = std.time.epoch;

const config = @import("config.zig");
const date = @import("date.zig");

const stdout = std.io.getStdOut().writer();

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = &arena.allocator;

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len != 3) {
        try stdout.print("usage: {s} prefix date\n", .{args[0]});
        return;
    }

    const base_year = try config.load(allocator, args[1]);

    const md = try date.convertDateStringToMeacal(args[2], base_year);

    try stdout.print("{s}{:0>2}{c}{:0>2}\n", .{ args[1], md.year, md.month, md.day });
}
