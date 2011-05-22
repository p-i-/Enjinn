//
//  CustomGLView.m
//  F33rsmEnjinn
//
//  Created by Pi on 16/05/2011.
//  Copyright 2011 Pi. All rights reserved.
//

#import "glHelper.h"

#import "CustomGLView.h"

#import "GLTexture.h"

#import "Blurrer.h"

#import "Program.h"

@interface CustomGLView ( )
- (void) texDrawFunc: (id) id_X;
- (void) renderTestQuadWithTexture: (GLuint) texID;

@property (nonatomic, retain) Program*          program;

@end

// = = = = = = = = = = = = = = =  

@implementation CustomGLView

@synthesize program;
        
#define bytesForStructMember(STRUCT, MEMBER) sizeof( ((STRUCT *)NULL)->MEMBER )
#define glFloatsFor(STRUCT, MEMBER) bytesForStructMember( STRUCT, MEMBER ) / sizeof( GLfloat )


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    
    if (! self)
        return nil;
    
    LOG( @"Custom view's initWithCoder:" );
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
    
    switch ( demo ) {
        case demo_RenderTexturedQuad_XORBitPattern:
        {
            [GLTexture createTestXORGLTextureWidth: (GLuint) 1024
                                            height: (GLuint) 1024
                                    returningTexId: & texId_test ] ;
            break;
        }
            
        case demo_RenderTexturedQuad_DrawFunc:
        {
            [GLTexture  genTexOfWidth: (GLuint)    1024
                               height: (GLuint)    1024
                         drawFuncTarg: (id)        self
                          drawFuncSel:             @selector(texDrawFunc:)
                       returningTexId:             & texId_test ] ;
            break;
        }
            
        case demo_RenderTexturedQuad_TexFromImage:
        {
            NSString* gemFile = [[NSBundle mainBundle] pathForResource:@"gem" ofType:@"jpg"];
            UIImage* gem = [UIImage imageWithContentsOfFile: gemFile];
            
            [GLTexture  createGLTextureFromImage:              gem
                                        POTWidth: (GLuint)     1024
                                       POTHeight: (GLuint)     1024
                                  returningTexId:              & texId_test ];
            break;
        }
            
        case demo_RenderToTexture:
        {
            GLuint texId_gem;
            
            NSString* gemFile = [[NSBundle mainBundle] pathForResource:@"gem" ofType:@"jpg"];
            UIImage* gem = [UIImage imageWithContentsOfFile: gemFile];
            
            [GLTexture  createGLTextureFromImage:              gem
                                        POTWidth: (GLuint)     1024
                                       POTHeight: (GLuint)     1024
                                  returningTexId:              & texId_gem ];
            
            glLogAndFlushErrors();
            
            [Blurrer  createTextureByBlurringTexture: texId_gem
                                             POTSize: (GLSize) {1024, 1024}
                                      returningTexId: & texId_test ];
            break;
        }
            
        default:
            break;
    }
    
    glLogAndFlushErrors();
    
    
    LOG( @"" );
    LOG( @"Filling in structs for attributes & uniforms" );
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
    LOG( @"" );
    
    
    self.program = [Program program];
    
    [program setupProgramWithShader: @"Shader"
                         attributes: atts
                           uniforms: unifs ];
    
    
    LOG( @"" );
    GLuint id_VertBuf;
    [Vertex setupVertexArrayPointers: atts
                  returningVertBufId: & id_VertBuf ];
    
    // [program genVertBufWithId
    
    LOG( @"" );
    [self startDrawing];

    [PiLog outdent];
    
    return self;
}

- (void) texDrawFunc: (id) id_X
{
    CGContextRef X = (CGContextRef) id_X;
    CGSize bitmapSize = CGSizeMake( CGBitmapContextGetWidth( X ), CGBitmapContextGetHeight( X ) );
    
    {
        CGPoint center = CGPointMake( bitmapSize.width / 2., 
                                     bitmapSize.height / 2. );
		
        
        CGRect bounds = CGRectMake( 0, 0, bitmapSize.width, bitmapSize.height );
        
        // fill background rect dark red
        CGContextSetAlpha(X, 0.1);
        CGContextFillRect(X, bounds);
        
        // circle
        CGContextSetAlpha(X, 0.5);
        CGContextFillEllipseInRect(X, bounds);
        
        // fat rounded-cap line from origin to center of view
        CGContextSetAlpha(X, 0.8);
        CGContextSetLineWidth(X, 30);	
        CGContextSetLineCap(X, kCGLineCapRound);
        CGContextBeginPath(X);
        CGContextMoveToPoint(X, 0,0);
        CGContextAddLineToPoint(X, center.x, center.y);
        CGContextStrokePath(X);
    }
}

- (void)dealloc
{
    [super dealloc];
}


#define ROTATE YES
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
        GLint matrixUnifId = [ program uniformId: (GLuint)0 /* U0_MATRIX */ ];
        glUniformMatrix4fv( matrixUnifId, 1, GL_FALSE, M );                
	}
    
    glLogAndFlushErrors();
    
    [self renderTestQuadWithTexture: texId_test];
}



- (void) renderTestQuadWithTexture: (GLuint) texID
{
    VERTEX_XY_ST_RGBA testQuad[4] = 
    {
        //  X   Y    S  T    R  G  B  A
        {.xy = {-.5, -.5}, .st = {0, 0}, .rgba = {0, 0, 1, 1} },
        {.xy = { .5, -.5}, .st = {1, 0}, .rgba = {1, 0, 0, 1} },
        {.xy =  { .5,  .5}, .st = {1, 1}, .rgba = {1, 0, 0, 1} },
        {.xy =  {-.5,  .5}, .st = {0, 1}, .rgba = {1, 0, 0, 1} },
    };
    
    glBufferData( GL_ARRAY_BUFFER, sizeof( testQuad ), testQuad, GL_STATIC_DRAW );               
    
    GLushort quadIndices[] = {0, 1, 3, 2}; 
    
    
    glActiveTexture( GL_TEXTURE0 );
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
