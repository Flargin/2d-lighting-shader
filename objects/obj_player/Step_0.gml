var hor_mov = keyboard_check(ord("D")) - keyboard_check(ord("A"));
var ver_mov = keyboard_check(ord("S")) - keyboard_check(ord("W"));

var input_angle = point_direction(0, 0, hor_mov, ver_mov);
var angle_diff = angle_difference(input_angle, angle);
angle = round(lerp(angle, angle + angle_diff, 0.2));

///
/// X
/// 
if(hor_mov != 0)
    x_vel += accel * dcos(angle);

if(sign(hor_mov) != sign(x_vel)) 
    x_vel += -decel * sign(x_vel);

if(hor_mov == 0 && abs(x_vel) <= decel) {
    x_vel = 0;
}

x_vel = clamp(x_vel, -VEL_MAX, VEL_MAX);

x += x_vel;

if(place_meeting(x, y, obj_wall) && x_vel != 0) {
    while(place_meeting(x, y, obj_wall)) {
        x -= sign(x_vel);
    }
    
    x = round(x);
    x_vel = 0;
}

///
/// Y
/// 
if(ver_mov != 0)
    y_vel += accel * -dsin(angle);

if(sign(ver_mov) != sign(y_vel)) 
    y_vel += -decel * sign(y_vel);

if(ver_mov == 0 && abs(y_vel) <= decel) {
    y_vel = 0;
}

y_vel = clamp(y_vel, -VEL_MAX, VEL_MAX);

y += y_vel;

if(place_meeting(x, y, obj_wall) && y_vel != 0) {
    while(place_meeting(x, y, obj_wall)) {
        y -= sign(y_vel);
    }
    
    y = round(y);
    y_vel = 0;
}

///
/// DEBUG
/// 
if(keyboard_check_pressed(vk_escape))
    game_end();