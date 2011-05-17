//
//  ShaderAux.h
//  F33rsmEnjinn
//
//  Created by Pi on 16/05/2011.
//  Copyright 2011 Pi. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenGLES/ES2/gl.h>

@interface ShaderAux : NSObject {
    
}

+ (BOOL) compileShaderOfType: (GLenum) type
                    filename: (NSString *) file 
           returningShaderId: (GLuint *) shaderId ;

+ (BOOL)linkProgram: (GLuint) prog;

+ (BOOL)validateProgram: (GLuint) prog;

@end
