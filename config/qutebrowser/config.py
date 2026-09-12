c = c

c.url.start_pages = ["file:///home/grae/.config/qutebrowser/startpage.html"]

# ROSE PINE COLORS

base = "#191724"
surface = "#1f1d2e"
overlay = "#26233a"
muted = "#6e6a86"
subtle = "#908caa"
text = "#e0def4"
love = "#eb6f92"
gold = "#f6c177"
rose = "#ebbcba"
pine = "#31748f"
foam = "#9ccfd8"
iris = "#c4a7e7"

# FONT

c.fonts.default_family = "JetBrains Mono"
c.fonts.default_size = "11pt"

c.fonts.statusbar = "11pt JetBrains Mono"
c.fonts.tabs.selected = "11pt JetBrains Mono"
c.fonts.tabs.unselected = "11pt JetBrains Mono"
c.fonts.hints = "bold 11pt JetBrains Mono"
c.fonts.keyhint = "11pt JetBrains Mono"

# TABS

c.tabs.show = "always"

c.tabs.padding = {
    "top": 5,
    "bottom": 5,
    "left": 6,
    "right": 6,
}

c.tabs.indicator.width = 3
c.tabs.title.format = "{current_title}"
c.tabs.title.format_pinned = "{current_title}"
c.tabs.position = "top"
c.tabs.background = True

# TABS COLORS

c.colors.tabs.bar.bg = "rgba(25, 23, 36, 0)"

c.colors.tabs.even.bg = "rgba(25, 23, 36, 0)"
c.colors.tabs.even.fg = muted

c.colors.tabs.odd.bg = "rgba(25, 23, 36, 0)"
c.colors.tabs.odd.fg = muted

c.colors.tabs.selected.even.bg = surface
c.colors.tabs.selected.even.fg = text

c.colors.tabs.selected.odd.bg = surface
c.colors.tabs.selected.odd.fg = text

c.colors.tabs.indicator.start = love
c.colors.tabs.indicator.stop = love

# SCROLLING

c.scrolling.smooth = True
c.scrolling.bar = "overlay"

# HINTS

c.hints.chars = "asdfghjkl"
c.hints.radius = 4
c.hints.border = f"1px solid {love}"

c.colors.hints.bg = f"rgba(235, 111, 146, 0.95)"
c.colors.hints.fg = base
c.colors.hints.match.fg = gold

# COMPLETION

c.colors.completion.fg = text

c.colors.completion.even.bg = base
c.colors.completion.odd.bg = surface

c.colors.completion.category.bg = overlay
c.colors.completion.category.fg = iris

c.colors.completion.item.selected.bg = overlay
c.colors.completion.item.selected.fg = text

c.colors.completion.match.fg = love

c.colors.completion.scrollbar.bg = overlay
c.colors.completion.scrollbar.fg = muted


# KEY HINTS

c.keyhint.radius = 16
c.keyhint.delay = 0

c.colors.keyhint.bg = "rgba(25, 23, 36, 0.95)"
c.colors.keyhint.fg = text
c.colors.keyhint.suffix.fg = love


# STATUS BAR

c.statusbar.widgets = [
    "keypress",
    "url",
    "scroll",
]

c.colors.statusbar.normal.bg = base
c.colors.statusbar.normal.fg = subtle

c.colors.statusbar.command.bg = base
c.colors.statusbar.command.fg = text

c.colors.statusbar.insert.bg = love
c.colors.statusbar.insert.fg = base

c.colors.statusbar.private.bg = love
c.colors.statusbar.private.fg = base

c.colors.statusbar.url.fg = foam
c.colors.statusbar.url.error.fg = love
c.colors.statusbar.url.success.http.fg = gold
c.colors.statusbar.url.success.https.fg = pine
c.colors.statusbar.url.warn.fg = gold


# DOWNLOADS

c.colors.downloads.bar.bg = base
c.colors.downloads.stop.fg = foam
c.colors.downloads.error.fg = love


# MESSAGES

c.colors.messages.error.fg = love
c.colors.messages.error.bg = base
c.colors.messages.error.border = love

c.colors.messages.warning.fg = gold
c.colors.messages.warning.bg = base
c.colors.messages.warning.border = gold

c.colors.messages.info.fg = foam
c.colors.messages.info.bg = base
c.colors.messages.info.border = foam


# PROMPTS

c.colors.prompts.fg = text
c.colors.prompts.bg = surface
c.colors.prompts.border = overlay
c.colors.prompts.selected.bg = overlay
c.colors.prompts.selected.fg = text

c.prompt.radius = 8


# TOOLTIPS

c.colors.tooltip.bg = surface
c.colors.tooltip.fg = text

# URLS

c.url.searchengines = {
    "DEFAULT": "https://www.duckduckgo.com/search?q={}",
    "!w": "https://en.wikipedia.org/wiki/{}",
    "!gh": "https://github.com/results?search_query={}",
    "!aw": "https://wiki.archlinux.org/?search={}",
    "!pgk": "https://archlinux.org/packages/?sort=&q={}&maintainer=&flagged=",
    "!yt": 'https://www.youtube.com/results?search_query={}',
}

# KEYBINDINGS

config.bind("E", "open -t file:///home/grae/.config/qutebrowser/startpage.html")

# WEBPAGES

c.colors.webpage.preferred_color_scheme = "dark"
c.colors.webpage.darkmode.enabled = True

config.load_autoconfig(True)
