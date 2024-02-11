prev_cpu_value = 0
target_angle = 0

function cpu_dial(cr, center_x, center_y)
    print(center_x)
-- TOTAL CPU DIAL

cpu_total = conky_parse("${cpu}")
min_cpu = 0
max_cpu = 100

-- Outline
min_angle = 30
max_angle = 330
outline_width = 3
outline_radius = 120
outline_start_rad = 0
outline_end_rad = 2 * math.pi -- 360 graus

cairo_set_line_width(cr, outline_width)
cairo_arc (cr, center_x, center_y, outline_radius, outline_start_rad, outline_end_rad)
cairo_set_source_rgba (cr, 1, 1, 1, 1)
cairo_stroke (cr)

-- INDICATOR
-- Outline
indicator_radius = outline_radius - 15
indicator_start_rad = math.rad(120) -- 7 o'clock
indicator_end_rad = math.rad(60) -- 5 o'clock
indicator_width = 1
cairo_set_line_width (cr, indicator_width)
cairo_arc (cr, center_x, center_y, indicator_radius, indicator_start_rad, indicator_end_rad)
cairo_stroke(cr)

-- Marks high usage
mark_high_width = 5
mark_colored_radius = outline_radius - 4
mark_high_start_angle = math.rad(0)
mark_high_end_angle = math.rad(60)
cairo_set_source_rgba(cr, 1, 0, 0, 1)
cairo_arc (cr, center_x, center_y, mark_colored_radius, mark_high_start_angle, mark_high_end_angle)
cairo_set_line_width(cr, mark_high_width)
cairo_stroke(cr)

-- Marks
mark_width = 2
long_mark = 30
short_mark = 25
num_of_marks = 21 -- Considering 0
mark_radius = 15
angle_per_mark = 2 * math.pi / num_of_marks
mark_start_angle = math.rad(30)
mark_end_angle = math.rad(330)
angle_per_mark = (mark_end_angle - mark_start_angle) / num_of_marks
mark_value_start = 0
cairo_set_line_width(cr, mark_width)
cairo_stroke(cr)

for mark = 1, num_of_marks do
    if mark % 2 == 0 then
        mark_length = short_mark
    else
        mark_length = long_mark
    end
    mark_angle = position_mark(mark, num_of_marks, -math.pi / 2, 3 * math.pi / 2)
    x_mark_start = center_x + (outline_radius - mark_radius) * math.cos(mark_angle)
    y_mark_start = center_y - (outline_radius - mark_radius) * math.sin(mark_angle)
    x_mark_end = center_x + (outline_radius - mark_length) * math.cos(mark_angle)
    y_mark_end = center_y - (outline_radius - mark_length) * math.sin(mark_angle)
    cairo_move_to(cr, x_mark_start, y_mark_start)
    cairo_line_to(cr, x_mark_end, y_mark_end)

    -- Draw mark values
    cairo_set_font_size(cr, 12) -- Adjust font size as needed
    mark_value = tostring(mark_value_start)
    extents = cairo_text_extents_t:create()
    cairo_text_extents(cr, mark_value, extents)
    mark_value_width = extents.width
    mark_value_height = extents.height

    -- Calculate text position based on the angle of the mark
    text_radius = outline_radius - 37 -- Adjust distance from dial as needed
    x_text = center_x + text_radius * math.cos(mark_angle) - mark_value_width / 2
    y_text = center_y - text_radius * math.sin(mark_angle) + mark_value_height / 2

    cairo_move_to(cr, x_text, y_text)
    cairo_set_source_rgba(cr, 1, 1, 1, 1)
    cairo_show_text(cr, mark_value)

    cairo_stroke(cr)
    mark_value_start = mark_value_start + 5
end


-- Dot at the middle
dot_width = 4
cairo_set_source_rgba(cr, 1, 1, 1, 1)
cairo_arc (cr, center_x, center_y, dot_width, 0, 2 * math.pi)
cairo_fill (cr)

-- Label
label_text = "Total %"
cairo_set_font_size(cr, 13)
label_extents = cairo_text_extents_t:create()
cairo_text_extents(cr, label_text, label_extents)
label_text_width = label_extents.width
label_text_start_x = center_x - label_text_width / 2
label_text_start_y = center_y + 35
cairo_move_to(cr, label_text_start_x, label_text_start_y)
cairo_show_text(cr, "Total %")

-- Needle
needle_length = outline_radius - 10
needle_width = 2
needle_smoothness = 0.2
cpu_indicator = position_needle()
needle_end_x = center_x + needle_length * math.cos( cpu_indicator + (math.pi / 2))
needle_end_y = center_y + needle_length * math.sin(cpu_indicator + (math.pi / 2))
cairo_set_source_rgba (cr, 1, 1, 1, 1)
cairo_set_line_width(cr, needle_width)
cairo_move_to(cr, center_x, center_y)
cairo_line_to(cr, needle_end_x, needle_end_y)
cairo_stroke(cr)
end

function position_mark(mark_number, total_marks, min_angle, max_angle)

local start_angle = max_angle - math.rad(30)
local end_angle = min_angle + math.rad(30)
local angle_per_mark = (end_angle - start_angle) / (total_marks - 1)
local mark_angle = start_angle + (mark_number - 1) * angle_per_mark
return mark_angle
end

function position_needle()
local new_target_angle = min_angle + (cpu_total - min_cpu) / (max_cpu - min_cpu) * (max_angle - min_angle)
target_angle = target_angle + (new_target_angle - target_angle) * needle_smoothness -- Adjust the smoothing factor as needed

return math.rad(target_angle)
end

return cpu_dial