const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
   print("Run test instead!\n", .{});
}

pub fn reconcileLists(lists: []const u8) !u32 {
    var fbs = std.io.FixedBufferStream(lists);
    var reader = fbs.reader();
    var line_buffer: [1024]u8 = undefined;

    while (true) {
        const line = try reader.readUntilDelimiterOrEof(buf: []u8, delimiter: u8)
    }
}

test "simple test" {
    // String literal syntax
    const lists =
        \\3   4
        \\4   3
        \\2   5
        \\1   3
        \\3   9
        \\3   3
    ;
    try std.testing.expectEqual(reconcileLists(lists), 11);
}
