//
//  Shader.vsh
//  helloGL
//
//  Created by Pi on 17/02/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

precision mediump float;

attribute vec4 A0_vertex_xy;			
attribute vec2 A1_texCoord_st;
attribute vec4 A2_color_rgba;		

varying vec2 V0_texture_ST;			
varying vec4 V1_color_RGBA;			

uniform mat4 U0_matrix; // ModelView-Projection			

void main( void )					
{
	gl_Position = vec4( U0_matrix * A0_vertex_xy );	// could do: vec4(A0.xy, 0.0, 1.0);
	
	V0_texture_ST = vec2( A1_texCoord_st );				
	V1_color_RGBA = vec4( A2_color_rgba );				
}
