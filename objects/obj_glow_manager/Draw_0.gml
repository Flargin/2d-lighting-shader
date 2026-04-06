var count = 0;

with(obj_player) {
    other.circle_pos[count*2] = x;
    other.circle_pos[count*2 + 1] = y;
    other.circle_radius[count] = 50;
    other.circle_color[count*3] = colour_get_red(color);
    other.circle_color[count*3 + 1] = colour_get_green(color);
    other.circle_color[count*3 + 2] = colour_get_blue(color);
    count++;
}

with(obj_lamp) {
    other.circle_pos[count*2] = x;
    other.circle_pos[count*2 + 1] = y;
    other.circle_radius[count] = 100;
    other.circle_color[count*3] = colour_get_red(color);
    other.circle_color[count*3 + 1] = colour_get_green(color);
    other.circle_color[count*3 + 2] = colour_get_blue(color);
    count++;
}


if(!surface_exists(surf)) {
    surf = surface_create(WIDTH, HEIGHT);
}

surface_set_target(surf);
    draw_clear_alpha(c_black, 0);

    var c = c_black;
    draw_rectangle_color(
        0,
        0, 
        WIDTH,
        HEIGHT,
        c, c, c, c,
        false
    );
surface_reset_target();

shader_set(shader);
    var circlePos = shader_get_uniform(shader, "circlePos");
    var circleRadius = shader_get_uniform(shader, "circleRadius");
    var circleCount = shader_get_uniform(shader, "circleCount");
    var screenSize = shader_get_uniform(shader, "screenSize");
    var currentStep = shader_get_uniform(shader, "currentStep");
    var circleColor = shader_get_uniform(shader, "circleColor");

    shader_set_uniform_f_array(circlePos, circle_pos);
    shader_set_uniform_f_array(circleRadius, circle_radius);
    shader_set_uniform_i(circleCount, count);
    shader_set_uniform_f_array(screenSize, [WIDTH, HEIGHT]);
    shader_set_uniform_f(currentStep, step);
    shader_set_uniform_f_array(circleColor, circle_color);

    draw_surface(surf, 0, 0);
shader_reset();

