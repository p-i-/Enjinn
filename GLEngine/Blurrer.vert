//
//  Shader.vert
//  F33rsmEnjinn
//

precision mediump float;

attribute highp   vec4 A0_glVertex;       
attribute highp   vec2 A1_glMultiTexCoord_st;    

varying   mediump vec2 vTexCoord;            

uniform   highp   mat4 U0_glMVPMatrix;            

void main( void )                   
{
    vTexCoord  = vec2( A1_glMultiTexCoord_st );             
    
    gl_Position = vec4( U0_glMVPMatrix * A0_glVertex );
}
