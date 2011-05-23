//
//  GemGlow.h
//  GLEngine
//
//  Created by Pi on 22/05/2011.
//  Copyright 2011 Pi. All rights reserved.
//

#import "GLView.h"

#import "Vertex.h"

//  A T T R I B U T E S  &  U N I F O R M S

typedef struct { GLfloat x,y; } GLVecXY;
typedef struct { GLfloat s,t; } GLVecST;
typedef struct { GLfloat r,g,b,a; } GLVecRGBA;
typedef union { 
    struct { GLfloat x, y, s, t, r, g, b, a; };
	struct { GLVecXY xy; GLVecST st; GLVecRGBA rgba; };  } VERTEX_XY_ST_RGBA;

enum {
    U0_MATRIX,
    U1_SAMP_ID_GEM,
    U1_SAMP_ID_SPARKLE,
    U3_GLOWFACTOR,
    UNIFORM_COUNT
};

enum 
{
    A0_VERTEX_XY,
    A1_TEXCOORD_ST,
    A2_COLOR_RGBA,
    ATTRIBUTE_COUNT
};


@interface GemGlow : GLView {
    GLuint TexID_Gem, TexID_Sparkle;

    
    ATTRIBUTE* atts;
    char** unifs;
}

@end
