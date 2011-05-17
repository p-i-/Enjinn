//
//  GLProgram.m
//  F33rsmEnjinn
//
//  Created by Pi on 05/03/2011.
//  Copyright 2011 Pi. All rights reserved.
//

#import "glHelper.h"

#import "GLProgram.h"
#import "ShaderAux.h"

@implementation GLProgram


+ (id) program
{
    return [ [ [ GLProgram alloc ] init ] autorelease ];
}

- (id) init
{
    self = [super init];
    
    programId = glCreateProgram();
    
    return self;
}

- (void) use
{
    [Indent log: @"Make program active program" ];
    glUseProgram( programId );
}

- (BOOL) loadShadersCompileAndLink: (NSString*) in_shader
                 bindingAttributes: ( ATTRIBUTE [] ) in_attributeArray 
{
    [Indent log: @"loadShadersCompileAndLink:bindingAttributes:" ];
    [Indent inc];
    
    [Indent log: [ NSString stringWithFormat: @"Loading %@.vert & %@.frag", in_shader, in_shader ] ];
    
    // load, compile & attach shaders
    GLuint vertShader, fragShader;
    {
        NSString* vert_path = [[NSBundle mainBundle] pathForResource: in_shader  ofType: @"vert"];
        NSString* frag_path = [[NSBundle mainBundle] pathForResource: in_shader  ofType: @"frag"];
        
        NSAssert( (vert_path != 0x0) && (frag_path != 0x0), @"Couldn't locate shader! Make sure it's added to the target: target -> build phases -> copy bundle resources \n" );

        [Indent log: @"Compiling shaders" ];
        bool vs_ok = [ShaderAux  compileShaderOfType: GL_VERTEX_SHADER
                                            filename: vert_path
                                   returningShaderId: & vertShader ];
        
        bool fs_ok = [ShaderAux  compileShaderOfType: GL_FRAGMENT_SHADER
                                            filename: frag_path
                                   returningShaderId: & fragShader ];
        
        glLogAndFlushErrors();
        
        NSAssert( vs_ok && fs_ok, @"Failed to compile shader! \n" );
        
        
        [Indent log: @"Attaching shaders to program" ];
        glAttachShader( programId, vertShader );
        glAttachShader( programId, fragShader );
        
        glLogAndFlushErrors();
	}
    
    [self bindAttributes: in_attributeArray];
    
    // LINK program
    {
        [Indent log: @"Linking program" ];
        bool ok = [ShaderAux linkProgram: programId];
        NSAssert( ok, @"Failed to link program! \n" );
        glLogAndFlushErrors();
    }
    
    // Validate
    {
        // Validate program before drawing. This is a good check, but only really necessary in a debug build.
        // DEBUG macro must be defined in your debug configurations if that's not already the case.
#if defined(DEBUG)
        [Indent log: @"Validating program" ];
        bool ok = [ShaderAux validateProgram: programId];
        NSAssert( ok, @"Failed to validate program: %d", programId);
#endif	
    }
    
    // Delete shaders
    {
        [Indent log: @"Deleting shaders" ];
        glDeleteShader( vertShader );
        glDeleteShader( fragShader );
    }
    
    [Indent dec];
    return YES;
}


- (void) processUniformArray: ( char* [] ) in_uniformArray
{
    [Indent log: @"Processing UniformArray:" ];
    [Indent inc];
    
    // determine # attributes and uniforms
    int uniformCount = 0;
    while ( in_uniformArray[ uniformCount ] )
        uniformCount++;
    
    uniformIds = calloc( uniformCount, sizeof( GLuint ) );
    
    // get uniform locations (we later use uniforms[ k ] to change value of that uniform)
    {
        for (int i=0;  in_uniformArray[ i ];  i++)
        {            
            uniformIds[ i ] = glGetUniformLocation( programId, in_uniformArray[ i ] ); 
            
            [Indent log: [ NSString stringWithFormat: @"Uniform '%s' is at location: %d",  in_uniformArray[ i ],  uniformIds[ i ]] ];
            NSAssert( uniformIds[ i ] >= 0, @"Problem with uniform '%s'", in_uniformArray[ i ] );
        }
        
        glLogAndFlushErrors();
    }
    
    [Indent dec];
}

- (void) bindAttributes: ( ATTRIBUTE [] ) in_attributeArray
{
    [Indent log: @"bindAttributes" ];
    [Indent inc];
    
    /*
     Every time we wish to render a frame, we throw a raw buffer of vertex data at our vertex shader.  In our case each vertex consists of 8 glFloats.
     
     This is where we tell the vertex shader how to translate this raw dump into the variables (ie attributes) it will use.
     */
    int attribBytesTotal, attribCount;
    {
        int i=0, floatsTotal = 0;
        while( YES )
        {
            ATTRIBUTE* pA = & in_attributeArray[ i ];
            
            if ( pA->token == END_OF_ATTRIBUTES )
                break;
            
            [Indent log: [ NSString stringWithFormat: @"Attribute #%d: '%s'", i, pA->token ] ];
            
            glBindAttribLocation( programId, i, pA->token );
            
            floatsTotal += pA->glFloats;
            i++;
        } ;
        
        glLogAndFlushErrors();
        
        attribBytesTotal = floatsTotal * sizeof( GLfloat );
        attribCount = i;
    }
    
    [Indent dec];
}


- (GLint) uniformId: (GLuint) index
{
    return uniformIds[ index ];
}


@end
