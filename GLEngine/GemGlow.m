//
//  GemGlow.m
//  GLEngine
//
//  Created by Pi on 22/05/2011.
//  Copyright 2011 Pi. All rights reserved.
//

#import "glHelper.h"

#import "GemGlow.h"

#import "GLTexture.h"
#import "Program.h"

@interface GemGlow ( )

- (void) renderQuad;

@property (retain) Program* program;

@end



@implementation GemGlow

@synthesize program;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    
    if (! self)
        return nil;
    
    LOG( @"GemGlow's initWithCoder:" );
    [PiLog indent];
    
    {
        int maxTextureImageUnits;
        glGetIntegerv( GL_MAX_TEXTURE_IMAGE_UNITS, & maxTextureImageUnits );
        
        LOG( @"MaxTextureImageUnits: %d", maxTextureImageUnits );
    }
    
    LOG( @"" );
    [self setupContextAndFBOs];
    
    LOG( @"" );
    LOG( @"Generating texture" );
    
    
    NSString* gemFile = [[NSBundle mainBundle] pathForResource:@"gem" ofType:@"jpg"];
    UIImage* gem = [UIImage imageWithContentsOfFile: gemFile];
    
    [GLTexture  createGLTextureFromImage:              gem
                                POTWidth: (GLuint)     1024
                               POTHeight: (GLuint)     1024
                          returningTexId:              & TexID_Gem ];
    

    NSString* sparkleFile = [[NSBundle mainBundle] pathForResource:@"sparkle" ofType:@"jpg"];
    UIImage* sparkle = [UIImage imageWithContentsOfFile: sparkleFile];
    
    [GLTexture  createGLTextureFromImage:              sparkle
                                POTWidth: (GLuint)     1024
                               POTHeight: (GLuint)     1024
                          returningTexId:              & TexID_Sparkle ];
    
    
    
    
    LOG( @"" );
    LOG( @"Filling in structs for attributes & uniforms" );
    atts = ( ATTRIBUTE [] )
    {
        { A0_VERTEX_XY,    "A0_vertex_xy",    glFloatsFor( VERTEX_XY_ST_RGBA, xy   ),  offsetof( VERTEX_XY_ST_RGBA, xy   ) },
        { A1_TEXCOORD_ST,  "A1_texCoord_st",  glFloatsFor( VERTEX_XY_ST_RGBA, st   ),  offsetof( VERTEX_XY_ST_RGBA, st   ) },
        { A2_COLOR_RGBA,   "A2_color_rgba",   glFloatsFor( VERTEX_XY_ST_RGBA, rgba ),  offsetof( VERTEX_XY_ST_RGBA, rgba ) },
        { ATTRIBUTE_COUNT, END_OF_ATTRIBUTES, 0                                     ,  0                                   }
    };
    
    unifs = ( char* [] )
    {
        "U0_matrix", 
        "U1_sampId_Gem",
        "U2_sampId_Sparkle",
        "U3_glowFactor",
        END_OF_UNIFORMS
    };
    
    // this is a GLView method
    LOG( @"" );
    
    
    self.program = [Program program];
    
    [program setupProgramWithShader: @"GemGlow"
                         attributes: atts
                           uniforms: unifs ];
    
    
    LOG( @"" );
    GLuint id_VertBuf;
    [Vertex setupVertexArrayPointers: atts
                  returningVertBufId: & id_VertBuf ];
    
    
    // bind gem texture to slot #0, and inform shader via uniform
    glActiveTexture( GL_TEXTURE0 );
    glBindTexture( GL_TEXTURE_2D, TexID_Gem );
    glUniform1i( [ program uniformId: U1_SAMP_ID_GEM ],  (GLuint)0 );
    
    // ... similarly for texture #1
    glActiveTexture( GL_TEXTURE1 );
    glBindTexture( GL_TEXTURE_2D, TexID_Sparkle );
    glUniform1i( [ program uniformId: U1_SAMP_ID_SPARKLE ],  (GLuint)1 );

    
    
    // [program genVertBufWithId
    
    LOG( @"" );
    [self startDrawing];
    
    [PiLog outdent];
    
    return self;
}



#define ROTATE NO
- (void) willRender
{    
    // sort out blending
    glDisable( GL_DEPTH_TEST );
    glEnable( GL_BLEND );
    glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
    
	// clear the COLOR buffer,
	glClearColor(0.0f, 1.0f, 0.0f, 1.0f);
    glClear( GL_COLOR_BUFFER_BIT );
	
    // MV*P matrix
    {
        float fac = .9 * MIN( backingWidth, backingHeight );
        
        float x = fac / (float) backingWidth ;   // eg 768 / 768  = 1
        float y = fac / (float) backingHeight ;  // eg 768 / 1024 = .75
        
        
        static float t=0.f;
        if(ROTATE)
            t+=.05;
        
        // Setup uniform (matrix, sampler) state.  
        const GLfloat M[ ] = // Assumes ( MV * P ) matrix.
        {
            x * cos(t),  -sin(t),      .0,    .0,  
            sin(t),      y * cos(t),   .0,    .0, 
            .0,         .0,           1.0,    .0,  
            .0,         .0,            .0,   1.0  };
        
        // NOTE: Need to call glUseProgram BEFORE doing this.
        GLint matrixUnifId = [ program uniformId: U0_MATRIX ];
        glUniformMatrix4fv( matrixUnifId, 1, GL_FALSE, M );                
	}
    
    glLogAndFlushErrors();
    
    [self renderQuad];
}

#define  PULSE  YES
- (void) renderQuad
{
    float s = 1.f;
    VERTEX_XY_ST_RGBA testQuad[4] = 
    {
        {.xy = {-s, -s}, .st = {0, 0}, .rgba = {0, 0, 1, 1} },
        {.xy = { s, -s}, .st = {1, 0}, .rgba = {1, 0, 0, 1} },
        {.xy = { s,  s}, .st = {1, 1}, .rgba = {1, 0, 0, 1} },
        {.xy = {-s,  s}, .st = {0, 1}, .rgba = {1, 0, 0, 1} },
    };
    
    glBufferData( GL_ARRAY_BUFFER, sizeof( testQuad ), testQuad, GL_STATIC_DRAW );               
    
    GLushort quadIndices[] = {0, 1, 3, 2}; 
    
    
    
    
    static float f = M_PI; //  / 2.f;
    if (PULSE)
        f+=.02;
    float glowFac = (sin(f)+ 1.) / 2.;
    glUniform1f( [ program uniformId: U3_GLOWFACTOR ], glowFac );   

    
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
