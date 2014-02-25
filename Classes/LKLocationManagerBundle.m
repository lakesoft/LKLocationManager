//
//  LKLocationManagerBundle.m
//  LKLocationManager
//
//  Created by Hiroshi Hashiguchi on 2014/02/25.
//  Copyright (c) 2014年 lakesoft. All rights reserved.
//

#import "LKLocationManagerBundle.h"

@implementation LKLocationManagerBundle

+ (NSBundle*)bundle
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"LKLocationManager-Resources" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    return bundle;
}

@end
