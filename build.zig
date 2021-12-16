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

    const exe = b.addExecutable("sdltest", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    if (target.isWindows()) {
        const sdl_path = "D:\\tmp\\SDL2-2.0.18\\";
        exe.addIncludeDir(sdl_path ++ "include");
        exe.addLibPath(sdl_path ++ "lib\\x64");
        b.installBinFile(sdl_path ++ "lib\\x64\\SDL2.dll", "SDL2.dll");
    }
    exe.linkSystemLibrary("SDL2");
    exe.linkSystemLibrary("c");
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
