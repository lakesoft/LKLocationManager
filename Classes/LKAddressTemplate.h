//
//  LKAddressTemplate.h
//  LKLocationManager
//
//  Created by Hiroshi Hashiguchi on 2014/02/25.
//  Copyright (c) 2014年 lakesoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LKAddressTemplateDescription;
@interface LKAddressTemplate : NSObject

#pragma mark - Files
// LKAddressTemplate.plist    ... Keyword list
// Localized.strings          ... Keyword title (localized)

#pragma mark - Converter
+ (NSString*)convertWithTemplate:(NSString*)template addressDictionary:(NSDictionary*)addressDictionary;
+ (NSString*)convertWithTemplate:(NSString*)template addressDictionary:(NSDictionary*)addressDictionary locale:(NSLocale*)locale;

#pragma mark - Keyword list
+ (NSInteger)numberOfKeywords;
+ (LKAddressTemplateDescription*)descriptionAtIndex:(NSInteger)index;

@end
