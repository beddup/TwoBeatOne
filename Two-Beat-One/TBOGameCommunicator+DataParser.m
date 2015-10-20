//
//  TBOGameCommunicator+DataParser.m
//  Two Beat One
//
//  Created by Amay on 5/30/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "TBOGameCommunicator+DataParser.h"

@implementation TBOGameCommunicator (DataParser)
-(NSDictionary *)dictionaryByData:(NSData *)data{
    if (data) {
        
        NSDictionary *dictionary=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        return dictionary;
    }
    return nil;
    
}
-(NSData *)dataByDictionary:(NSDictionary *)dictionary{
    
    return [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
}

@end
