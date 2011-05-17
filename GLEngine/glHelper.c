//
//  glHelper.c
//  glWheel1
//
//  Created by Pi on 13/03/2011.
//  Copyright 2011 Pi. All rights reserved.
//

#import "glHelper.h"

#import "stdio.h"

#import <OpenGLES/ES2/gl.h>
#import <assert.h>
//#import <OpenGL/OpenGL.h>


char* stringForGlErr( GLenum err )
{
    switch ( err )
    {
        case GL_INVALID_ENUM:      return "GL_INVALID_ENUM";
        case GL_INVALID_VALUE:     return "GL_INVALID_VALUE";
        case GL_INVALID_OPERATION: return "GL_INVALID_OPERATION";
        //case GL_STACK_OVERFLOW:    return "GL_STACK_OVERFLOW";
        //case GL_STACK_UNDERFLOW:   return "GL_STACK_UNDERFLOW";
        case GL_OUT_OF_MEMORY:     return "GL_OUT_OF_MEMORY";
    }
    
    static char buf[ 16 ];
    
    snprintf( buf, 16, "%d", err );
    
    return buf;
}

void glLogAndFlushErrors()
{
	GLuint err, lastErr = GL_NO_ERROR;
	
	while ( ( err = glGetError() )  !=  GL_NO_ERROR ) 
        printf( "glError: %s\n", stringForGlErr( lastErr = err ) );
    
    assert ( lastErr == GL_NO_ERROR );
}

