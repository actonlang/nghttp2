const std = @import("std");
const print = @import("std").debug.print;

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});
    //const t = target.result;

    var flags = std.ArrayList([]const u8).init(b.allocator);
    defer flags.deinit();

    const lib = b.addStaticLibrary(.{
        .name = "nghttp2",
        .target = target,
        .optimize = optimize,
    });
    lib.addIncludePath(b.path("./lib"));
    lib.addIncludePath(b.path("./lib/includes"));
    //lib.addIncludePath(.{ .cwd_relative = "/usr/include" });

            //#define NGHTTP2_NORETURN __attribute__((noreturn))
    const config_header = b.addConfigHeader(
        .{
            .style = .blank,
        },
        .{
            .HAVE_STD_MAP_EMPLACE = true,
            .HAVE_LIBXML2 = true,
            .HAVE__EXIT = true,
            .HAVE_ACCEPT4 = true,
            .HAVE_CLOCK_GETTIME = true,
            .HAVE_MKOSTEMP = true,
            .HAVE_PIPE2 = true,
            .HAVE_DECL_INITGROUPS = true,
            .HAVE_DECL_CLOCK_MONOTONIC = true,
            .HAVE_ARPA_INET_H = true,
            .HAVE_FCNTL_H = true,
            .HAVE_INTTYPES_H = true,
            .HAVE_LIMITS_H = true,
            .HAVE_NETDB_H = true,
            .HAVE_NETINET_IN_H = true,
            .HAVE_NETINET_IP_H = true,
            .HAVE_PWD_H = true,
            .HAVE_SYS_SOCKET_H = true,
            .HAVE_SYS_TIME_H = true,
            .HAVE_SYSLOG_H = true,
            .HAVE_UNISTD_H = true,
            .NOTHREADS = true,
        },
    );
    lib.addConfigHeader(config_header);

    const version_header = b.addConfigHeader(
        .{
            .style = .{ .cmake = b.path("lib/includes/nghttp2/nghttp2ver.h.in") },
            .include_path = "nghttp2/nghttp2ver.h",
        },
        .{
            .PACKAGE_VERSION = "1.63.0",
            .PACKAGE_VERSION_NUM = 0x013f00,
        },
    );
    lib.addConfigHeader(version_header);

    flags.appendSlice(&.{
        "-DHAVE_CONFIG_H",
    }) catch unreachable;

    const source_files = [_][]const u8{
        "lib/nghttp2_pq.c",
        "lib/nghttp2_map.c",
        "lib/nghttp2_queue.c",
        "lib/nghttp2_frame.c",
        "lib/nghttp2_buf.c",
        "lib/nghttp2_stream.c",
        "lib/nghttp2_outbound_item.c",
        "lib/nghttp2_session.c",
        "lib/nghttp2_submit.c",
        "lib/nghttp2_helper.c",
        "lib/nghttp2_alpn.c",
        "lib/nghttp2_hd.c",
        "lib/nghttp2_hd_huffman.c",
        "lib/nghttp2_hd_huffman_data.c",
        "lib/nghttp2_version.c",
        "lib/nghttp2_priority_spec.c",
        "lib/nghttp2_option.c",
        "lib/nghttp2_callbacks.c",
        "lib/nghttp2_mem.c",
        "lib/nghttp2_http.c",
        "lib/nghttp2_rcbuf.c",
        "lib/nghttp2_extpri.c",
        "lib/nghttp2_ratelim.c",
        "lib/nghttp2_time.c",
        "lib/nghttp2_debug.c",
        "lib/sfparse.c"
    };

    lib.linkLibC();
    lib.linkLibCpp();
    lib.installHeader(b.path("lib/includes/nghttp2/nghttp2.h"), "nghttp2/nghttp2.h");
    lib.addCSourceFiles(.{
        .files = &source_files,
        .flags = flags.items,
    });

    b.installArtifact(lib);
}
