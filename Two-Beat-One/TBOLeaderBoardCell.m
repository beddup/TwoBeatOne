//
//  TBOLeaderBoardCell.m
//  Two Beat One
//
//  Created by Amay on 5/26/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//
#import "defines.h"
#import "TBOLeaderBoardCell.h"


@implementation TBOLeaderBoardCell

#pragma mark - properties
-(void)setRank:(NSUInteger)rank{
    _rank=rank;
    [self setNeedsDisplay];
}
-(void)setPlayerPhoto:(UIImage *)playerPhoto{
    _playerPhoto=playerPhoto;
    [self setNeedsDisplay];

}
-(void)setPlayerName:(NSString *)playerName{
    _playerName=playerName;
    [self setNeedsDisplay];
}

-(void)setFormattedperformance:(NSString *)formattedperformance{
    _formattedperformance=formattedperformance;
    [self setNeedsDisplay];
}
-(void)setPerformance:(NSString *)performance{
    _performance=performance;
    [self setNeedsDisplay];
}
#pragma mark -draw
-(void)drawRect:(CGRect)rect{
    
    CGFloat distanceBetweenElements=15.0;
    CGFloat distanceFromEdge=10.0;
    UIColor *textColor=[UIColor colorWithRed:1 green:1 blue:214.0/255 alpha:1];

    // draw rank
    NSAttributedString *rankString=[[NSAttributedString alloc]initWithString:@(self.rank).stringValue
                                                                  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:24 weight:UIFontWeightLight], NSForegroundColorAttributeName:textColor}];
    
    CGSize rankStringSize=rankString.size;
    CGRect rankRect=CGRectMake(distanceFromEdge, (CGRectGetHeight(rect)-rankStringSize.height)/2, rankStringSize.width, rankStringSize.height);
    [rankString drawInRect:rankRect];
    
    // draw performance
    NSAttributedString *performanceString=[[NSAttributedString alloc]initWithString:self.performance
                                                                         attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:24], NSForegroundColorAttributeName:textColor}];
    CGSize performanceSize=performanceString.size;
    CGRect performanceRect=CGRectMake(CGRectGetWidth(rect)-distanceFromEdge-performanceSize.width, (CGRectGetHeight(rect)-performanceSize.height)/2, performanceSize.width, performanceSize.height);
    [performanceString drawInRect:performanceRect];
    
    // draw performance formate
    NSAttributedString *pformateString=[[NSAttributedString alloc]initWithString:self.formattedperformance
                                                                      attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10 weight:UIFontWeightLight], NSForegroundColorAttributeName:textColor}];
    CGSize pformateSize=pformateString.size;
    CGRect pfRect=CGRectMake(CGRectGetWidth(rect)-distanceFromEdge-pformateSize.width,
                             CGRectGetMaxY(performanceRect), pformateSize.width, pformateSize.height);
    [pformateString drawInRect:pfRect];

    
    //draw photo
    CGRect photoRect=CGRectMake(CGRectGetMaxX(rankRect)+distanceBetweenElements, CGRectGetHeight(rect)/6, CGRectGetHeight(rect)*2/3,CGRectGetHeight(rect)*2/3 );
    UIBezierPath *circleBorder=[UIBezierPath bezierPathWithOvalInRect:photoRect];
    [[UIColor colorWithRed:1 green:1 blue:214.0/255 alpha:1] setStroke];
    [circleBorder stroke];
    
    //draw name
    NSMutableAttributedString *nameAString=[[NSMutableAttributedString alloc]initWithString:self.playerName
                                                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16 weight:UIFontWeightLight], NSForegroundColorAttributeName:textColor}];
    CGSize nameStringSize=nameAString.size;
    CGFloat maxWidth=CGRectGetWidth(rect)-CGRectGetMaxX(photoRect)-CGRectGetWidth(performanceRect)-2*distanceBetweenElements-distanceFromEdge;
    // trim name to fit the space
    if (maxWidth < nameStringSize.width) {
        NSAttributedString *dotstring=[[NSAttributedString alloc]initWithString:@"..." attributes:[nameAString attributesAtIndex:0 effectiveRange:NULL]];
        [nameAString appendAttributedString:dotstring];
        
        while (maxWidth < nameAString.size.width) {
            [nameAString replaceCharactersInRange:NSMakeRange(nameAString.length-5, 5) withAttributedString:dotstring];
        }
        nameStringSize=nameAString.size;
    }
    CGRect nameRect=CGRectMake(CGRectGetMaxX(photoRect)+distanceBetweenElements, (CGRectGetHeight(rect)-nameStringSize.height)/2, nameStringSize.width > maxWidth ? maxWidth : nameStringSize.width, nameStringSize.height);
    [nameAString drawInRect:nameRect];
    
    [circleBorder addClip];
    // draw photo
    [self.playerPhoto drawInRect:photoRect];
}
#pragma mark - setup
-(void)setup{

    self.backgroundColor=[UIColor clearColor];

}
- (void)awakeFromNib {
    
    [self setup];

}
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

@end
