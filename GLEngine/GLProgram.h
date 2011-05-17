//
//  GLProgram.h
//  F33rsmEnjinn
//
//  Created by Pi on 05/03/2011.
//  Copyright 2011 Pi. All rights reserved.
//

#import <OpenGLES/ES2/gl.h>

#import "GLViewBits.h"

@interface GLProgram : NSObject
{ 
    GLuint programId;
    GLint* uniformIds;
}

+ (id) program ;

- (void) use ;

- (BOOL) loadShadersCompileAndLink: (NSString*) in_shader
                 bindingAttributes: ( ATTRIBUTE [] ) in_attributeArray ;

- (void) processUniformArray: ( char* [] ) in_uniformArray ;

- (void) bindAttributes: ( ATTRIBUTE [] ) in_attributeArray ;

- (GLint) uniformId: (GLuint) index ;

@end
