const std = @import("std");
const lx = @import("lexer.zig");
const config = @import("config.zig");

const meacal = @import("meacal.zig");

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = &arena.allocator;
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len != 3) {
        std.debug.print("usage: {s} prefix date\n", .{args[0]});
        return;
    }

    if (try config.load(allocator, args[1])) |config_item| {
        var lexer = try lx.Lexer.create(allocator, args[2]);
        // fixme: free

        const t0 = lexer.nextToken();
        const t1 = lexer.nextToken();
        const t2 = lexer.nextToken();
        const t3 = lexer.nextToken();
        const t4 = lexer.nextToken();

        if (t0.type_of != lx.TokenTypeOf.number or
            t1.type_of != lx.TokenTypeOf.dash or
            t2.type_of != lx.TokenTypeOf.number or
            t3.type_of != lx.TokenTypeOf.dash or
            t4.type_of != lx.TokenTypeOf.number)
        {
            std.debug.print("incorrect date {s}\n", .{args[1]});
            return;
        }

        var year = try lexer.parseInt(t0);
        var month = try lexer.parseInt(t2);
        var day = try lexer.parseInt(t4);

        meacal.toMeaCal(config_item.year, year, month, day);
    } else {
        std.debug.print("unable to load configuration\n", .{});
        return;
    }
}
