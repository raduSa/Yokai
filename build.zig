const std = @import("std");
const OptimizeMode = std.builtin.OptimizeMode;
const ResolvedTarget = std.Build.ResolvedTarget;

const CXX_FLAGS = .{
    "-std=c++23",
    "-pedantic",
    "-Werror",
    "-Wall",
    "-Wextra",
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    build_repl(b, target, optimize);
    build_daemon(b, target, optimize);
    build_tests(b, target, optimize);
    // format_code();
    // build_docs(b, target, optimize);
}

fn build_repl(
    b: *std.Build,
    target: ResolvedTarget,
    optimize: OptimizeMode,
) void {
    const exe = b.addExecutable(.{
        .name = "yokai-repl",
        .target = target,
        .optimize = optimize,
        .use_llvm = false,
    });

    exe.linkLibCpp();

    const repl_files = .{
        "main.cpp",
        "../common/connection.cpp",
    };
    exe.addCSourceFiles(.{
        .root = b.path("repl"),
        .files = &(repl_files),
        .flags = &CXX_FLAGS,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run-repl", "Run the repl");
    run_step.dependOn(&run_cmd.step);
}

fn build_daemon(
    b: *std.Build,
    target: ResolvedTarget,
    optimize: OptimizeMode,
) void {
    const exe = b.addExecutable(.{
        .name = "yokai-daemon",
        .target = target,
        .optimize = optimize,
        .use_llvm = false,
    });

    exe.linkLibCpp();

    const daemon_files = .{
        "main.cpp",
        "../common/connection.cpp",
    };
    exe.addCSourceFiles(.{
        .root = b.path("daemon"),
        .files = &daemon_files,
        .flags = &CXX_FLAGS,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run-daemon", "Run the daemon");
    run_step.dependOn(&run_cmd.step);
}

fn build_tests(
    b: *std.Build,
    target: ResolvedTarget,
    optimize: OptimizeMode,
) void {
    const unit_tests = b.addExecutable(.{
        .name = "tests",
        .target = target,
        .optimize = optimize,
        .use_llvm = false,
    });

    unit_tests.linkLibCpp();

    const test_files = .{
        "main.cpp",
    };
    unit_tests.addCSourceFiles(.{
        .root = b.path("tests"),
        .files = &test_files,
        .flags = &CXX_FLAGS,
    });

    b.installArtifact(unit_tests);

    const test_cmd = b.addRunArtifact(unit_tests);
    test_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        test_cmd.addArgs(args);
    }

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&test_cmd.step);
}

fn build_docs(
    b: *std.Build,
    target: ResolvedTarget,
    optimize: OptimizeMode,
) void {
    _ = b;
    _ = target;
    _ = optimize;
    // https://ziglang.org/learn/build-system/#system-tools
}

fn format_code(
    b: *std.Build,
    target: ResolvedTarget,
    optimize: OptimizeMode,
) void {
    _ = b;
    _ = target;
    _ = optimize;
}
