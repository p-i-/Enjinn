//
//  Shader.frag
//  F33rsmEnjinn
//
//  Derived from GLYoda (aka Max Rupp)'s web.cecs.pdx.edu/~feelgood/Source/FBO.c
//

precision mediump float;

uniform lowp    sampler2D   RTScene;             

varying mediump vec2  vTexCoord; // V0_glTexCoord_st;          
//varying lowp    vec4  V1_glColor_rgba;                 

void main( void )                       
{                                  
   // gl_FragColor = texture2D( S0, V0_glTexCoord_st ).a; // * V1_glColor_rgba ;
    
    vec4 sum = vec4(0.0);
    
    // blur in y (vertical)
    // take nine samples, with the distance blurSize between them
    sum += texture2D(RTScene, vec2(vTexCoord.x - 4.0*blurSize, vTexCoord.y)) * 0.05;
    sum += texture2D(RTScene, vec2(vTexCoord.x - 3.0*blurSize, vTexCoord.y)) * 0.09;
    sum += texture2D(RTScene, vec2(vTexCoord.x - 2.0*blurSize, vTexCoord.y)) * 0.12;
    sum += texture2D(RTScene, vec2(vTexCoord.x -     blurSize, vTexCoord.y)) * 0.15;
    sum += texture2D(RTScene, vec2(vTexCoord.x,                vTexCoord.y)) * 0.16;
    sum += texture2D(RTScene, vec2(vTexCoord.x +     blurSize, vTexCoord.y)) * 0.15;
    sum += texture2D(RTScene, vec2(vTexCoord.x + 2.0*blurSize, vTexCoord.y)) * 0.12;
    sum += texture2D(RTScene, vec2(vTexCoord.x + 3.0*blurSize, vTexCoord.y)) * 0.09;
    sum += texture2D(RTScene, vec2(vTexCoord.x + 4.0*blurSize, vTexCoord.y)) * 0.05;
    
    gl_FragColor = sum;

}