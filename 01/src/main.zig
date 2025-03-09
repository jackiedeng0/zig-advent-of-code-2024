const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    const gpa = std.heap.page_allocator;

    var args = try std.process.argsWithAllocator(gpa);
    defer args.deinit();

    const prog = args.next().?;
    const filename = args.next();
    if (filename == null) {
        std.debug.print("Usage: {s} filename\n", .{prog});
        return;
    }

    const file = try std.fs.cwd().openFile(filename.?, .{});
    defer file.close();

    const readBuf: []u8 = try gpa.alloc(u8, 20000);
    const sizeRead = try file.readAll(readBuf);
    const answer = try reconcileLists(gpa, readBuf[0..sizeRead]);
    std.debug.print("answer: {d}\n", .{answer});
}

fn abs(x: i33) u64 {
    var absX: u64 = undefined;
    if (x < 0) {
        absX = @intCast(-x);
    } else {
        absX = @intCast(x);
    }
    return absX;
}

pub fn reconcileLists(allocator: std.mem.Allocator, lists: []const u8) !u64 {
    var nums1 = std.ArrayList(u32).init(allocator);
    defer nums1.deinit();
    var nums2 = std.ArrayList(u32).init(allocator);
    defer nums2.deinit();

    var lineIt = std.mem.splitScalar(u8, lists, '\n');
    while (lineIt.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var spaceIt = std.mem.splitScalar(u8, line, ' ');

        var numStr: []const u8 = undefined;
        if (spaceIt.next()) |value| {
            numStr = value;
        } else {
            return error.SpaceItEmpty;
        }

        if (std.fmt.parseInt(u32, numStr, 10)) |value| {
            try nums1.append(value);
        } else |_| {
            print("Failed to parse '{s}'\n", .{numStr});
            return error.ParseIntFail;
        }

        while (spaceIt.next()) |value| {
            if (value.len != 0) {
                numStr = value;
                break;
            }
        } else {
            return error.SpaceItEmpty;
        }

        if (std.fmt.parseInt(u32, numStr, 10)) |value| {
            try nums2.append(value);
        } else |_| {
            print("Failed to parse '{s}'\n", .{numStr});
            return error.ParseIntFail;
        }
    }

    std.sort.heap(u32, nums1.items, {}, std.sort.asc(u32));
    std.sort.heap(u32, nums2.items, {}, std.sort.asc(u32));

    var total: u64 = 0;

    for (0..nums1.items.len) |i| {
        total += abs(@as(i33, nums1.items[i]) - @as(i33, nums2.items[i]));
    }
    return total;
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
    try std.testing.expectEqual(reconcileLists(std.testing.allocator, lists), 11);
}
