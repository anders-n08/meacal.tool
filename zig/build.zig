const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const meacal_exe = b.addExecutable("meacal.tool", "src/main.zig");
    meacal_exe.addIncludeDir("external/known-folders");
    meacal_exe.addPackage(.{
        .name = "known-folders",
        .path = .{ .path = "libs/known-folders/known-folders.zig" },
    });

    meacal_exe.setTarget(target);
    meacal_exe.setBuildMode(mode);
    meacal_exe.install();

    const d100_exe = b.addExecutable("d100.tool", "src/d100.zig");
    d100_exe.addIncludeDir("external/known-folders");
    d100_exe.addPackage(.{
        .name = "known-folders",
        .path = .{ .path = "libs/known-folders/known-folders.zig" },
    });
    d100_exe.setTarget(target);
    d100_exe.setBuildMode(mode);
    d100_exe.install();

    const run_cmd = meacal_exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
