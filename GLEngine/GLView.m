//
//  GLView.m
//  F33rsmEnjinn
//
//  Created by Pi on 14/05/2011.
//  Copyright 2011 Pi. All rights reserved.
//


#import <QuartzCore/QuartzCore.h> // CAEAGLLayer
#import "glHelper.h"

#import "GLView.h"
#import "Program.h"

@interface GLView( )

- (void) drawView:          (CADisplayLink *)   dispLink;
- (BOOL) resizeFromLayer:   (CAEAGLLayer *)     layer;

@property (nonatomic, retain) CADisplayLink*    displayLink;
//@property (nonatomic, retain) Program*          program;

@end




@implementation GLView

@synthesize displayLink;//, program;

+ (id) glView
{
    return [ [ [ GLView alloc ] init ] autorelease ];
}


// You must implement this method
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}


//- (id)initWithCoder:(NSCoder *)aDecoder // Frame:(CGRect)frame
//{
//    self = [super initWithCoder: aDecoder];
//    
//    [self customInit];
//    
//    return self;
//}


- (void) setupContextAndFBOs
{	
    self.multipleTouchEnabled = YES;
    
    LOG( @"GLView: setupContextAndFBOs..." );
    [PiLog indent];
          
    // Setup drawing surface properties
    {
        CAEAGLLayer* eaglLayer = (CAEAGLLayer *) self.layer;
        
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool: FALSE], 
                                        kEAGLDrawablePropertyRetainedBacking, 
                                        kEAGLColorFormatRGBA8, 
                                        kEAGLDrawablePropertyColorFormat, 
                                        nil];
    } 
    
    // create context letting us draw to surface
    {
        context = [ [EAGLContext alloc]  initWithAPI: kEAGLRenderingAPIOpenGLES2 ];
        NSAssert( context != NULL, @"EAGLContext alloc... failed! \n" );
        
        
        BOOL ok = [EAGLContext setCurrentContext: context];
        NSAssert( ok, @"setCurrentContext failed! \n" );
        
        LOG( @"...EAGLContext created!" );
    }
    
    
    // Setup framebuffers
	{	
		// Create default framebuffer object. The backing will be
		// allocated for the current layer in -resizeFromLayer
        glGenFramebuffers( 1, & defaultFramebuffer ); 
		glBindFramebuffer( GL_FRAMEBUFFER, defaultFramebuffer );
		
        glGenRenderbuffers( 1, & colorRenderbuffer ); 
		glBindRenderbuffer( GL_RENDERBUFFER, colorRenderbuffer );
		
        // attach renderBuffer to our frameBuffer
		// NOTE: we could alternatively attach a texture to our FBO with 
		//       glFramebufferTexture2D
		glFramebufferRenderbuffer( GL_FRAMEBUFFER, 
								  GL_COLOR_ATTACHMENT0, 
								  GL_RENDERBUFFER, 
								  colorRenderbuffer );
        
	    glLogAndFlushErrors();
    }
    
    // allocates storage shared between view's backing layer (CAEAGLLayer) and GL's RenderBuffer object
    // retrieves x y size of backing layer
    [self layoutSubviews];
    
    // check everything set up ok
    {
        GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER) ;
        NSAssert( status == GL_FRAMEBUFFER_COMPLETE, @"failed to make complete framebuffer object %x", status);
        LOG( @"...completed @ %d x %d", backingWidth, backingHeight );
    }
    
    [PiLog outdent];
}


//- (void) setupProgramWithShader: ( NSString * )     in_shaderFilename
//                     attributes: ( ATTRIBUTE [] )   in_attributeArray
//                       uniforms: ( char* [] )       in_uniformArray
//{
//    glLogAndFlushErrors();
//    
//    LOG( @"GLView: setupProgramWithShader:attributes:uniforms:" );
//    [PiLog indent];
//
//    self.program = [Program program];
//    
//    [program setupProgramWithShader: in_shaderFilename
//                         attributes: in_attributeArray
//                           uniforms: in_uniformArray ];
//    //[program use];
//    
//    [PiLog outdent];
//}

- (void) startDrawing
{
    LOG( @"GLView: startDrawing..." );
    
    NSAssert( displayLink == NULL, @"ERROR: startDrawing" );
    self.displayLink = [CADisplayLink displayLinkWithTarget: self 
                                                   selector: @selector( drawView: ) ];
    
    [self.displayLink addToRunLoop: [NSRunLoop currentRunLoop] 
                           forMode: NSDefaultRunLoopMode ];
    
}


- (void) drawView: (CADisplayLink*) dispLink
{   
    [self willRender]; // delegate callback
    
    
    // This application only creates a single color renderbuffer 
	//    which is already bound at this point.
    // This call is redundant, but needed if dealing with multiple renderbuffers.
    glBindRenderbuffer( GL_RENDERBUFFER, colorRenderbuffer );
    [context presentRenderbuffer: GL_RENDERBUFFER];
	
	glLogAndFlushErrors();
}



- (void) layoutSubviews
{
    [self resizeFromLayer: (CAEAGLLayer *) self.layer];
    //[self drawView: nil];
}


- (BOOL) resizeFromLayer: (CAEAGLLayer *) layer
{     
    LOG( @"GLView: resizeFromLayer..." );
    
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
	
    // allocate/reallocate color buffer backing based on the current layer size
    [context renderbufferStorage: GL_RENDERBUFFER 
					fromDrawable: layer ];
	
    NSAssert( glCheckFramebufferStatus( GL_FRAMEBUFFER ) == GL_FRAMEBUFFER_COMPLETE, @"Failed to make complete framebuffer object" );
    	
	// get W & H
    glGetRenderbufferParameteriv( GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, & backingWidth );
    glGetRenderbufferParameteriv( GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, & backingHeight );
	
	glViewport( 0, 0, backingWidth, backingHeight );
	
    return YES;
}

//- (GLint) uniformId: (GLuint) index
//{
//    return [program uniformId: index];
//}


// - - - - - - - - - - - - - - - - - 
// PROTOCOL -- OVERRIDE THESE
- (void) willRender { }


@end
