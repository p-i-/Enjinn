//
//  main.m
//  F33rsmEnjinn
//
//  Created by Pi on 16/05/2011.
//  Copyright 2011 Pi. All rights reserved.
//


/*
 * GL ES2 engine by [Pi], inspired by GLYoda (aka Max Rupp)'s web.cecs.pdx.edu/~feelgood/Source/FBO.c
 */

int main( int argc, char *argv[] )
{
    NSLog( @"GL ES2 engine by [Pi], inspired by GLYoda (aka Max Rupp)'s web.cecs.pdx.edu/~feelgood/Source/FBO.c\n\n" );
        
    NSAutoreleasePool *pool = [ [NSAutoreleasePool alloc] init ];
    
    int retVal = UIApplicationMain( argc, argv, nil, nil );
    
    [pool release];
    
    return retVal;
}
