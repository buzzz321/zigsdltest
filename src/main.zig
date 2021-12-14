const c = @cImport({
    @cInclude("SDL2/SDL.h");
});
const std = @import("std");
const math = @import("std").math;
const WINDOW_WIDTH: i32 = 1024;
const WINDOW_HEIGHT: i32 = 768;

const Star = struct {
    x: f32,
    y: f32,
    delta: f32,
    r: u8,
    g: u8,
    b: u8,

    pub fn init3(x: f32, y: f32, delta: f32) Star {
        return Star{
            .x = x,
            .y = y,
            .delta = delta,
            .r = 0xff,
            .g = 0xff,
            .b = 0xff,
        };
    }
    pub fn init2(x: f32, y: f32) Star {
        return Star{
            .x = x,
            .y = y,
            .delta = (@intToFloat(f32, WINDOW_WIDTH / 2) - x) / (@intToFloat(f32, WINDOW_HEIGHT / 2) - y),
            .r = 0xff,
            .g = 0xff,
            .b = 0xff,
        };
    }
};

pub fn main() anyerror!void {
    std.log.info("A small sdl test.", .{});

    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    const screen = c.SDL_CreateWindow("My Game Window", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, WINDOW_WIDTH, WINDOW_HEIGHT, c.SDL_RENDERER_PRESENTVSYNC | c.SDL_RENDERER_ACCELERATED) orelse
        {
        c.SDL_Log("Unable to create window: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyWindow(screen);

    const renderer = c.SDL_CreateRenderer(screen, -1, 0) orelse {
        c.SDL_Log("Unable to create renderer: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyRenderer(renderer);

    _ = c.SDL_RenderClear(renderer);
    _ = c.SDL_RenderPresent(renderer);
    var quit = false;
    var pos_x: i32 = 0;
    var pos_y: i32 = WINDOW_HEIGHT / 2;
    var star = Star.init2(@intToFloat(f32, WINDOW_WIDTH / 2) + 10.0, @intToFloat(f32, WINDOW_HEIGHT / 2) + 10.0);
    std.debug.print("-> {d}\n", .{star});
    while (!quit) {
        _ = c.SDL_SetRenderDrawColor(renderer, 0x00, 0x00, 0x00, 0x00);
        _ = c.SDL_RenderClear(renderer);
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.@"type") {
                c.SDL_QUIT => {
                    quit = true;
                },
                else => {},
            }
        }
        var dots: u8 = 0;

        while (dots < 200) {
            _ = c.SDL_SetRenderDrawColor(renderer, @truncate(u8, 0xFF +% dots), @truncate(u8, 0xFF + @bitCast(u32, pos_y) + dots), @truncate(u8, 0xFF + @bitCast(u32, pos_x) + dots), 0x00);

            pos_y = @floatToInt(i32, 100.0 * math.sin(@intToFloat(f64, pos_x) / 10.0)) + WINDOW_HEIGHT / 2;
            pos_x += 1;
            if (pos_x > WINDOW_WIDTH) {
                pos_x = 0;
            }
            _ = c.SDL_RenderDrawPoint(renderer, pos_x, pos_y);
            dots += 1;
        }
        //_ = c.SDL_RenderCopy(renderer, zig_texture, null, null);
        c.SDL_RenderPresent(renderer);

        c.SDL_Delay(30);
    }
}
