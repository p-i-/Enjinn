//
//  Indent.h
//  GLEngine
//
//  Created by Pi on 17/05/2011.
//  Copyright 2011 Pi. All rights reserved.
//


@interface Indent : NSObject {
    
}

+(void) inc;
+(void) dec;
+(void) zero;
+(NSString*) margin;
//+(void) print;
+(void) log: (NSString*) S;

@end
