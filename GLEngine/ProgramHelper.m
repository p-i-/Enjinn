//
//  ShaderAux.m
//  F33rsmEnjinn
//
//  Created by Pi on 16/05/2011.
//  Copyright 2011 Pi. All rights reserved.
//

#import "ProgramHelper.h"


@implementation ProgramHelper

+ (BOOL) compileShaderOfType: (GLenum) type
                    filename: (NSString *) file 
           returningShaderId: (GLuint *) shaderId
{
	
	NSString * ns_file = [NSString stringWithContentsOfFile: file 
												   encoding: NSUTF8StringEncoding 
													  error: nil] ;
	
	const GLchar * source = (GLchar *) [ns_file UTF8String];
	
    if (!source)
    {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
	
    * shaderId = glCreateShader( type );
    glShaderSource( *shaderId, 1, & source, NULL );
    glCompileShader( *shaderId );
	
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv( *shaderId, GL_INFO_LOG_LENGTH, & logLength );
    
    if (logLength > 0)
    {
        GLchar * log = (GLchar *) malloc( logLength );
        glGetShaderInfoLog( *shaderId, logLength, & logLength, log );
        
        NSLog( @"Shader compile log:\n%s", log );
        
        free( log );
    }
#endif
	
    GLint status;
    glGetShaderiv( *shaderId, GL_COMPILE_STATUS, & status );
    
    if (status == 0)
    {
        glDeleteShader( *shaderId );
        return NO;
    }
	
    return YES;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

+ (BOOL) linkProgram: (GLuint) prog
{
    glLinkProgram(prog);
	
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv( prog, GL_INFO_LOG_LENGTH, & logLength );
    
    if (logLength > 0)
    {
        GLchar * log = (GLchar *) malloc( logLength );
        
        glGetProgramInfoLog( prog, logLength, & logLength, log );
        
        NSLog( @"Program link log:\n%s", log );
        
        free(log);
    }
#endif
	
    GLint status;
    glGetProgramiv(prog, GL_LINK_STATUS, & status);
    
    if (status == 0)
        return FALSE;
	
    return TRUE;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

+ (BOOL) validateProgram: (GLuint) prog
{
    glValidateProgram( prog );
    
    GLint logLength;
    glGetProgramiv( prog, GL_INFO_LOG_LENGTH, & logLength );
    
    if (logLength > 0)
    {
        GLchar * log = (GLchar *) malloc( logLength );
        
        glGetProgramInfoLog( prog, logLength, & logLength, log );
        
        NSLog(@"Program validate log:\n%s", log);
        
        free(log);
    }
	
    GLint status;
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    
    if (status == 0)
        return FALSE;
	
    return TRUE;
}

@end
