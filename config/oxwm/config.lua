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
    oxwm.bar.block.shell({
        format = " {}",
        command = "uname -r",
        interval = 999999999,
        color = colors.red,
        underline = true,
    }),
    oxwm.bar.block.static({
        text = "│",
        interval = 999999999,
        color = colors.sep,
        underline = false,
    }),
    oxwm.bar.block.ram({
        format = "󰍛 Ram: {used}/{total} GB",
        interval = 5,
        color = colors.green,
        underline = true,
    }),
    oxwm.bar.block.static({
        text = "│",
        interval = 999999999,
        color = colors.sep,
        underline = false,
    }),
    oxwm.bar.block.datetime({
        format = "󰸘 {}",
        date_format = "%a, %b %d - %-I:%M %P",
        interval = 1,
        color = colors.red,
        underline = true,
    }),
    oxwm.bar.block.static({
        text = "│",
        interval = 999999999,
        color = colors.sep,
        underline = false,
    }),
    oxwm.bar.block.systray({
    }),
    oxwm.bar.block.battery({
        format = "Bat: {}%",
        charging = "⚡ Bat: {}%",
        discharging = "- Bat: {}%",
        full = "✓ Bat: {}%",
        interval = 30,
        color = colors.green,
        underline = true,
    }),
};

oxwm.set_terminal(terminal)
oxwm.set_modkey(modkey)
oxwm.set_tags(tags)

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
oxwm.key.bind({ modkey }, "S", oxwm.spawn({ "sh", "-c", "$HOME/.config/scripts/scratchpad.sh" }))
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
