//
//  Indent.h
//  GLEngine
//
//  Created by Pi on 17/05/2011.
//  Copyright 2011 Pi. All rights reserved.
//

#define LOG( ... )  [ PiLog log:  \
                        [ NSString stringWithFormat: __VA_ARGS__ ]  \
                    ]

@interface PiLog : NSObject { }

+(void) indent;
+(void) outdent;
+(void) zero;

+(NSString*) margin;

+(void) log: (NSString*) S;

@end
