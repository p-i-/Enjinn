//
//  Blurrer.h
//  GLEngine
//
//  Created by Pi on 20/05/2011.
//  Copyright 2011 Pi. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>


@interface Blurrer : NSObject {
    
}

+ (void)  blurTexture: (GLuint)     in_texId
             POTWidth: (GLuint)     in_W
            POTHeight: (GLuint)     in_H
       returningTexId: (GLuint*)    out_pTexId ;

@end
