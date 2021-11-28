const std = @import("std");
const known = @import("known-folders");

const ConfigurationError = error{
    PrefixNotFound,
    DirectoryNotFound,
};

pub fn load(allocator: *std.mem.Allocator, prefix: []const u8) !u16 {
    var dir = try known.open(allocator, known.KnownFolder.home, .{});
    if (dir) |d| {
        const file = try d.openFile(".config/meacal/meacal.config", .{});
        defer file.close();

        while (file.reader().readUntilDelimiterAlloc(allocator, '\n', 1024)) |line| {
            var it = std.mem.tokenize(u8, line, ": ");
            if (std.mem.eql(u8, prefix, it.next().?)) {
                return try std.fmt.parseInt(u16, it.next().?, 10);
            }
        } else |_| {
            return ConfigurationError.PrefixNotFound;
        }
    } else {
        return ConfigurationError.DirectoryNotFound;
    }

    // Not sure if we can end up here.
    return ConfigurationError.PrefixNotFound;
}
