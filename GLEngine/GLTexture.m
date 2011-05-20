//
//  TexImage.m
//  glWheel1
//
//  Created by Pi on 12/03/2011.
//  Copyright 2011 Pi. All rights reserved.
//

#import "GLTexture.h"

#import "glHelper.h"

// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 

@interface GLTexture ( )



+ (void) AlphaMapFromUIImage: (UIImage *) srcImage
                    intoData: (uint8_t *) destAlphas 
                       width: (size_t) dest_W
                      height: (size_t) dest_H
                     stretch: (BOOL) stretchToFit
                  keepAspect: (BOOL) keepAspect ;

@end

// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = 

@implementation GLTexture 

+ (void) createTestXORGLTextureWidth: (GLuint) W
                              height: (GLuint) H
                      returningTexId: (GLuint*) pTexID 
{
    //    XOR_TEST_TEXTURE
    GLuint pixCount = W * H;
    
    uint8_t * alphas = calloc( pixCount, sizeof( uint8_t) );
    
    int pix=0;
    for (int x = 0; x < W; x++)
        for (int y = 0; y < H; y++)
            alphas[ pix++ ] = x ^ y;
    
    [GLTexture createGLTextureWidth: W
                             height: H
                         FromAlphas: alphas
                  intoGLTextureSlot: GL_TEXTURE0
                     returningTexId: pTexID ] ;
    
    free( alphas );
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

+ (void) genTexOfWidth: (GLuint)    in_W
                height: (GLuint)    in_H
          drawFuncTarg: (id)        targ
           drawFuncSel: (SEL)       sel
                inSlot: (GLenum)    in_slotNum
        returningTexId: (GLuint*)   pTexID
{    
    GLubyte * imageData;
    CGContextRef X;
    {
        GLuint bytesPerPixel = 1; // ALPHA ONLY
        GLuint bytesPerRow = bytesPerPixel * in_W;
        GLuint byteCount = bytesPerRow * in_H;
        
        // Allocate memory needed for the bitmap context
        imageData = (GLubyte *) calloc( byteCount, sizeof(GLubyte) );
        
        // Create a 'Context' that lets us draw onto this memory-chunk
        //
        // (1) coord (0, H-1) will occupy first 4 bytes of m_imageData (TESTED MYSELF)
        // ie we have normal sane CARTESIAN SYSTEM with ORIGIN (0,0) BOTTOM LEFT
        // with the TOP ROW coming out FIRST 
        //			so eg (0,0) will be BOTTOM LEFT, 
        //				(and (0,0).alpha will be at 4*(H-1)*W + 3 (assuming 4-byte RGBA))
        X = CGBitmapContextCreate(imageData, 
                                  in_W, in_H, 
                                  8,                     // bitsPerComponent
                                  bytesPerRow, 
                                  NULL,                  // colorSpace
                                  kCGImageAlphaOnly);
        
        // (2) http://iphone-3d-programming.labs.oreilly.com/ch05.html#fig-TexelMapping
        // ...the spec also says that, when uploading an image with glTexImage2D, 
        // it should be arranged in memory such that the FIRST row of data 
        // corresponds to the BOTTOM ROW in the image, 
        //
        // but by (1), the FIRST row of data is (x, H-1), aka the TOP ROW of the image.
        //			∴ we need to FLIP our image WHEN WE CREATE IT!
        //			ie we need to draw everything upside down
        CGContextTranslateCTM( X, 0, in_H );	// bring origin from BL to TL
        CGContextScaleCTM( X, 1, -1 );	// flip
    }
    
    // custom-draw something onto image context
    // Drawing to CGContext:
    // (3) http://developer.apple.com/library/mac/documentation/graphicsimaging/Conceptual/drawingwithquartz2d/dq_overview/dq_overview.html#//apple_ref/doc/uid/TP30001066-CH202-CJBBAEEC
    // So (0,0) will draw to bottom left
    [targ performSelector: sel 
               withObject: (id) X ];
    
    // create GL-texture from context's backing bitmap-store
    [GLTexture createGLTextureWidth: in_W
                             height: in_H
                         FromAlphas: imageData
                  intoGLTextureSlot: in_slotNum
                     returningTexId: pTexID ];
    
    // release context & free bitmap-store
    CGContextRelease( X ); 
    free( imageData );
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

#define isPOT(x) (((x) > 0) && (((x) & ((x) - 1)) == 0))

+ (void) createGLTextureFromImage: (UIImage *) srcImage
                         POTWidth: (GLuint) dest_W
                        POTHeight: (GLuint) dest_H
                           inSlot: (GLenum) slotNum
                   returningTexId: (GLuint*) pTexID
{
    bool ok = isPOT(dest_W) && isPOT(dest_H);
    if (! ok)
    {
        NSLog(@"ERROR: NPOT!");
        return;
    }
    
    GLuint pixCount = dest_W * dest_H;
    
    uint8_t * alphas = calloc(pixCount, sizeof( uint8_t) );
    
    [GLTexture AlphaMapFromUIImage: srcImage
                          intoData: alphas
                             width: dest_W
                            height: dest_H
                           stretch: YES
                        keepAspect: YES ];
    
    [GLTexture createGLTextureWidth: dest_W
                             height: dest_H
                         FromAlphas: alphas
                  intoGLTextureSlot: slotNum
                     returningTexId: pTexID ];
    
    free( alphas );
}

// = = = = = = = = = = = =  I N T E R N A L  = = = = = = = = = = = =

+ (void) AlphaMapFromUIImage: (UIImage *) srcImage
                    intoData: (uint8_t *) destAlphas 
                       width: (size_t) dest_W
                      height: (size_t) dest_H
                     stretch: (BOOL) stretchToFit
                  keepAspect: (BOOL) keepAspect
{
    CGRect makeTargetRect( CGSize srcSize, CGSize destSize, BOOL stretchToFit, BOOL keepAspect);
    
    // - - - 
    
    size_t pixelCount = dest_W * dest_H;
    
    typedef struct {
        uint8_t r,g,b,a;
    } RGBA;
    
    // backing bitmap store
    RGBA* pixels = calloc( pixelCount, sizeof( RGBA ) );
    
    // create context using above store
    CGContextRef X_RGBA;
    {
        size_t bitsPerComponent = 8;
        size_t bytesPerRow = dest_W * sizeof( RGBA );
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        
        // create a context with RGBA pixels
        X_RGBA = CGBitmapContextCreate( (void *)pixels, dest_W, dest_H, 
                                       bitsPerComponent, bytesPerRow, 
                                       colorSpace, kCGImageAlphaNoneSkipLast
                                       );        
        assert(X_RGBA);
        
        CGColorSpaceRelease(colorSpace);
    }
    
    // FLIP coord system
    {
        // image will get drawn upside down.
        // Need to flip coord system, so image comes right way up
        CGContextTranslateCTM( X_RGBA, 0, dest_H );     // bring origin from BL to TL
        CGContextScaleCTM( X_RGBA, 1, -1 );             // flip
    }
    
    // Draw image onto context
    {
        CGSize srcSize = srcImage.size;
        CGSize destSize = CGSizeMake( dest_W, dest_H );
        
        CGRect targetRect = makeTargetRect( srcSize, destSize, stretchToFit, keepAspect );
        
        CGImageRef img = [srcImage CGImage];
        CGContextDrawImage( X_RGBA, targetRect, img );
    }
    
    // extract 1-byte greyscale per pixel
    for(int y = 0; y < dest_H; y++) 
    {
        for(int x = 0; x < dest_W; x++) 
        {
            int N = y * dest_W + x;
            
            RGBA pix = pixels[ N ];
            
            // convert to grayscale using recommended method: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            destAlphas[ N ] = .3 * pix.r + .59 * pix.g + .11 * pix.b;
        }
    }
    
    // clean up
    CGContextRelease(X_RGBA); 
    free( pixels );
}    

// - - - 

CGRect makeTargetRect( CGSize srcSize, CGSize destSize, BOOL stretchToFit, BOOL keepAspect)
{
    // draw source-image onto drawing surface, stretching if necessary
    // this will fill dest alphas array properly
    CGRect targetRect;
    {
        int src_W = srcSize.width;
        int src_H = srcSize.height;
        
        int dest_W = destSize.width;
        int dest_H = destSize.height;
        
        CGSize targetSize;
        {
            if (! stretchToFit)
            {
                targetSize = CGSizeMake(src_W, src_H);
            }
            else
            {
                if (! keepAspect)
                {
                    targetSize = CGSizeMake(dest_W, dest_H);
                }
                else
                {
                    float ratio_X = src_W / (float) dest_W;
                    float ratio_Y = src_H / (float) dest_H;
                    
                    float bigger = MAX (ratio_X, ratio_Y);
                    
                    targetSize = CGSizeMake(src_W / bigger, src_H / bigger);
                }
            }
        }
        
        CGSize halfSize = CGSizeMake( targetSize.width / 2., 
                                     targetSize.height / 2. );
        
        CGPoint targetOrigin = CGPointMake( dest_W / 2. - halfSize.width, 
                                           dest_H / 2. - halfSize.height );
        
        targetRect = (CGRect) { .origin = targetOrigin, .size = targetSize };
    }    
    
    return targetRect;
};

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

+ (void) createGLTextureWidth: (GLuint) W
                       height: (GLuint) H
                   FromAlphas: (uint8_t *) alphas
            intoGLTextureSlot: (GLenum) slotID
               returningTexId: (GLuint*) pTexID
{
    NSAssert ( isPOT( W ) && isPOT( H ), @"ERROR: GL Textures on iOS MUST be power of two!" );
    
    glActiveTexture( slotID );
    
    // Ask GL to give us a texture-ID for us to use
    glGenTextures( 1, pTexID );
    
    glBindTexture( GL_TEXTURE_2D, *pTexID );
    
    // set some params on the ACTIVE texture
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    
    // WRITE/COPY from P into active texture  
    glTexImage2D( GL_TEXTURE_2D, 0, GL_ALPHA, W, H, 
                 0, GL_ALPHA, GL_UNSIGNED_BYTE, (void *) alphas );
    
    glGenerateMipmap(GL_TEXTURE_2D);
    
    glLogAndFlushErrors();
}

@end