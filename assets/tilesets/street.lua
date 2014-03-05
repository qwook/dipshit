
--[[

Collision Shape reference:

1 =  __
    |__|

2 =   /|
    /__|

3 = |\
    |__\

4 =  __
    |  /
    |/

5 =  __
    \  |
      \|

]]

return {
    image = "street1.gif";
    tilesize = 16; -- not actually used, just for legacy
    tiles = {
        {x=0, y=1, colshape=0};
        {x=1, y=1, colshape=1};
        {x=2, y=1, colshape=1};
        {x=0, y=2, colshape=0};
        {x=1, y=2, colshape=1};
        {x=0, y=3, colshape=0};
        {x=1, y=3, colshape=0};
        {x=5, y=0, colshape=2};
        {x=5, y=1, colshape=1};
        {x=6, y=1, colshape=1};
        {x=6, y=0, colshape=3};
    };
}