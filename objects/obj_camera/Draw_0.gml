var count = 0;
var wall_count = 0;

var cam_corner_x = x - cam_width / 2;
//var cam_corner_y = y - cam_height / 2;

with(obj_glow) {
    other.circle_pos[count*2] = x - cam_corner_x;
    other.circle_pos[count*2 + 1] = y;
    other.circle_radius[count] = glow_radius;
    other.circle_color[count*3] = colour_get_red(color);
    other.circle_color[count*3 + 1] = colour_get_green(color);
    other.circle_color[count*3 + 2] = colour_get_blue(color);
    count++;
}

with(obj_wall) {
    other.wall_points[wall_count*4] = x - cam_corner_x;
    other.wall_points[wall_count*4 + 1] = y;
    other.wall_points[wall_count*4 + 2] = x + sprite_width;
    other.wall_points[wall_count*4 + 3] = y + sprite_height;
    wall_count++;
}


if(!surface_exists(surf)) {
    surf = surface_create(cam_width, cam_height);
}

surface_set_target(surf);
    draw_clear_alpha(c_black, 0);

    var c = c_black;
    draw_rectangle_color(
        0,
        0, 
        cam_width,
        cam_height,
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
    
    //for shd_visibility
    var u_resolution = shader_get_uniform(shader, "u_resolution");
    var u_mouse = shader_get_uniform(shader, "u_mouse");
    var u_rect_count = shader_get_uniform(shader, "u_rect_count");
    var u_rects = shader_get_uniform(shader, "u_rects");


    shader_set_uniform_f_array(circlePos, circle_pos);
    shader_set_uniform_f_array(circleRadius, circle_radius);
    shader_set_uniform_i(circleCount, count);
    shader_set_uniform_f_array(screenSize, [cam_width, cam_height]);
    shader_set_uniform_f(currentStep, step);
    shader_set_uniform_f_array(circleColor, circle_color);

    //for shd_visibility
    shader_set_uniform_f(u_resolution, surface_get_width(surf), surface_get_height(surf));
    shader_set_uniform_f(u_mouse, obj_player.x, obj_player.y);
    shader_set_uniform_i(u_rect_count, wall_count);
    shader_set_uniform_f_array(u_rects, wall_points);

    draw_surface(surf, x - cam_width / 2, y - cam_height / 2);
shader_reset();
