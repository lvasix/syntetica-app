const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const syntetica_app = b.addExecutable(.{
        .name = "syntetica_app",
        .root_module = b.addModule("syntetica_app", .{
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const syntetica_core_dep = b.dependency("Syntetica_Engine", .{
        .target = target,
        .optimize = optimize,
    });

    syntetica_app.root_module.addImport("syntetica_core", syntetica_core_dep.module("syntetica_core"));

    const run_app_step = b.addRunArtifact(syntetica_app);

    const app_step = b.step("run", "Run the game engine application");
    app_step.dependOn(&syntetica_app.step);
    app_step.dependOn(&run_app_step.step);
}
