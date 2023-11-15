#version 330

uniform float time; // Time in miliseconds.
float time_mod = sin(time/600)/700;
float time_long = mod(time,1000);
float time_long_cyclic =sin(time/6000);
float time_cyclic1 = sin((time+sin(time/10))/450);
float time_cyclic2 = sin((time+sin(time/400))/534);

float time_noise = cos(time*time*time*(time*(time*6.-15.)+10.))*200;
float time_cyclic3 = cos(sin(time)/time_noise);

float time_cyclic4 = sin(mod(time_cyclic3*time_mod, time_cyclic2/150));
float smooth1 = smoothstep(time_cyclic3*time_noise, time_cyclic2, time_cyclic4);


float smooth2 = smooth1 * time_cyclic4;

float onoff = smoothstep(-1, 1, time_long_cyclic);
float smooth3 = smoothstep(time_long_cyclic, time, time_cyclic4)*(onoff+1);
float time_cyclic5 = (1+onoff)*cos(time_cyclic4*time_long);
// Offsets in pixels for each color
vec2 uvb = vec2(0.5*time_cyclic2*smooth1,time_cyclic3*2);
vec2 uvg = vec2(-3*time_cyclic3*time_cyclic4*smooth1,3*time_cyclic1);
vec2 uvr = vec2(5*time_cyclic5,-3*time_cyclic2*smooth2);

// Scaling of the effect. This makes the effect stronger
// on pixels further away from the center of the window 
// and weaker on pixels close to it
// Set as 0 to disable
float scaling_factor = 0.8+0.1*((onoff+1)*time_cyclic4);


// Base strength of the effect. To be used along the scaling_factor
// Tells how strong the effect is at the center
float base_strength = 0;

in vec2 texcoord;             // texture coordinate of the fragment

uniform sampler2D tex;        // texture of the window
ivec2 window_size = textureSize(tex, 0);
ivec2 window_center = ivec2(window_size.x/2, window_size.y/2);

// Default window post-processing:
// 1) invert color
// 2) opacity / transparency
// 3) max-brightness clamping
// 4) rounded corners
vec4 default_post_processing(vec4 c);

vec4 window_shader() {
    if (scaling_factor != 0)
    {
        // Calculate the scale for the current coordinates 
        vec2 scale; 
        scale.xy = base_strength+scaling_factor*((texcoord.xy - window_center.xy*vec2(time_cyclic1*2*(time_cyclic3*0.5), (1+onoff)*time_cyclic5))/window_size.xy);

        // Scale offsets
        uvr.xy *= scale.xy;
        uvg.xy *= scale.xy;
        uvb.xy *= scale.xy;
    }

    // Calculate offset coords
    uvr += texcoord;
    uvg += texcoord;
    uvb += texcoord;

    // Fetch colors using offset coords
    vec3 offset_color;
    offset_color.x = texelFetch(tex, ivec2(uvr), 0).x;
    offset_color.y = texelFetch(tex, ivec2(uvg), 0).y;
    offset_color.z = texelFetch(tex, ivec2(uvb), 0).z;
    
    // Set the new color
    vec4 c;
    c.xyz = offset_color;
    c.w = texelFetch(tex, ivec2(uvr), 0).w;
    
    return default_post_processing(c);
}
