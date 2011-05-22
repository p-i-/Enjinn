//
//  GLView.h
//  F33rsmEnjinn
//
//  Created by Pi on 14/05/2011.
//  Copyright 2011 Pi. All rights reserved.
//

#import "GLViewBits.h" // renderProtocol, ATTRIBUTE
#import "Vertex.h"

@class Program;
@class EAGLContext;

@interface GLView : UIView <GLViewCallbacks> 
{
@private
    EAGLContext *context;
    GLuint defaultFramebuffer, colorRenderbuffer;    
    
@protected
    GLint backingWidth, backingHeight;

}

+ (id) glView;

- (void) setupContextAndFBOs;

//- (void) setupProgramWithShader: ( NSString * )     in_shaderFilename
//                     attributes: ( ATTRIBUTE [] )   in_attributeArray
//                       uniforms: ( char* [] )       in_uniformArray ;

//- (void) setupVertexArrayPointers: ( ATTRIBUTE [] ) in_attributeArray ;

- (void) startDrawing;

//- (GLint) uniformId: (GLuint) index;


@end
