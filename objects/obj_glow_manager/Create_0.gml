surf = -1;
depth = -100;

array_size = 40;

circle_pos = array_create(array_size * 2);
circle_radius = array_create(array_size);
circle_color = array_create(array_size * 3);

WIDTH = sprite_get_width(spr_background);
HEIGHT = sprite_get_height(spr_background);

step = 0;

shader = shd_hard_step;