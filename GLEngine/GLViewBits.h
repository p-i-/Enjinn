//
//  GLViewBits.h
//  F33rsmEnjinn
//
//  Created by Pi on 15/05/2011.
//  Copyright 2011 Pi. All rights reserved.
//

/*
 Any class that subclasses GLView will need to implement these callbacks.  It will have to do its own custom setup code, and also just before each frame gets rendered it will need to do its own custom rendering. 
 */ 

@protocol GLViewCallbacks <NSObject>
- (void) willRender;
@end
