shader_type canvas_item;

// How big the blocks are
uniform float block_size = 10.0; 

void fragment() {
    // 1. Calculate "Blocky" UV coordinates
    vec2 size = vec2(textureSize(TEXTURE, 0));
    vec2 uv_snapped = floor(UV * (size / block_size)) * (block_size / size);
    
    // 2. Sample the texture using the blocky coordinate
    vec4 color = texture(TEXTURE, uv_snapped);
    
    // 3. The "Alpha Scissor" - This is the magic part
    // If the pixel is even slightly transparent, DELETE IT.
    // This turns a "blurry" gradient into a "hard" pixel block.
    if (color.a < 0.5) {
        discard;
    }
    
    COLOR = color;
}