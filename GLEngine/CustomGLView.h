//
//  CustomGLView.h
//  F33rsmEnjinn
//
//  Created by Pi on 16/05/2011.
//  Copyright 2011 Pi. All rights reserved.
//

#import "GLView.h"

//  A T T R I B U T E S  &  U N I F O R M S

typedef struct { GLfloat x,y; } GLVecXY;
typedef struct { GLfloat s,t; } GLVecST;
typedef struct { GLfloat r,g,b,a; } GLVecRGBA;
typedef union { 
    struct { GLfloat x, y, s, t, r, g, b, a; };
	struct { GLVecXY xy; GLVecST st; GLVecRGBA rgba; };  } VERTEX_XY_ST_RGBA;

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

//  - - - 

@interface CustomGLView : GLView {
    GLuint texId_test;
    ATTRIBUTE* atts;
    char** unifs;
}

@end
