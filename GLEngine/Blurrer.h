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

//+ (void)  blurTexture: (GLuint)     in_texId
//             POTWidth: (GLuint)     in_W
//            POTHeight: (GLuint)     in_H
//              srcSlot: (GLuint)     srcSlot
//             destSlot: (GLuint)     destSlot
//       returningTexId: (GLuint*)    out_pTexId ;

+ (void)  createTextureByBlurringTexture: (GLuint)     in_id_tex
                                 POTSize: (GLSize)     in_POTSize
                          returningTexId: (GLuint *)   out_p_id_tex ;


@end
