if(follow != noone) {
	x_to += sign(follow.x - x_to);
	y_to += sign(follow.y - y_to);
}

if(!mouse_check_button(mb_left)) {
	x = lerp(x, x_to, .1);
	y = lerp(y, y_to, .1);
}

//sets the camera's position with the viewport
camera_set_view_pos(view_camera[0], x - (cam_width * 0.5), y - (cam_height * 0.5));

if(keyboard_check_pressed(vk_space))
	follow_player = true;
	
if(follow_player) {
	with(obj_player) {
		other.x_to = instance_nearest(x, y, obj_slide).x;
		other.y_to = instance_nearest(x, y, obj_slide).y;
	}
}


if(mouse_check_button(mb_left)) {
	zoom_x = lerp(zoom_x, mouse_x, 0.1);
	zoom_y = lerp(zoom_y, mouse_y, 0.1);
	
	current_zoom = lerp(current_zoom, target_zoom, 0.15);
	
	
} else {
	zoom_x = lerp(zoom_x, x - (cam_width * 0.5), 0.2);
	zoom_y = lerp(zoom_y, y - (cam_height * 0.5), 0.2);
	
	current_zoom = lerp(current_zoom, 1.0, 0.2);
}

camera_set_view_size(view_camera[0], cam_width / current_zoom, cam_height / current_zoom);
camera_set_view_pos(view_camera[0], zoom_x, zoom_y);



if(keyboard_check_pressed(vk_right)) {
    x += cam_width;
    x_to += cam_width;
    zoom_x += cam_width;
    //shader = shd_off;
} else if(keyboard_check_pressed(vk_left)) {
    x -= cam_width;
    x_to -= cam_width;
    zoom_x -= cam_width;
}

if(follow_player && instance_nearest(x, y, obj_slide).shader != -1) {
    shader = instance_nearest(x, y, obj_slide).shader;
}



///
/// DEBUG
/// 

if(keyboard_check_released(ord("R"))) {
    room_restart();
}