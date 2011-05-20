//
//  TexImage.h
//  glWheel1
//
//  Created by Pi on 12/03/2011.
//  Copyright 2011 Pi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>             // UIImage

#import <OpenGLES/ES2/gl.h>

@interface GLTexture  : NSObject { }

+ (void) createTestXORGLTextureWidth: (GLuint) W
                              height: (GLuint) H
                      returningTexId: (GLuint*) pTexID ;

+ (void) createGLTextureWidth: (GLuint) W
                       height: (GLuint) H
                   FromAlphas: (uint8_t *) alphas
            intoGLTextureSlot: (GLenum) slotID
               returningTexId: (GLuint*) pTexID ;

///  example usage: 
/// 
/// GLuint texID = [TexFromImage width: 1024 
///                             height: 1024
///                       drawFuncTarg: self
///                        drawFuncSel: @selector(render:) ];
/// 
/// - (void) render: (id) id_X
/// {
///    CGContextRef X = (CGContextRef) id_X;
///    CGSize bitmapSize = CGSizeMake( CGBitmapContextGetWidth( X ), CGBitmapContextGetHeight( X ) );
///
///    :
/// }        
+ (void) genTexOfWidth: (GLuint)    in_W
                height: (GLuint)    in_H
          drawFuncTarg: (id)        targ
           drawFuncSel: (SEL)       sel
                inSlot: (GLenum)    slotNum
        returningTexId: (GLuint*)   pTexID ;


+ (void) createGLTextureFromImage: (UIImage *)  srcImage
                         POTWidth: (GLuint)     dest_W
                        POTHeight: (GLuint)     dest_H
                           inSlot: (GLenum)     slotNum
                   returningTexId: (GLuint*)    pTexID ;


@end
