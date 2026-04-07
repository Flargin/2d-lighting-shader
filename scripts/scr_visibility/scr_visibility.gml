/// @desc 2D Visibility sweep — port of Red Blob Games Haxe implementation
/// License: Apache v2  https://www.redblobgames.com/articles/visibility/

// ---------------------------------------------------------------------------
// STRUCT CONSTRUCTORS
// ---------------------------------------------------------------------------

function VisPoint(_x, _y) constructor {
    x = _x;
    y = _y;
}

function VisEndPoint(_x, _y) constructor {
    x      = _x;
    y      = _y;
    beginn   = false;
    segment = undefined;
    angle   = 0.0;
}

function VisSegment() constructor {
    p1 = undefined;
    p2 = undefined;
    d  = 0.0;
}

// ---------------------------------------------------------------------------
// vis_create()  — call once; keep the returned struct on your object
// ---------------------------------------------------------------------------

function vis_create() {
    var v = {
        segments  : [],   // array of VisSegment
        endpoints : [],   // array of VisEndPoint
        open      : [],   // array of VisSegment (active during sweep)
        center    : new VisPoint(0, 0),
        output    : [],   // array of VisPoint pairs (triangle strip)
    };
    return v;
}

// ---------------------------------------------------------------------------
// vis_load_map(v, size, margin, blocks, walls)
//   blocks : array of structs { x, y, r }
//   walls  : array of structs { x1, y1, x2, y2 }
// ---------------------------------------------------------------------------

function vis_load_map(v, size, margin, blocks, walls) {
    v.segments  = [];
    v.endpoints = [];

    // Border
    _vis_add_segment(v, margin,        margin,        margin,        size-margin);
    _vis_add_segment(v, margin,        size-margin,   size-margin,   size-margin);
    _vis_add_segment(v, size-margin,   size-margin,   size-margin,   margin);
    _vis_add_segment(v, size-margin,   margin,        margin,        margin);

    // Square blocks
    var i = 0;
    repeat (array_length(blocks)) {
        var b = blocks[i++];
        _vis_add_segment(v, b.x-b.r, b.y-b.r, b.x-b.r, b.y+b.r);
        _vis_add_segment(v, b.x-b.r, b.y+b.r, b.x+b.r, b.y+b.r);
        _vis_add_segment(v, b.x+b.r, b.y+b.r, b.x+b.r, b.y-b.r);
        _vis_add_segment(v, b.x+b.r, b.y-b.r, b.x-b.r, b.y-b.r);
    }

    // Custom walls
    i = 0;
    repeat (array_length(walls)) {
        var w = walls[i++];
        _vis_add_segment(v, w.x1, w.y1, w.x2, w.y2);
    }
}

// ---------------------------------------------------------------------------
// vis_set_light(v, x, y)  — update every frame when the light moves
// ---------------------------------------------------------------------------

function vis_set_light(v, lx, ly) {
    v.center.x = lx;
    v.center.y = ly;

    var n = array_length(v.segments);
    for (var i = 0; i < n; i++) {
        var seg = v.segments[i];
        var dx  = 0.5 * (seg.p1.x + seg.p2.x) - lx;
        var dy  = 0.5 * (seg.p1.y + seg.p2.y) - ly;
        seg.d   = dx*dx + dy*dy;

        seg.p1.angle = arctan2(seg.p1.y - ly, seg.p1.x - lx);
        seg.p2.angle = arctan2(seg.p2.y - ly, seg.p2.x - lx);

        var dA = seg.p2.angle - seg.p1.angle;
        if (dA <= -pi) dA += 2*pi;
        if (dA >   pi) dA -= 2*pi;
        seg.p1.beginn = (dA > 0.0);
        seg.p2.beginn = !seg.p1.beginn;
    }
}

// ---------------------------------------------------------------------------
// vis_sweep(v, [max_angle])  — returns array of VisPoints (pairs = triangles)
// ---------------------------------------------------------------------------

function vis_sweep(v, max_angle) {
    if (is_undefined(max_angle)) max_angle = 999.0;

    v.output = [];
    v.open   = [];

    // Sort endpoints by angle (insertion sort — fast enough for <200 endpoints)
    var eps = array_copy([], 0, v.endpoints, 0, array_length(v.endpoints));
    _vis_sort_endpoints(eps);

    var begin_angle = 0.0;

    for (var pass = 0; pass < 2; pass++) {
        var n = array_length(eps);
        for (var ei = 0; ei < n; ei++) {
            var p = eps[ei];

            if (pass == 1 && p.angle > max_angle) break;

            var current_old = (array_length(v.open) == 0) ? undefined : v.open[0];

            if (p.beginn) {
                // Insert before the first segment that p.segment is in front of
                var inserted = false;
                var on = array_length(v.open);
                for (var oi = 0; oi < on; oi++) {
                    if (_vis_segment_in_front(v, p.segment, v.open[oi], v.center)) {
                        array_insert(v.open, oi, p.segment);
                        inserted = true;
                        break;
                    }
                }
                if (!inserted) array_push(v.open, p.segment);
            } else {
                // Remove from open list
                var on = array_length(v.open);
                for (var oi = 0; oi < on; oi++) {
                    if (v.open[oi] == p.segment) {
                        array_delete(v.open, oi, 1);
                        break;
                    }
                }
            }

            var current_new = (array_length(v.open) == 0) ? undefined : v.open[0];

            if (current_old != current_new) {
                if (pass == 1) {
                    _vis_add_triangle(v, begin_angle, p.angle, current_old);
                }
                begin_angle = p.angle;
            }
        }
    }

    return v.output;
}

// ---------------------------------------------------------------------------
// vis_line_intersection(p1, p2, p3, p4)
//   All args are VisPoint structs. Returns a new VisPoint.
// ---------------------------------------------------------------------------

function vis_line_intersection(p1, p2, p3, p4) {
    var s = ((p4.x-p3.x)*(p1.y-p3.y) - (p4.y-p3.y)*(p1.x-p3.x))
          / ((p4.y-p3.y)*(p2.x-p1.x) - (p4.x-p3.x)*(p2.y-p1.y));
    return new VisPoint(p1.x + s*(p2.x-p1.x), p1.y + s*(p2.y-p1.y));
}

// ===========================================================================
// PRIVATE HELPERS  (prefix _vis_)
// ===========================================================================

function _vis_add_segment(v, x1, y1, x2, y2) {
    var seg = new VisSegment();
    var p1  = new VisEndPoint(x1, y1);
    var p2  = new VisEndPoint(x2, y2);
    p1.segment = seg;
    p2.segment = seg;
    seg.p1 = p1;
    seg.p2 = p2;

    array_push(v.segments,  seg);
    array_push(v.endpoints, p1);
    array_push(v.endpoints, p2);
}

function _vis_sort_endpoints(eps) {
    // Insertion sort: stable, in-place
    var n = array_length(eps);
    for (var i = 1; i < n; i++) {
        var key = eps[i];
        var j   = i - 1;
        while (j >= 0 && _vis_endpoint_compare(eps[j], key) > 0) {
            eps[j+1] = eps[j];
            j--;
        }
        eps[j+1] = key;
    }
}

function _vis_endpoint_compare(a, b) {
    if (a.angle > b.angle) return  1;
    if (a.angle < b.angle) return -1;
    if (!a.beginn &&  b.beginn) return  1;
    if ( a.beginn && !b.beginn) return -1;
    return 0;
}

function _vis_left_of(seg, p) {
    var cross = (seg.p2.x - seg.p1.x) * (p.y - seg.p1.y)
              - (seg.p2.y - seg.p1.y) * (p.x - seg.p1.x);
    return (cross < 0);
}

function _vis_interpolate(p, q, f) {
    return new VisPoint(p.x*(1-f) + q.x*f, p.y*(1-f) + q.y*f);
}

function _vis_segment_in_front(v, a, b, rel) {
    var A1 = _vis_left_of(a, _vis_interpolate(b.p1, b.p2, 0.01));
    var A2 = _vis_left_of(a, _vis_interpolate(b.p2, b.p1, 0.01));
    var A3 = _vis_left_of(a, rel);
    var B1 = _vis_left_of(b, _vis_interpolate(a.p1, a.p2, 0.01));
    var B2 = _vis_left_of(b, _vis_interpolate(a.p2, a.p1, 0.01));
    var B3 = _vis_left_of(b, rel);

    if (B1 == B2 && B2 != B3) return true;
    if (A1 == A2 && A2 == A3) return true;
    if (A1 == A2 && A2 != A3) return false;
    if (B1 == B2 && B2 == B3) return false;
    return false;
}

function _vis_add_triangle(v, angle1, angle2, seg) {
    var p1 = v.center;
    var p2 = new VisPoint(v.center.x + cos(angle1), v.center.y + sin(angle1));
    var p3, p4;

    if (!is_undefined(seg)) {
        p3 = seg.p1;
        p4 = seg.p2;
    } else {
        p3 = new VisPoint(v.center.x + cos(angle1)*500, v.center.y + sin(angle1)*500);
        p4 = new VisPoint(v.center.x + cos(angle2)*500, v.center.y + sin(angle2)*500);
    }

    var p_begin = vis_line_intersection(p3, p4, p1, p2);

    p2.x = v.center.x + cos(angle2);
    p2.y = v.center.y + sin(angle2);
    var p_end = vis_line_intersection(p3, p4, p1, p2);

    array_push(v.output, p_begin);
    array_push(v.output, p_end);
}