//
//  NSObject+Parse.m
//  Parser
//
//  Created by huanchi on 16/3/4.
//  Copyright © 2016年 上海欢炽网络科技有限公司. All rights reserved.
//

#import "NSObject+Parse.h"
#import <objc/runtime.h>

@implementation NSObject (Parse)

-(NSArray *)properties{
    return [self propertyOfClass:self.class];
}


+(NSDictionary *)keyValueProperty{
    unsigned int outCount = 0;
    NSMutableDictionary *dict = [NSMutableDictionary new];
    objc_property_t *properties = class_copyPropertyList(self.class, &outCount);
    for (const objc_property_t *p=properties; p < properties+outCount; p++) {
        objc_property_t property_t = *p;
        const char *p_t = property_getName(property_t);
        const char *clss_t = property_getAttributes(property_t);
        NSString *property = [NSString stringWithUTF8String:p_t];
        NSString *property_att = [NSString stringWithUTF8String:clss_t];
        if ([property_att rangeOfString:@"\","].location == NSNotFound) {
            [dict setObject:@"" forKey:property];
        }else{
            NSString *className = [property_att substringWithRange:NSMakeRange(3, [property_att rangeOfString:@"\","].location-3)];
            [dict setObject:className forKey:property];
        }
    }
    free(properties);
    return dict;

}

-(NSArray *)propertyOfClass:(Class)clss{
    unsigned int outCount = 0;
    objc_property_t *properties = class_copyPropertyList(clss, &outCount);
    NSMutableArray *list = [[NSMutableArray alloc]init];
    for (const objc_property_t *p=properties; p < properties+outCount; p++) {
        objc_property_t property = *p;
        const char *name = property_getName(property);
        [list addObject:[NSString stringWithUTF8String:name]];
    }
    free(properties);
    return list;
}

-(NSMutableDictionary *)toDictionary{
    if ([self isKindOfClass:[NSArray class]]) {
        return nil;
    }
    NSArray *properties = [self properties];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    for (id property in properties) {
        if (![[self valueForKey:property]conformsToProtocol:@protocol(NSCopying)]) {
            [dict setObject:[[self valueForKey:property] toDictionary] forKey:property];
        }else{
            [dict setObject:[self valueForKey:property] forKey:property];
        }
    }
    return dict;
}


-(id)initWithDictionary:(NSDictionary *)dictionary{
    self = [self init];
    if (self) {
        NSDictionary *keyValues = [self.class keyValueProperty];
        for (NSString *key in keyValues.allKeys) {
            NSString *className = [keyValues objectForKey:key];
            if ([className isEqualToString:@""]) {
                [self setValue:[dictionary objectForKey:key] forKey:key];
            }else if([NSClassFromString(className) conformsToProtocol:@protocol(NSCopying)]){
                [self setValue:[dictionary objectForKey:key] forKey:key];
            }else{
                [self setValue:[[dictionary objectForKey:key] parserWithClass:NSClassFromString(className)] forKey:key];
            }
        }
    }
    return self;
}

-(id)parserWithClass:(Class)clss{
    if (clss == nil) {
        return self;
    }
    if ([self isKindOfClass:[NSString class]]) {
        NSData *data = [(NSString *)self dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (error) {
            return error;
        }
        [dict parserWithClass:clss];
    }
    if ([self isKindOfClass:[NSDictionary class]]) {
        return [[clss alloc]initWithDictionary:(NSDictionary *)self];
    }
    if ([self isKindOfClass:[NSArray class]]) {
        NSMutableArray *parserData = [[NSMutableArray alloc]initWithCapacity:[(NSArray *)self count]];
        for (NSDictionary *dic in (NSArray *)self) {
            [parserData addObject:[dic parserWithClass:clss]];
        }
        return parserData;
    }
    return self;
}

@end


