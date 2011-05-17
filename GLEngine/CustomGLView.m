//
//  CustomGLView.m
//  F33rsmEnjinn
//
//  Created by Pi on 16/05/2011.
//  Copyright 2011 Pi. All rights reserved.
//

#import "glHelper.h"

#import "CustomGLView.h"

@interface CustomGLView ()
- (void) genTexture;
- (void) renderTestQuadWithTexture: (GLuint) texID;
@end

// = = = = = = = = = = = = = = =  

@implementation CustomGLView



        
#define bytesForStructMember(STRUCT, MEMBER) sizeof( ((STRUCT *)NULL)->MEMBER )
#define glFloatsFor(STRUCT, MEMBER) bytesForStructMember( STRUCT, MEMBER ) / sizeof( GLfloat )

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    
    [Indent log: @"Custom view's initWithCoder:" ];
    [Indent inc];
    
    if (self) {
        NSLog( @" " );
        //[Indent log: @"invoking GLView's setupContextAndFBOs"];
        [self setupContextAndFBOs];
                
        NSLog( @" " );
        [self genTexture];
        
        NSLog( @" " );
        [Indent log: @"Filling in structs for attributes & uniforms"];
        atts = ( ATTRIBUTE [] )
        {
            { A0_VERTEX_XY,     "A0_glVertex",             glFloatsFor( VERTEX_XY_ST_RGBA, xy ),    offsetof( VERTEX_XY_ST_RGBA, xy ) },
            { A1_TEXCOORD_ST,   "A1_glMultiTexCoord_st",   glFloatsFor( VERTEX_XY_ST_RGBA, st ),    offsetof( VERTEX_XY_ST_RGBA, st ) },
            { A2_COLOR_RGBA,    "A2_glColor",              glFloatsFor( VERTEX_XY_ST_RGBA, rgba ),  offsetof( VERTEX_XY_ST_RGBA, rgba ) },
            { ATTRIBUTE_COUNT,  END_OF_ATTRIBUTES, 0, 0 }
        };
        
        unifs = ( char* [] )
        {
            "U0_glMVPMatrix", 
        };

        // this is a GLView method
        NSLog( @" " );
        //[Indent log: @"invoking GLView's setupProgramWithShader:attributes:uniforms: passing in custom data"];
        [self setupProgramWithShader: @"Shader"
                          attributes: atts
                            uniforms: unifs ];
        
        NSLog( @" " );
        //[Indent log: @"invoking GLView's setupVertexArray: passing in custom data"];
        [self setupVertexArrayPointers: atts];
        
        NSLog( @" " );
        //[Indent log: @"invoking GLView's startDrawing"];
        [self startDrawing];
    }
    
    [Indent dec];
    
    return self;
}



- (void) genTexture
{
    // Create A 512x512 greyscale texture
    {
		// MUST be power of 2 for W & H or FAILS!
		GLuint W = 512, H = 512;
		
		[Indent log: [ NSString stringWithFormat: @"Generating texture @ %d x %d \n", W, H ] ];
		
        // Create a pretty greyscale pixel pattern
		GLubyte *P = calloc( 1, ( W * H * 4 * sizeof( GLubyte ) ) );
        
        for ( GLuint i = 0; ( i < H ); ++i )
        {
            for ( GLuint j = 0; ( j < W ); ++j )
            {
                P[( ( i * W + j ) * 4  +  0 )] =
                P[( ( i * W + j ) * 4  +  1 )] =
                P[( ( i * W + j ) * 4  +  2 )] =
                P[( ( i * W + j ) * 4  +  3 )] = ( i ^ j );
            }
        }       
        
		// Ask GL to give us a texture-ID for us to use
		glGenTextures( 1, & texId_XORPattern );
		
        // make it the ACTIVE texture, ie functions like glTexImage2D will 
		// automatically know to use THIS texture
		glBindTexture( GL_TEXTURE_2D, texId_XORPattern );
		
        // set some params on the ACTIVE texture
		glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
        
		// WRITE/COPY from P into active texture  
        glTexImage2D( GL_TEXTURE_2D, 0, GL_RGBA, W, H, 0, GL_RGBA, GL_UNSIGNED_BYTE, P );
		
        free( P );
        
        glLogAndFlushErrors();
    }

}



- (void)dealloc
{
    [super dealloc];
}



- (void) willRender
{
    glLogAndFlushErrors();
    
	// clear the COLOR buffer,
	glClearColor(0.0f, 0.0f, 0.1f, 1.0f);
    glClear( GL_COLOR_BUFFER_BIT );

    glLogAndFlushErrors();
	
    // MV*P matrix
    {
        float fac = .9 * MIN( backingWidth, backingHeight );
        
        float x = fac / (float) backingWidth ;   // eg 768 / 768  = 1
        float y = fac / (float) backingHeight ;  // eg 768 / 1024 = .75
        
        
        static float t=0.f;
        t+=.05;
        
        // Setup uniform (matrix, sampler) state.  
        const GLfloat M[ ] = // Assumes ( MV * P ) matrix.
        {
            x * cos(t),  -sin(t),      .0,    .0,  
            sin(t),      y * cos(t),   .0,    .0, 
            .0,         .0,           1.0,    .0,  
            .0,         .0,            .0,   1.0  };
        
        // NOTE: Need to call glUseProgram BEFORE doing this.
        GLint matrixUnifId = [ self uniformId: (GLuint)0 /* U0_MATRIX */ ];
        glUniformMatrix4fv( matrixUnifId, 1, GL_FALSE, M );                
	}
    
    glLogAndFlushErrors();
    
    [self renderTestQuadWithTexture: texId_XORPattern];
}



- (void) renderTestQuadWithTexture: (GLuint) texID
{
    VERTEX_XY_ST_RGBA testQuad[4] = 
    {
        //  X   Y    S  T    R  G  B  A
        {.xy = {-.5, -.5}, .st = {0, 0}, .rgba = {1, 0, 0, 1} },
        {.xy = { .5, -.5}, .st = {1, 0}, .rgba = {1, 0, 0, 1} },
        {.xy =  { .5,  .5}, .st = {1, 1}, .rgba = {1, 0, 0, 1} },
        {.xy =  {-.5,  .5}, .st = {0, 1}, .rgba = {1, 0, 0, 1} },
    };
    
    glBufferData( GL_ARRAY_BUFFER, sizeof( testQuad ), testQuad, GL_STATIC_DRAW );               
    
    GLushort quadIndices[] = {0, 1, 3, 2}; 
    
    
    glBindTexture( GL_TEXTURE_2D, texID );
    
    if (1)
    {
        glDrawElements( GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_SHORT, quadIndices );
    }
    else
    {
        GLuint tqIndex_BufID;
        glGenBuffers( 1, & tqIndex_BufID );
        glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, tqIndex_BufID ); 
        glBufferData( GL_ELEMENT_ARRAY_BUFFER, sizeof( quadIndices ), quadIndices, GL_STATIC_DRAW );  
        
        glDrawElements( GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_SHORT, NULL );
    }
    
    glLogAndFlushErrors();
}

@end
