//
//  Vertex.h
//  GLEngine
//
//  Created by Pi on 21/05/2011.
//  Copyright 2011 Pi. All rights reserved.
//

#import <OpenGLES/ES2/gl.h>     // GLuint

// useful when filling attribute array
#define bytesForStructMember(STRUCT, MEMBER) sizeof( ((STRUCT *)NULL)->MEMBER )
#define glFloatsFor(STRUCT, MEMBER) bytesForStructMember( STRUCT, MEMBER ) / sizeof( GLfloat )

#define END_OF_ATTRIBUTES NULL
#define END_OF_UNIFORMS NULL

//  ... Also it will need to fill out all of the attributes used in the vertex shader, into this structure:
typedef struct {
    GLuint id_;
    char*  token;
    GLuint glFloats;
    GLuint byteOffset;
} ATTRIBUTE;


@interface Vertex : NSObject { }

+ (void) setupVertexArrayPointers: ( ATTRIBUTE [] ) in_attributeArray
               returningVertBufId: (GLuint *)       p_id_vertBuf ;

@end
