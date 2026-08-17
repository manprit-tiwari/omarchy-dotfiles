-- Change the default Omarchy look'n'feel.

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
hl.config({
  general = {
    -- Change to niri-like side-scrolling layout.
    layout = "scrolling",
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
hl.config({
  decoration = {
    -- Use round window corners.
    rounding = 8,
  },
})

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
hl.config({
  scrolling = {
    column_width = 0.9,
    focus_fit_method = 0,
    follow_focus = true,
  },
})
