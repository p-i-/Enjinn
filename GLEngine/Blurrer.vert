//
//  Shader.vert
//  F33rsmEnjinn
//
//  Derived from GLYoda (aka Max Rupp)'s web.cecs.pdx.edu/~feelgood/Source/FBO.c
//

precision mediump float;

attribute highp   vec4 A0_glVertex;       
attribute highp   vec2 A1_glMultiTexCoord_st;    

varying   mediump vec2 V0_glTexCoord_st;            

uniform   highp   mat4 U0_glMVPMatrix;            

void main( void )                   
{
    V0_glTexCoord_st  = vec2( A1_glMultiTexCoord_st );             
    
    gl_Position = A0_glVertex; // vec4( U0_glMVPMatrix * A0_glVertex );
}
