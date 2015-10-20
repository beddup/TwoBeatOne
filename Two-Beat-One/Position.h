//
//  Postion.h
//  Two Beat One
//
//  Created by Amay on 5/7/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    PositionDirectionUp,
    PositionDirectionDown,
    PositionDirectionLeft,
    PositionDirectionRight,
} PositionDirection;

@interface Position : NSObject

@property(nonatomic,readonly)NSInteger x;
@property(nonatomic,readonly)NSInteger y;
@property(strong,nonatomic,readonly)NSString *string;


-(instancetype)initWithX:(NSInteger)x Y:(NSInteger )Y;
+(Position *)positionByString:(NSString *)string;
+(Position *)positionByInteger:(NSInteger)positionValue;
-(Position *)reversedPosition;
-(Position *)nearByPosition:(PositionDirection)direction;

-(BOOL)isNearTo:(Position *)p;
-(BOOL)isValid;

@end
