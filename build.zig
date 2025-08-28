const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const cli_mod = b.addModule("cli", .{
        .root_source_file = b.path("src/cli.zig"),
        .target = target,
        .optimize = optimize,
    });

    const example_mod = b.createModule(.{
        .root_source_file = b.path("src/example.zig"),
        .target = target,
        .optimize = optimize,
    });
    example_mod.addImport("cli", cli_mod);
    
    const example_exe = b.addExecutable(.{
        .name = "example",
        .root_module = example_mod,
    });
    const run_example = b.addRunArtifact(example_exe);
    const test_step = b.step("run-example", "Run example");
    test_step.dependOn(&run_example.step);
}
