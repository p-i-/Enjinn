//
//  Vertex.h
//  GLEngine
//
//  Created by Pi on 21/05/2011.
//  Copyright 2011 Pi. All rights reserved.
//

/*
 Any class that subclasses GLView will need to implement these callbacks.  It will have to do its own custom setup code, and also just before each frame gets rendered it will need to do its own custom rendering. 
 */ 

#import <OpenGLES/ES2/gl.h>     // GLuint


//@protocol GLViewCallbacks <NSObject>
//- (void) willRender;
//@end

#define END_OF_ATTRIBUTES NULL

//  ... Also it will need to fill out all of the attributes used in the vertex shader, into this structure:
typedef struct {
    GLuint id_;
    char*  token;
    GLuint glFloats;
    GLuint byteOffset;
} ATTRIBUTE;


@interface Vertex : NSObject {
    
}

+ (void) setupVertexArrayPointers: ( ATTRIBUTE [] ) in_attributeArray
               returningVertBufId: (GLuint *)       pIdVertBuf ;

@end
