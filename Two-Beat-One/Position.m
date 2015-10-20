//
//  Postion.m
//  Two Beat One
//
//  Created by Amay on 5/7/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "Position.h"

@implementation Position


-(instancetype)initWithX:(NSInteger)x Y:(NSInteger)y{
    if (x<1 || x>4 || y<1 || y>4 ) {
        return nil;
    }
    self=[super init];
    if (self) {
        _x=x;
        _y=y;
    }
    return self;
}

// creat a position based on a string
+(Position *)positionByString:(NSString *)string{

    NSInteger x=[string intValue]/10;
    NSInteger y=[string intValue]%10;
    if (x<1 || x>4 || y<1 || y>4 ) {
        return nil;
    }
    return [[Position alloc]initWithX:x Y:y];
}

// creat a position based on integer
+(Position *)positionByInteger:(NSInteger)positionValue{
    NSInteger x=positionValue/10;
    NSInteger y=positionValue%10;
    if (x<1 || x>4 || y<1 || y>4 ) {
        return nil;
    }
    return  [[Position alloc]initWithX:positionValue/10 Y:positionValue%10];
}

// mirror position on chessboard
-(Position *)reversedPosition{
    return [Position positionByInteger:55-[self.string integerValue]];
}

-(Position *)nearByPosition:(PositionDirection)direction{
    switch (direction) {
        case PositionDirectionDown:
            return [Position positionByInteger:self.string.integerValue-1];
        case PositionDirectionLeft:
            return [Position positionByInteger:self.string.integerValue-10];
        case PositionDirectionRight:
            return [Position positionByInteger:self.string.integerValue+10];
        case PositionDirectionUp:
            return [Position positionByInteger:self.string.integerValue+1];
    }
}

-(NSString *)string{
    return [NSString stringWithFormat:@"%ld%ld",(long)self.x,(long)self.y];
}

// isvalid on chessboard
-(BOOL)isValid{
    if (self.x>=1 && self.x<=4 &&
        self.y>=1 && self.y<=4) {
        return YES;
    }
    return NO;
}

-(BOOL)isNearTo:(Position *)p{

    NSInteger delta= self.x+self.y-p.x-p.y;
    if (delta == 1 || delta == -1) {
        return YES;
    }
    return NO;
}

-(BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[Position class]] &&
        ((Position *)object).x == self.x &&
        ((Position *)object).y == self.y) {
        return YES;
    }
    return NO;
}

@end
