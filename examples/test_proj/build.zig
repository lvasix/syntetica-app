const std = @import("std");

pub fn build(b: *std.Build) void {
    const main_module = b.addModule("main", .{
        .root_source_file = b.path("src/main.zig"),
    });

    const exe = b.addExecutable(.{
        .name = "main",
        .root_module = main_module,
    });

    b.installArtifact(exe);
    const run_artf = b.addRunArtifact(exe);

    const run_step = b.step("run", "");
    run_step.dependOn(run_artf.step);
}
