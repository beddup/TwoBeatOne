//
//  TBOGameCommunicator+DataParser.h
//  Two Beat One
//
//  Created by Amay on 5/30/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "TBOGameCommunicator.h"

@interface TBOGameCommunicator (DataParser)

-(NSDictionary *)dictionaryByData:(NSData *)data;
-(NSData *)dataByDictionary:(NSDictionary *)dictionary;

@end
