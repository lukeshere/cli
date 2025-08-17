const std = @import("std");
const cli = @import("cli.zig");

pub const methods = struct {
    pub const commands = struct {
        pub fn helloFn(_options: []const cli.Option) bool {
            var greeting: []const u8 = undefined;
            var name: []const u8 = "World";

            for (_options) |opt| {
                if (std.mem.eql(u8, opt.name, "greeting")) {
                    greeting = opt.value;
                } else if (std.mem.eql(u8, opt.name, "name")) {
                    if (opt.value.len > 0) {
                        name = opt.value;
                    }
                }
            }

            cli.printColored(.Green, "{s}, ", .{greeting});
            cli.printColored(.Cyan, "{s}", .{name});
            cli.printColored(.Yellow, "!\n", .{});
            return true;
        }

        // Handler for the "help" command
        pub fn helpFn(_: []const cli.Option) bool {
            std.debug.print("Usage: my-cli <command> [options]\n" ++
                "Commands:\n" ++
                "  hello    Greet someone\n" ++
                "  help     Show this help message\n" ++
                "" ++
                "Options for hello:\n" ++
                "  -n, --name <value>    Name to greet\n", .{});
            return true;
        }
    };

    pub const options = struct {
        // Handler for the "name" option
        pub fn nameFn(_: []const u8) bool {
            // Option-specific logic could go here
            return true;
        }

        pub fn greetingFn(_: []const u8) bool {
            return true;
        }
    };
};
