
local shaders = {}

shaders.mask_effect = love.graphics.newShader([[

vec4 effect ( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {
    if (Texel(texture, texture_coords).a == 0.0)
        discard;
    else
        return vec4(1.0);
}

]])

return shaders
