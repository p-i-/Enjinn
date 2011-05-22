//
//  GLProgram.h
//  F33rsmEnjinn
//
//  Created by Pi on 05/03/2011.
//  Copyright 2011 Pi. All rights reserved.
//

#import <OpenGLES/ES2/gl.h>

//#import "GLViewBits.h"
#import "Vertex.h"

@interface Program : NSObject
{ 
    GLuint id_program;
    GLint* uniformIds;
}

- (void) setupProgramWithShader: ( NSString * )     in_shaderFilename
                     attributes: ( ATTRIBUTE [] )   in_attributeArray
                       uniforms: ( char* [] )       in_uniformArray ;


+ (id) program ;

- (void) use ;


- (GLint) uniformId: (GLuint) index ;

@end
