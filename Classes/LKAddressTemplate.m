//
//  LKAddressTemplate.m
//  LKLocationManager
//
//  Created by Hiroshi Hashiguchi on 2014/02/25.
//  Copyright (c) 2014年 lakesoft. All rights reserved.
//

#import "LKAddressTemplate.h"
#import "LKLocationManagerBundle.h"
#import "LKAddressTemplateDescription.h"

#define LK_ADDRESS_TEMPLATE_KEYWORD(key)    ([@"%addr." stringByAppendingString:key])
#define LK_ADDRESS_TEMPLATE_DESCKEY(key)    ([@"desc." stringByAppendingString:key])

@implementation LKAddressTemplate

#pragma mark - Privates

+ (NSArray*)_keys
{
    static NSArray* _keys = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray* keys = [NSArray arrayWithContentsOfFile:[LKLocationManagerBundle.bundle
                                                      pathForResource:NSStringFromClass(self) ofType:@"plist"]];
        _keys = [keys sortedArrayUsingComparator:^NSComparisonResult(NSString* obj1, NSString* obj2) {
            return [obj1 compare:obj2];
        }];
    });
    return _keys;
}


#pragma mark - API
+ (NSString*)convertWithTemplate:(NSString*)template addressDictionary:(NSDictionary*)addressDictionary
{
    return [self convertWithTemplate:template addressDictionary:addressDictionary locale:nil];
}

+ (NSString*)convertWithTemplate:(NSString*)template addressDictionary:(NSDictionary*)addressDictionary locale:(NSLocale*)locale
{
    NSString* result = template;

    NSArray* keys = [self._keys sortedArrayUsingComparator:^NSComparisonResult(NSString* obj1, NSString* obj2) {
        return [obj2 compare:obj1]; // reverse
    }];

    for (NSString* key in keys) {
        NSString* keyword = LK_ADDRESS_TEMPLATE_KEYWORD(key);
        NSString* string = addressDictionary[key];
        string = string ? string : @"";
        result = [result stringByReplacingOccurrencesOfString:keyword withString:string];
    }
    return result;
}

+ (NSInteger)numberOfKeywords
{
    return self._keys.count;
}

+ (LKAddressTemplateDescription*)descriptionAtIndex:(NSInteger)index
{
    LKAddressTemplateDescription* desc = LKAddressTemplateDescription.new;
    NSString* key = self._keys[index];
    desc.title = NSLocalizedStringFromTableInBundle(LK_ADDRESS_TEMPLATE_DESCKEY(key),
                                                    nil,
                                                    LKLocationManagerBundle.bundle,
                                                    nil);
    
    desc.keyword = LK_ADDRESS_TEMPLATE_KEYWORD(key);
    return desc;
}


@end
