///
/// CAMERA VARIABLES
/// 
cam_width = 1920;
cam_height = 1080;

x = cam_width / 2;
y = cam_height / 2;

x_to = x;
y_to = y;

follow = noone;

follow_player = false;

//zoom stuff
current_zoom = 1.0;
target_zoom = 2.0;
zoom_x = 0;
zoom_y = 0;



///
/// SHADER VARIABLES
/// 
surf = -1;
depth = -100;

array_size = 40;

circle_pos = array_create(array_size * 2);
circle_radius = array_create(array_size);
circle_color = array_create(array_size * 3);
wall_points = array_create(array_size * 4);

step = 0;

shader = shd_smooth_step;