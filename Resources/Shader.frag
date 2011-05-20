//
//  Shader.frag
//  F33rsmEnjinn
//
//  Derived from GLYoda (aka Max Rupp)'s web.cecs.pdx.edu/~feelgood/Source/FBO.c
//

precision mediump float;

uniform lowp    sampler2D   S0;             

varying mediump vec2  V0_glTexCoord_st;          
varying lowp    vec4  V1_glColor_rgba;                 

void main( void )                       
{                                  
    gl_FragColor = texture2D( S0, V0_glTexCoord_st ).a * V1_glColor_rgba ;
}