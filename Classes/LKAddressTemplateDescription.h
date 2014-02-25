//
//  LKAddressTemplateDescription.h
//  LKLocationManager
//
//  Created by Hiroshi Hashiguchi on 2014/02/25.
//  Copyright (c) 2014年 lakesoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LKAddressTemplateDescription : NSObject

@property (strong, nonatomic) NSString* title;      // e.g.) "Week"
@property (strong, nonatomic) NSString* keyword;   // e.g.) "%city"

@end
