local oxwm = oxwm

local modkey = "Mod4"
local terminal = "st"

local colors = {
    bg = "#191724",
    fg = "#e0def4",
    red = "#eb6f92",
    cyan = "#9ccfd8",
    green = "#9ccfd8",
    light_blue = "#31748f",
    blue = "#c4a7e7",
    purple = "#c4a7e7",
    yellow = "#f6c177",
    orange = "#ebbcba",
    grey = "#6e6a86",
    sep = "#26233a",
}
-- local tags = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }
local tags = { "", "󰊯", "󱘶", "󰧮", "", "", "", "", "", "" }

local bar_font = "JetBrainsMono Nerd Font Propo:style=Bold:size=12"

local blocks = {
    -- Kernel
    oxwm.bar.block.shell({
        format = " {}",
        command = "uname -r",
        interval = 999999999,
        color = colors.red,
        underline = true,
    }),
    -- Separator + RAM
    oxwm.bar.block.static({text = "│", interval = 999999999, color = colors.orange, underline = false}),
    oxwm.bar.block.ram({
        format = "󰍛 Ram: {used}/{total} GB",
        interval = 5,
        color = colors.yellow,
        underline = true,
    }),
    -- Separator + CPU
    oxwm.bar.block.static({text = "│", interval = 999999999, color = colors.purple, underline = false}),
    oxwm.bar.block.shell({
        format = "CPU: {}%",
        command = [[top -bn1 | grep '%Cpu' | awk '{print 100-$8}' | awk -F. '{print $1}']],
        interval = 3,
        color = colors.cyan,
        underline = true,
    }),
    -- Separator + VOL
    oxwm.bar.block.static({text = "│", interval = 999999999, color = colors.blue, underline = false}),
    oxwm.bar.block.shell({
        format = "VOL: {}%",
        command = [[pamixer --get-volume]],
        interval = 2,
        color = colors.orange,
        underline = true,
    }),
    -- Separator + BAT
    oxwm.bar.block.static({text = "│", interval = 999999999, color = colors.green, underline = false}),
    oxwm.bar.block.shell({
        format = "BAT: {}%",
        command = "cat /sys/class/power_supply/BAT1/capacity",
        interval = 10,
        color = colors.blue,
        underline = true,
    }),
    -- Separator + BATTERY SMART
    oxwm.bar.block.static({text = "│", interval = 999999999, color = colors.light_blue, underline = false}),
    oxwm.bar.block.battery({
        format = "Bat: {}%",
        charging = "⚡ Bat: {}%",
        discharging = "- Bat: {}%",
        full = "✓ Bat: {}%",
        interval = 30,
        color = colors.grey,
        underline = true,
    }),
    -- TIME (rightmost)
    oxwm.bar.block.datetime({
        format = "󰸘 {}",
        date_format = "%a, %b %d - %-I:%M %P",
        interval = 1,
        color = colors.red,
        underline = true,
    }),
};

oxwm.set_terminal(terminal)
oxwm.set_modkey(modkey)
oxwm.set_tags(tags)

-- BRIGHTNESS FUNCTIONS

local function get_current_brightness()
    local handle = io.popen("xrandr --verbose | grep -m1 -i brightness | awk '{print $2}'")
    local result = handle:read("*a")
    handle:close()
    local value = tonumber(result)
    return value or 1.0
end

local function set_brightness(val)
    os.execute("xrandr --output $(xrandr | grep ' connected' | awk '{print $1}' | head -n1) --brightness " .. val)
end

local function brightness_down()
    local current = get_current_brightness()
    local new_brightness = math.max(current * 0.9, 0.1)
    set_brightness(new_brightness)
end

local function brightness_up()
    local current = get_current_brightness()
    local new_brightness = math.min(current * 1.1, 1.0)
    set_brightness(new_brightness)
end

local function brightness_mute()
    set_brightness(0.02)
end

oxwm.key.bind({}, "F1", function() os.execute("pamixer -t") end)          -- Mute/unmute
oxwm.key.bind({}, "F2", function() os.execute("pamixer -d 5") end)         -- Volume down
oxwm.key.bind({}, "F3", function() os.execute("pamixer -i 5") end)         -- Volume up
oxwm.key.bind({}, "F4", brightness_down)
oxwm.key.bind({}, "F5", brightness_up)

-- Layouts
oxwm.set_layout_symbol("tiling", "[T]")
oxwm.set_layout_symbol("normie", "[F]")
oxwm.set_layout_symbol("scrolling", "[S]")

-- Appearance
oxwm.border.set_width(3)
oxwm.border.set_focused_color(colors.purple)
oxwm.border.set_unfocused_color(colors.grey)

-- Smart Enabled = No border if 1 window
oxwm.gaps.set_smart(false)
oxwm.gaps.set_inner(5, 5)
oxwm.gaps.set_outer(5, 5)

oxwm.rule.add({ class = "firefox", tag = 2 })
oxwm.rule.add({ class = "qutebrowser", tag = 2 })
oxwm.rule.add({ class = "tmux", tag = 1 })
oxwm.rule.add({ class = "scratchpad", floating = true })

oxwm.bar.set_font(bar_font)
oxwm.bar.set_blocks(blocks)
oxwm.bar.set_scheme_normal(colors.fg, colors.bg, "#444444")
oxwm.bar.set_scheme_occupied(colors.blue, colors.bg, colors.cyan)
oxwm.bar.set_scheme_selected(colors.blue, colors.bg, colors.purple)

oxwm.key.bind({ modkey }, "Return", oxwm.spawn_terminal())
oxwm.key.bind({modkey}, "Tab", oxwm.spawn({"sh", "-c", "qutebrowser"}))
oxwm.key.bind({modkey}, "E", oxwm.spawn({"sh", "-c", "pcmanfm"}))
-- oxwm.key.bind({ modkey }, "D", oxwm.spawn({ "sh", "-c", "dmenu_run -l 10" }))
oxwm.key.bind({ modkey }, "Z", oxwm.spawn({ "sh", "-c", "rofi -show drun" }))
oxwm.key.bind({ modkey }, "S", oxwm.spawn({ "sh", "-c", "maim -s shot.png"}))
oxwm.key.bind({ modkey }, "W", oxwm.client.kill())

oxwm.key.bind({ modkey, "Shift" }, "Slash", oxwm.show_keybinds())

oxwm.key.bind({ modkey, "Shift" }, "F", oxwm.client.toggle_fullscreen())
oxwm.key.bind({ modkey, "Shift" }, "Space", oxwm.client.toggle_floating())

oxwm.key.bind({ modkey }, "C", oxwm.layout.set("tiling"))
oxwm.key.bind({ modkey }, "N", oxwm.layout.cycle())

oxwm.key.bind({ modkey }, "I", oxwm.inc_num_master(1))
oxwm.key.bind({ modkey }, "P", oxwm.inc_num_master(-1))

oxwm.key.bind({ modkey }, "G", oxwm.toggle_gaps())

oxwm.key.bind({ modkey, "Shift" }, "Q", oxwm.quit())
oxwm.key.bind({ modkey, "Shift" }, "R", oxwm.restart())

oxwm.key.bind({ modkey }, "D", oxwm.client.focus_stack(1))
oxwm.key.bind({ modkey }, "A", oxwm.client.focus_stack(-1))

oxwm.key.bind({ modkey, "Shift" }, "D", oxwm.client.move_stack(1))
oxwm.key.bind({ modkey, "Shift" }, "A", oxwm.client.move_stack(-1))

oxwm.key.bind({ modkey, "Mod1" }, "D", oxwm.set_master_factor(-5))
oxwm.key.bind({ modkey, "Mod1" }, "A", oxwm.set_master_factor(5))

oxwm.key.bind({ modkey }, "Comma", oxwm.monitor.focus(-1))
oxwm.key.bind({ modkey }, "Period", oxwm.monitor.focus(1))
oxwm.key.bind({ modkey, "Shift" }, "Comma", oxwm.monitor.tag(-1))
oxwm.key.bind({ modkey, "Shift" }, "Period", oxwm.monitor.tag(1))

for i = 1, #tags do
    oxwm.key.bind({ modkey }, tostring(i), oxwm.tag.view(i - 1))
    oxwm.key.bind({ modkey, "Shift" }, tostring(i), oxwm.tag.move_to(i - 1))
    oxwm.key.bind({ modkey, "Control" }, tostring(i), oxwm.tag.toggleview(i - 1))
    oxwm.key.bind({ modkey, "Control", "Shift" }, tostring(i), oxwm.tag.toggletag(i - 1))
end

-- oxwm.key.chord({
--     { { modkey }, "Space" },
--     { {},         "T" }
-- }, oxwm.spawn_terminal())

--[[ oxwm.key.chord({
    { { modkey }, "F" },
    { {},         "B" }
}, oxwm.spawn({ "sh", "-c", "$HOME/repos/dmenu-scripts/bookmarks-dmenu.sh" }))

oxwm.key.chord({
    { { modkey }, "F" },
    { {},         "F" }
}, oxwm.spawn({ "sh", "-c", "$HOME/repos/dmenu-scripts/repos-dmenu.sh" }))

oxwm.key.chord({
    { { modkey }, "F" },
    { {},         "O" }
}, oxwm.spawn({ "sh", "-c", "$HOME/repos/dmenu-scripts/tmux-dmenu.sh" })) --]]


-- Autostart

oxwm.autostart("st")
oxwm.autostart("qutebrowser")
oxwm.autostart("dunst")
