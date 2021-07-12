const std = @import("std");

pub const TokenTypeOf = enum { number, string, dash, pipe, colon, unknown, end_of_text };

pub const Lexer = struct {
    index: u64 = 0,
    text: []u8 = undefined,
    allocator: *std.mem.Allocator = undefined,

    pub fn create(allocator: *std.mem.Allocator, text: []const u8) std.mem.Allocator.Error!*Lexer {
        var self = try allocator.create(Lexer);
        errdefer allocator.destroy(self);

        self.* = .{
            .index = 0,
            .allocator = allocator,
        };

        self.text = try self.allocator.alloc(u8, text.len);
        std.mem.copy(u8, self.text, text);

        return self;
    }

    pub fn nextToken(self: *Lexer) Token {
        var token = Token{
            .start_index = self.index,
            .end_index = self.index,
        };

        var char_token_type_of: TokenTypeOf = TokenTypeOf.unknown;

        while (self.index < self.text.len) {
            if (std.ascii.isDigit(self.text[self.index])) {
                char_token_type_of = TokenTypeOf.number;
            } else if (std.ascii.isAlpha(self.text[self.index])) {
                char_token_type_of = TokenTypeOf.string;
            } else if (self.text[self.index] == '-') {
                char_token_type_of = TokenTypeOf.dash;
            } else if (self.text[self.index] == ':') {
                char_token_type_of = TokenTypeOf.colon;
            } else if (self.text[self.index] == '|') {
                char_token_type_of = TokenTypeOf.pipe;
            } else {
                char_token_type_of = TokenTypeOf.unknown;
            }

            if (token.type_of == TokenTypeOf.unknown) {
                token.type_of = char_token_type_of;
            }

            if ((token.type_of == TokenTypeOf.dash) or
                (token.type_of == TokenTypeOf.colon) or
                (token.type_of == TokenTypeOf.pipe))
            {
                // Triggers on the character and not on change.
                self.index += 1;
                return token;
            } else if (token.type_of != char_token_type_of) {
                return token;
            }

            self.index += 1;
            token.end_index = self.index;
        }

        return token;
    }

    pub fn parseInt(self: *Lexer, token: Token) anyerror!u64 {
        return std.fmt.parseInt(u64, self.text[token.start_index..token.end_index], 10);
    }

    pub fn getString(self: *Lexer, token: Token) []const u8 {
        return self.text[token.start_index..token.end_index];
    }
};

pub const Token = struct {
    start_index: u64 = 0,
    end_index: u64 = 0,
    type_of: TokenTypeOf = TokenTypeOf.unknown,
};
