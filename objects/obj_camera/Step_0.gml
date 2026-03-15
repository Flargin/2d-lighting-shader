if(follow != noone) {
    x_to = follow.x;
    y_to = follow.y;
}

x += (x_to - x) / cam_lerp;
y += (y_to - y) / cam_lerp;

x = round(clamp(x, CAM_WIDTH/2, sprite_get_width(spr_background) - CAM_WIDTH/2));
y = round(clamp(y, CAM_HEIGHT/2, sprite_get_height(spr_background) - CAM_HEIGHT/2));

camera_set_view_pos(view_camera[0], x - (CAM_WIDTH * 0.5), y - (CAM_HEIGHT * 0.5));