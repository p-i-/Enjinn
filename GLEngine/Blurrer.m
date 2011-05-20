//
//  Blurrer.m
//  GLEngine
//
//  Created by Pi on 20/05/2011.
//  Copyright 2011 Pi. All rights reserved.
//

//#import <OpenGLES/EAGL.h>
//#import <OpenGLES/EAGLDrawable.h>
//
//#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "GLTexture.h"
#import "glHelper.h"

#import "Blurrer.h"

#import "Program.h"

@implementation Blurrer

#define bytesForStructMember(STRUCT, MEMBER) sizeof( ((STRUCT *)NULL)->MEMBER )
#define glFloatsFor(STRUCT, MEMBER) bytesForStructMember( STRUCT, MEMBER ) / sizeof( GLfloat )

+ (void)  blurTexture: (GLuint)     in_texId
             POTWidth: (GLuint)     in_W
            POTHeight: (GLuint)     in_H
       returningTexId: (GLuint*)    out_pTexId
{
    // http://stackoverflow.com/questions/3613889/gl-framebuffer-incomplete-attachment-when-trying-to-attach-texture
    // search HELP: 'Using a Framebuffer Object as a Texture'
    
    // 2. Create the destination texture, and attach it to the framebuffer’s color attachment point.
    // create the texture
    GLuint id_texDest;
    
    {
        // fragshader will use 0 
        glActiveTexture( GL_TEXTURE0 );
        
        
        glGenTextures( 1, & id_texDest );
        glBindTexture( GL_TEXTURE_2D, id_texDest );
        
        
        // actually allocate memory for this texture
        GLuint pixCount = in_W * in_H;
        
        uint8_t * alphas = calloc(pixCount, sizeof( uint8_t) );

        // XOR texture
        int pix=0;
        for (int x = 0; x < in_W; x++)
            for (int y = 0; y < in_H; y++)
                alphas[ pix++ ] = x ^ y;
        
        // Ask GL to give us a texture-ID for us to use
        //glGenTextures( 1, pTexID );
        
        //glBindTexture( GL_TEXTURE_2D, id_texDest );
        
        // set some params on the ACTIVE texture
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
        
        // WRITE/COPY from P into active texture  
        glTexImage2D( GL_TEXTURE_2D, 0, GL_ALPHA, in_W, in_H, 
                     0, GL_ALPHA, GL_UNSIGNED_BYTE, (void *) alphas );
        
        glGenerateMipmap( GL_TEXTURE_2D );
        
        free( alphas );
        
        glLogAndFlushErrors();

    }
   
    
    // 3. Create a depth or depth/stencil renderbuffer, allocate storage for it, and attach it to the framebuffer’s depth attachment point.
    GLuint depthRenderbuffer;
    {
        glGenRenderbuffers(1, & depthRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, in_W, in_H);  // GL_STENCIL_INDEX8 

        // glBindRenderbuffer(GL_RENDERBUFFER, 0);
        
        glDisable( GL_DEPTH_TEST );
    }
    
    
    // *** Creating Offscreen Framebuffer Objects ***
    // 1. Create the framebuffer and bind it.
    GLuint framebuffer;
    {
        glGenFramebuffers(1, & framebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);    
        
        glFramebufferTexture2D( GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, id_texDest, 0 );
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
        
        // glBindFramebuffer(GL_FRAMEBUFFER, 0);
    }
    
    
    // 2. Create a color renderbuffer, allocate storage for it, and attach it to the framebuffer’s color attachment point.
//    GLuint colorRenderbuffer;
//    glGenRenderbuffers(1, &colorRenderbuffer);
//    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
//    glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8, width, height);
//    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
    
    
    
    
    
    
    
   
    
    // 3...
    
    // 4. Test the framebuffer for completeness. This test only needs to be performed when the framebuffer’s configuration changes.
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER) ;
    if(status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complete framebuffer object %x", status);
    }
// ^^^ Always 0x8cd6 GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT
    
	// clear the COLOR buffer,

    glLogAndFlushErrors();

	
    float j = 0.9f;
    glClearColor( j, j, j, j );
    glClear( GL_COLOR_BUFFER_BIT );

    //glViewport(0, 0, in_W, in_H);

    * out_pTexId = id_texDest;
    
    return;
    
    
    
    //Blurrer* B = [[[Blurrer alloc] init] autorelease];
    
    typedef struct { GLfloat x,y; } GLVecXY;
    typedef struct { GLfloat s,t; } GLVecST;
    //typedef struct { GLfloat r,g,b,a; } GLVecRGBA;
    typedef union { 
        struct { GLfloat x, y, s, t /*, r, g, b, a*/; };
        struct { GLVecXY xy; GLVecST st; 
            //GLVecRGBA rgba; 
        };  } VERTEX_XY_ST//_RGBA;
    ;
    
    enum 
    {
        U0_MATRIX
    };
    
    enum 
    {
        A0_VERTEX_XY,
        A1_TEXCOORD_ST,
        A2_COLOR_RGBA,
        ATTRIBUTE_COUNT
    };

    ATTRIBUTE* atts = ( ATTRIBUTE [] )
    {
        { A0_VERTEX_XY,     "A0_glVertex",             glFloatsFor( VERTEX_XY_ST, xy ),    offsetof( VERTEX_XY_ST, xy ) },
        { A1_TEXCOORD_ST,   "A1_glMultiTexCoord_st",   glFloatsFor( VERTEX_XY_ST, st ),    offsetof( VERTEX_XY_ST, st ) },
        //{ A2_COLOR_RGBA,    "A2_glColor",              glFloatsFor( VERTEX_XY_ST_RGBA, rgba ),  offsetof( VERTEX_XY_ST_RGBA, rgba ) },
        { ATTRIBUTE_COUNT,  END_OF_ATTRIBUTES, 0, 0 }
    };
    
    char** unifs = ( char* [] )
    {
        "U0_glMVPMatrix", 
    };

    Program* program;
    
    [program setupProgramWithShader: @"Blur"
                         attributes: atts
                           uniforms: unifs ];
    
    float k = 0.8;
    VERTEX_XY_ST testQuad[4] = 
    {
        //  X   Y    S  T    R  G  B  A
        {.xy = {-k, -k}, .st = {0, 0} },
        {.xy = { k, -k}, .st = {1, 0} },
        {.xy = { k,  k}, .st = {1, 1} },
        {.xy = {-k,  k}, .st = {0, 1} },
    };
    
    glBufferData( GL_ARRAY_BUFFER, sizeof( testQuad ), testQuad, GL_STATIC_DRAW );               
    
    GLushort quadIndices[] = {0, 1, 3, 2}; 
    
    
    glBindTexture( GL_TEXTURE_2D, in_texId );
    
    glDrawElements( GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_SHORT, quadIndices );

}

@end