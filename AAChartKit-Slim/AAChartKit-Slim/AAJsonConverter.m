//
//  AAJsonConverter.m
//  AAChartKit-SlimDemo
//
//  Created by An An on 2017/11/8.
//  Copyright © 2017年 Danny boy. All rights reserved.
//

#import "AAJsonConverter.h"
#import <objc/runtime.h>
@implementation AAJsonConverter

+ (NSString *)getPureOptionsString:(id)optionsObject {
    
//    NSArray *modelArr = @[optionsObject];
//  建议参考 jsonKit 实现方式
//    //2、判断是否能转为Json数据
//    /*如果给定对象可以转换为JSON数据，则返回YES。该对象必须具有以下属性:
//     顶级对象是NSArray或NSDictionary
//     所有对象都是NSString，NSNumber NSArray NSDictionary，NSNull
//     所有的字典键都是nsstring
//     NSNumber不是NaN或无穷大
//     其他规则可能适用。调用该方法或尝试转换是确定给定对象是否可以转换为JSON数据的确定方法。
//     * /
//     */
//    BOOL isValidJSONObject =  [NSJSONSerialization isValidJSONObject:modelArr];
//    if (isValidJSONObject) {
//        NSData *data =  [NSJSONSerialization dataWithJSONObject:optionsObject options:NSJSONWritingPrettyPrinted error:nil];
//        NSString *jsonString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//        return jsonString;
//    }
//    return nil;
    NSDictionary *dic = [self getObjectData:optionsObject];
    NSString *str = [self convertDictionaryIntoJson:dic];
    return [self wipeOffTheLineBreakAndBlankCharacter:str];
 }

+ (NSDictionary*)getObjectData:(id)obj {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int propsCount;
    Class class = [obj class];
    do {
        objc_property_t *props = class_copyPropertyList(class, &propsCount);
        for (int i = 0;i < propsCount; i++) {
            objc_property_t prop = props[i];
            
            NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
            id value = [obj valueForKey:propName];
            if (value == nil) {
                value = [NSNull null];
                continue;
            } else {
                value = [self getObjectInternal:value];
            }
            [dic setObject:value forKey:propName];
        }
        class = [class superclass];
    } while (class != [NSObject class]);
    
    return dic;
}

+ (NSData*)getJSON:(id)obj options:(NSJSONWritingOptions)options error:(NSError**)error {
    return [NSJSONSerialization dataWithJSONObject:[self getObjectData:obj] options:options error:error];
}

+ (id)getObjectInternal:(id)obj {
    if (   [obj isKindOfClass:[NSString class]]
        || [obj isKindOfClass:[NSNumber class]]
        || [obj isKindOfClass:[NSNull   class]] ) {
        return obj;
    }
    
    if ([obj isKindOfClass:[NSArray class]]) {
        NSArray *objarr = obj;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
        for (int i = 0;i < objarr.count; i++) {
            [arr setObject:[self getObjectInternal:[objarr objectAtIndex:i]] atIndexedSubscript:i];
        }
        return arr;
    }
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *objdic = obj;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
        for (NSString *key in objdic.allKeys) {
            [dic setObject:[self getObjectInternal:[objdic objectForKey:key]] forKey:key];
        }
        return dic;
    }
    return [self getObjectData:obj];
}

+ (NSString*)convertDictionaryIntoJson:(NSDictionary *)dictionary {
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *string =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return string;
}

+ (NSString*)wipeOffTheLineBreakAndBlankCharacter:(NSString *)originalString {
    NSString *str =[originalString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return str;
}



@end
