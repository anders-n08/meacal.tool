const std = @import("std");
const known = @import("known-folders");
const lx = @import("lexer.zig");

const ConfigItem = struct {
    prefix: []const u8,
    year: u64,
};

pub fn load(allocator: *std.mem.Allocator, prefix: []const u8) !?ConfigItem {
    var dir = try known.open(allocator, known.KnownFolder.home, .{});
    if (dir) |d| {
        const fp = try d.openFile(".config/meacal/meacal.config", .{});

        var buffer: [100]u8 = undefined;
        try fp.seekTo(0);
        // const bytes_read = try fp.readAll(&buffer);

        while (true) blk: {
            if (try fp.reader().readUntilDelimiterOrEof(buffer[0..], '\n')) |line| {
                var lexer = try lx.Lexer.create(allocator, line);

                const t0 = lexer.nextToken();
                const t1 = lexer.nextToken();
                const t2 = lexer.nextToken();
                const t3 = lexer.nextToken();
                const t4 = lexer.nextToken();
                const t5 = lexer.nextToken();
                const t6 = lexer.nextToken();
                const t7 = lexer.nextToken();
                const t8 = lexer.nextToken();

                if (t0.type_of != lx.TokenTypeOf.string or
                    t1.type_of != lx.TokenTypeOf.exclamation_mark or
                    t2.type_of != lx.TokenTypeOf.string or
                    t3.type_of != lx.TokenTypeOf.colon or
                    t4.type_of != lx.TokenTypeOf.string or
                    t5.type_of != lx.TokenTypeOf.pipe or
                    t6.type_of != lx.TokenTypeOf.string or
                    t7.type_of != lx.TokenTypeOf.colon or
                    t8.type_of != lx.TokenTypeOf.number)
                {
                    break :blk;
                }

                const prefix_lc = try std.ascii.allocLowerString(allocator, prefix);
                defer allocator.free(prefix_lc);

                if (std.mem.eql(u8, lexer.getString(t0), prefix_lc)) {
                    return ConfigItem{
                        .prefix = lexer.getString(t4),
                        .year = lexer.parseInt(t8) catch 2000,
                    };
                }
            } else {
                break;
            }
        }
    }

    return null;
}
