//
//  GLProgram.m
//  F33rsmEnjinn
//
//  Created by Pi on 05/03/2011.
//  Copyright 2011 Pi. All rights reserved.
//

#import "glHelper.h"

#import "Program.h"
#import "ProgramHelper.h"

// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 

@interface Program ()

- (BOOL) loadShadersCompileAndLink: (NSString*) in_shader
                 bindingAttributes: ( ATTRIBUTE [] ) in_attributeArray ;

- (void) processUniformArray: ( char* [] ) in_uniformArray ;

- (void) bindAttributes: ( ATTRIBUTE [] ) in_attributeArray ;

@end

// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 

@implementation Program

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

+ (id) program
{
    return [ [ [ Program alloc ] init ] autorelease ];
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

- (id) init
{
    self = [super init];
    
    id_program = glCreateProgram();
    
    return self;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

- (void) setupProgramWithShader: ( NSString * )     in_shaderFilename
                     attributes: ( ATTRIBUTE [] )   in_attributeArray
                       uniforms: ( char* [] )       in_uniformArray
{
    LOG( @"GLView: setupProgramWithShader:attributes:uniforms:" );
    [PiLog indent];
    
    NSAssert( glCheckFramebufferStatus( GL_FRAMEBUFFER ) == GL_FRAMEBUFFER_COMPLETE, @"Failed to make complete framebuffer object: Make sure you got the order right." );
    
    glLogAndFlushErrors();
    
    // calls glCreateProgram();
    // programId = [Program program];
    
    // load shaders, bind attributes, compile shaders, link shaders, validate program, delete shaders
    [self loadShadersCompileAndLink: in_shaderFilename
                     bindingAttributes: in_attributeArray ];
    
    // creates & fills an internal 'GLUint uniformIds[]' array
    [self processUniformArray: in_uniformArray];
    
    [self use];
    
    [PiLog outdent];
}


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

- (void) use
{
    LOG( @"Make program active program" );
    glUseProgram( id_program );
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

- (BOOL) loadShadersCompileAndLink: (NSString*) in_shader
                 bindingAttributes: ( ATTRIBUTE [] ) in_attributeArray 
{
    LOG( @"loadShadersCompileAndLink:bindingAttributes:" );
    [PiLog indent];
    
    glLogAndFlushErrors();
    
    
    // load, compile & attach shaders
    GLuint vertShader, fragShader;
    {
        LOG( @"Loading %@.vert & %@.frag", in_shader, in_shader );
        NSString* vert_path = [[NSBundle mainBundle] pathForResource: in_shader  ofType: @"vert"];
        NSString* frag_path = [[NSBundle mainBundle] pathForResource: in_shader  ofType: @"frag"];
        
        NSAssert( (vert_path != 0x0) && (frag_path != 0x0), @"Couldn't locate shader! Make sure it's added to the target: target -> build phases -> copy bundle resources \n" );
        
        LOG( @"Compiling shaders" );
        bool vs_ok = [ProgramHelper  compileShaderOfType: GL_VERTEX_SHADER
                                                filename: vert_path
                                       returningShaderId: & vertShader ];
        
        bool fs_ok = [ProgramHelper  compileShaderOfType: GL_FRAGMENT_SHADER
                                                filename: frag_path
                                       returningShaderId: & fragShader ];
        
        glLogAndFlushErrors();
        
        NSAssert( vs_ok && fs_ok, @"Failed to compile shader! \n" );
        
        
        LOG( @"Attaching shaders to program" );
        glAttachShader( id_program, vertShader );
        glAttachShader( id_program, fragShader );
        
        glLogAndFlushErrors();
	}
    
    [self bindAttributes: in_attributeArray];
    
    // LINK program
    {
        LOG( @"Linking program" );
        bool ok = [ProgramHelper linkProgram: id_program];
        NSAssert( ok, @"Failed to link program! \n" );
        glLogAndFlushErrors();
    }
    
    // Validate
    {
        // Validate program before drawing. This is a good check, but only really necessary in a debug build.
        // DEBUG macro must be defined in your debug configurations if that's not already the case.
#if defined( DEBUG )
        LOG( @"Validating program" );
        bool ok = [ProgramHelper validateProgram: id_program];
        NSAssert( ok, @"Failed to validate program: %d", id_program);
#endif	
    }
    
    // Delete shaders
    {
        LOG( @"Deleting shaders" );
        glDeleteShader( vertShader );
        glDeleteShader( fragShader );
    }
    
    [PiLog outdent];
    return YES;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

- (void) processUniformArray: ( char* [] ) in_uniformArray
{
    LOG( @"Processing UniformArray:" );
    [PiLog indent];
    
    // determine # attributes and uniforms
    int uniformCount = 0;
    while ( in_uniformArray[ uniformCount ] )
        uniformCount++;
    
    uniformIds = calloc( uniformCount, sizeof( GLuint ) );
    
    // get uniform locations (we later use uniforms[ k ] to change value of that uniform)
    {
        for (int i=0;  in_uniformArray[ i ];  i++)
        {            
            uniformIds[ i ] = glGetUniformLocation( id_program, in_uniformArray[ i ] ); 
            
            LOG( @"Uniform '%s' is at location: %d",  in_uniformArray[ i ],  uniformIds[ i ] );
            NSAssert( uniformIds[ i ] >= 0, @"Problem with uniform '%s'", in_uniformArray[ i ] );
        }
        
        glLogAndFlushErrors();
    }
    
    [PiLog outdent];
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

- (void) bindAttributes: ( ATTRIBUTE [] ) in_attributeArray
{
    LOG( @"bindAttributes" );
    [PiLog indent];
    
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
            
            LOG( @"Attribute #%d: '%s'", i, pA->token );
            
            glBindAttribLocation( id_program, i, pA->token );
            
            floatsTotal += pA->glFloats;
            i++;
        } ;
        
        glLogAndFlushErrors();
        
        attribBytesTotal = floatsTotal * sizeof( GLfloat );
        attribCount = i;
    }
    
    [PiLog outdent];
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

- (GLint) uniformId: (GLuint) index
{
    return uniformIds[ index ];
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

- (void) dealloc
{
    glDeleteProgram( id_program );
    
    [super dealloc];
}

@end
