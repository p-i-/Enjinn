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

#import "Vertex.h"


@interface Blurrer ()

+ (void)   createTextureByRotatingTexture: (GLuint)     in_id_tex
                                  POTSize: (GLSize)     in_POTSize
                                  byTheta: (GLfloat)    in_theta
               thenBlurringReturningTexId: (GLuint *)   out_p_id_tex ;
@end


@implementation Blurrer

+ (void)  createTextureByBlurringTexture: (GLuint)     in_id_tex
                                 POTSize: (GLSize)     in_POTSize
                          returningTexId: (GLuint *)   out_p_id_tex
{
    GLuint id_texIntermediate;
    
    [Blurrer createTextureByRotatingTexture: in_id_tex
                                    POTSize: in_POTSize
                                    byTheta: M_PI / 2.
                 thenBlurringReturningTexId: & id_texIntermediate ];
    
    [Blurrer createTextureByRotatingTexture: id_texIntermediate
                                    POTSize: in_POTSize
                                    byTheta: - M_PI / 2.
                 thenBlurringReturningTexId: out_p_id_tex ];


}


#define bytesForStructMember(STRUCT, MEMBER) sizeof( ((STRUCT *)NULL)->MEMBER )
#define glFloatsFor(STRUCT, MEMBER) bytesForStructMember( STRUCT, MEMBER ) / sizeof( GLfloat )

// Use GL_TEXTURE0 for SOURCE, GL_TEXTURE1 for DESTINATION
+ (void)   createTextureByRotatingTexture: (GLuint)     in_id_tex
                                  POTSize: (GLSize)     in_POTSize
                                  byTheta: (GLfloat)    in_theta
               thenBlurringReturningTexId: (GLuint *)   out_p_id_tex
{
    GLuint W = in_POTSize.x;
    GLuint H = in_POTSize.y;
    
    // create the texture
    GLuint id_texRGBA;
    {
        // 1 for dest -- fragshader will use 0 for src
        glActiveTexture( GL_TEXTURE1 ); 
        
        // Ask GL to give us a texture-ID for us to use
        glGenTextures( 1, & id_texRGBA );
        glBindTexture( GL_TEXTURE_2D, id_texRGBA );
        
        // actually allocate memory for this texture
        GLuint pixCount = W * H;
        
        typedef struct { uint8_t r, g, b, a } rgba;
        
        rgba * alphas = calloc( pixCount, sizeof( rgba ) );
        
        // set some params on the ACTIVE texture
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
        
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
        glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
        
        // WRITE/COPY from P into active texture  
        glTexImage2D( GL_TEXTURE_2D, 0,
                     GL_RGBA, W, H, 0, 
                     GL_RGBA, 
                     GL_UNSIGNED_BYTE, 
                     (void *) alphas );
        
        free( alphas );
        
        glLogAndFlushErrors();
    }
    
    
    GLint oldFBO;
    glGetIntegerv( GL_FRAMEBUFFER_BINDING, & oldFBO );
    {
        GLuint textureFrameBuffer;
        
        // create framebuffer
        glGenFramebuffers( 1, & textureFrameBuffer );
        glBindFramebuffer( GL_FRAMEBUFFER, textureFrameBuffer );
        
        // attach renderbuffer
        glFramebufferTexture2D( GL_FRAMEBUFFER, 
                               GL_COLOR_ATTACHMENT0, 
                               GL_TEXTURE_2D, 
                               id_texRGBA, 
                               0 );
                
        // Test the framebuffer for completeness. This test only needs to be performed when the framebuffer’s configuration changes.
        // 36054  0x8CD6  GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT
        GLenum status = glCheckFramebufferStatus( GL_FRAMEBUFFER ) ;
        NSAssert1( status == GL_FRAMEBUFFER_COMPLETE, @"failed to make complete framebuffer object %x", status );
        
        
        
        typedef struct { GLfloat x,y; } GLVecXY;
        typedef struct { GLfloat s,t; } GLVecST;
        typedef union {  struct{GLfloat x,y,s,t;};struct{GLVecXY xy;GLVecST st;};  }  VERTEX_XY_ST;
        
        enum 
        {
            A0_VERTEX_XY,
            A1_TEXCOORD_ST,
            ATTRIBUTE_COUNT
        };
        
        ATTRIBUTE* atts = ( ATTRIBUTE [] )
        {
            { A0_VERTEX_XY,     "A0_glVertex",             glFloatsFor( VERTEX_XY_ST, xy ),    offsetof( VERTEX_XY_ST, xy ) },
            { A1_TEXCOORD_ST,   "A1_glMultiTexCoord_st",   glFloatsFor( VERTEX_XY_ST, st ),    offsetof( VERTEX_XY_ST, st ) },
            { ATTRIBUTE_COUNT,  END_OF_ATTRIBUTES, 0, 0 }
        };
        
        enum 
        {
            U0_MATRIX,
            U1_SRC_TEXTURE,
            U2_BLURSIZE,
            UNIFORM_COUNT
        };
        
        char** unifs = ( char* [] )
        {
            "U0_glMVPMatrix", 
            "U1_srcTexture", 
            "U2_blurSize", 
            NULL
        };
        
        
        
        Program* program = [Program program];
        
        [program setupProgramWithShader: @"Blurrer"
                             attributes: atts
                               uniforms: unifs ];
                
        GLuint id_VertBuf;
        [Vertex setupVertexArrayPointers: atts
                      returningVertBufId: & id_VertBuf ];
                
        // load uniforms
        {
            //matrix
            {
                float t = in_theta;
                
                const GLfloat M[ ] = // Assumes ( MV * P ) matrix.
                {
                    cos(t),     -sin(t),        .0,    .0,  
                    sin(t),      cos(t),        .0,    .0, 
                    .0,          .0,           1. ,    .0,  
                    .0,          .0,            .0,   1.   };
                
                // NOTE: Need to call glUseProgram BEFORE doing this.
                GLint matrixUnifId = [ program uniformId: (GLuint)U0_MATRIX  ];
                glUniformMatrix4fv( matrixUnifId, 1, GL_FALSE, M );                
            }
            
            
            // set src texture to 0 (for GL_TEXTURE0)
            {
                GLint srcTexId = [ program uniformId: (GLuint)U1_SRC_TEXTURE ];
                
                glUniform1i( srcTexId, 0 );
            }
            
            // blur
            {
                GLint blurId = [ program uniformId: (GLuint)U2_BLURSIZE ];
                glUniform1f( blurId, 25.f/1024.f );
            }
        }
        
        // load points
        {
            VERTEX_XY_ST testQuad[4] = 
            {
                {.xy = {-1, -1}, .st = {0, 0} },
                {.xy = { 1, -1}, .st = {1, 0} },
                {.xy = { 1,  1}, .st = {1, 1} },
                {.xy = {-1,  1}, .st = {0, 1} },
            };
            
            glBufferData( GL_ARRAY_BUFFER, sizeof( testQuad ), testQuad, GL_STATIC_DRAW );         
        }
        
        // bind source texture to slot GL_TEXTURE0
        glActiveTexture( GL_TEXTURE0 );
        glBindTexture( GL_TEXTURE_2D, in_id_tex );
        
        // this will map gl(-1,-1) -> pixel(0,0) and gl(1,1) -> pix(W,H)
        glViewport( 0, 0, W, H );
        
        // DRAW QUAD!
        GLushort quadIndices[] = { 0, 1, 3, 2 }; 
        glDrawElements( GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_SHORT, quadIndices );
        
        // don't need vertex buffer any more
        glDeleteBuffers( 1, & id_VertBuf );

        // http://www.opengl.org/wiki/Common_Mistakes#glFinish_and_glFlush says dont need these         
        //        // flush any pending operations
        //        glFlush();
        //        
        //        // ... and wait for all GL processes to complete
        //        glFinish();
        
        // unbind FBO before deleting it
        glBindFramebuffer( GL_FRAMEBUFFER, oldFBO );
        glDeleteFramebuffers( 1, & textureFrameBuffer );
    }
        
    
    glLogAndFlushErrors();
    
    * out_p_id_tex = id_texRGBA;
}

@end
