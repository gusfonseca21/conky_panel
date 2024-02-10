require 'cairo'

-- Define variables to store previous CPU value and target angle
prev_cpu_value = 0
target_angle = 0

function conky_main ()
    if conky_window == nil then
        return
    end

    local cs = cairo_xlib_surface_create (conky_window.display,
    conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)

    cr = cairo_create(cs)

    -- TOTAL CPU DIAL

    cpu_total = conky_parse("${cpu}")
    min_cpu = 0
    max_cpu = 100

    -- Outline
    min_angle = 30
    max_angle = 330
    outline_width = 3
    center_x = 200
    center_y = 200
    outline_radius = 100
    outline_start_rad = 0
    outline_end_rad = 2 * math.pi -- 360 graus
    cairo_set_line_width(cr, outline_width)
    cairo_arc (cr, center_x, center_y, outline_radius, outline_start_rad, outline_end_rad)
    cairo_set_source_rgba (cr, 1, 1, 1, 1)
    cairo_stroke (cr)

    -- INDICATOR
    -- Outline
    indicator_radius = 85
    indicator_start_rad = math.rad(120) -- 7 o'clock
    indicator_end_rad = math.rad(60) -- 5 o'clock
    indicator_width = 1
    cairo_set_line_width (cr, indicator_width)
    cairo_arc (cr, center_x, center_y, indicator_radius, indicator_start_rad, indicator_end_rad)
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
        cairo_show_text (cr, mark_value_start)
        mark_value_start = mark_value_start + 5
        cairo_stroke(cr)
    end



    -- Dot at the middle
    dot_width = 4
    cairo_set_source_rgba(cr, 1, 1, 1, 1)
    cairo_arc (cr, center_x, center_y, dot_width, 0, 2 * math.pi)
    cairo_fill (cr)

    -- Needle
    needle_length = outline_radius - 10
    needle_width = 2
    cpu_indicator = position_needle()
    needle_end_x = center_x + needle_length * math.cos( cpu_indicator + (math.pi / 2))
    needle_end_y = center_y + needle_length * math.sin(cpu_indicator + (math.pi / 2))
    cairo_set_source_rgba (cr, 1, 1, 1, 1)
    cairo_set_line_width(cr, needle_width)
    cairo_move_to(cr, center_x, center_y)
    cairo_line_to(cr, needle_end_x, needle_end_y)
    cairo_stroke(cr)

    cairo_destroy (cr)
    cairo_surface_destroy (cs)
    cr = nil

    -- Store the current CPU value for the next update
    prev_cpu_value = cpu_total
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
    target_angle = target_angle + (new_target_angle - target_angle) * 0.2 -- Adjust the smoothing factor as needed

    return math.rad(target_angle)
end
