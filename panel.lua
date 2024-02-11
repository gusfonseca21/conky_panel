require 'cairo'
require("cpu_dial")


function conky_main ()
    if conky_window == nil then
        return
    end

    local cs = cairo_xlib_surface_create (conky_window.display,
    conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)

    cr = cairo_create(cs)

    cpu_total = conky_parse("${cpu}")
    cpu_1 = conky_parse("${cpu 1}")
    cpu_2 = conky_parse("${cpu 2}")
    cpu_3 = conky_parse("${cpu 3}")
    cpu_4 = conky_parse("${cpu 4}")
    
    cpu_dial(cr, cpu_total, "Total %", 150, 150)
    cpu_dial(cr, cpu_1, "CPU 1 %", 150, 400)
    cpu_dial(cr, cpu_2, "CPU 2 %", 400, 400)
    cpu_dial(cr, cpu_3, "CPU 3 %", 650, 400)
    cpu_dial(cr, cpu_4, "CPU 4 %", 900, 400)

    -- Prevent memory leaks
    cairo_destroy (cr)
    cairo_surface_destroy (cs)
    cr = nil
end
