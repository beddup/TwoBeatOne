//
//  TBOHistoryCollectionViewCell.m
//  Two-Beat-One
//
//  Created by Amay on 6/25/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//
#import "defines.h"
#import "Position.h"
#import "TBOHistoryCollectionViewCell.h"

#define History_Opposite NSLocalizedStringFromTable(@"History_Opposite", @"historyVC", @"opposite")
#define History_Time NSLocalizedStringFromTable(@"History_Time", @"historyVC", @"time")
#define History_Delete_Cell NSLocalizedStringFromTable(@"History_Delete_Cell", @"historyVC", @"DELETE CELL")

@interface TBOHistoryCollectionViewCell()

@property(strong,nonatomic)UIImage *markImage;
@property (copy, nonatomic) NSString *oppositeName;
@property (copy, nonatomic) NSString *dateString;
@property(strong,nonatomic) NSArray *allyPositions;
@property(strong,nonatomic) NSArray *enemyPositions;
@property(weak,nonatomic)   UIButton *deleteButton;


@end

@implementation TBOHistoryCollectionViewCell

#pragma mark - properties
-(void)setHistory:(NSDictionary *)history{

    _history=history;
    self.oppositeName=[History_Opposite stringByAppendingString:self.history[@"opposite"]];
    self.dateString=[History_Time stringByAppendingString:
                                 [NSDateFormatter localizedStringFromDate:self.history[@"dateAndTime"]
                                                                dateStyle:NSDateFormatterShortStyle
                                                                timeStyle:NSDateFormatterShortStyle]
                     ];
    self.allyPositions=self.history[@"positionWhenEnd"][@"allies"];
    self.enemyPositions=self.history[@"positionWhenEnd"][@"enemies"];
    self.deleteButton.alpha=0.0;
    [self setNeedsDisplay];

}
-(void)setMarkImage:(UIImage *)markImage{

    _markImage=markImage;
    [self setNeedsDisplay];

}
-(void)setIsChosen:(BOOL)isChosen{

    _isChosen=isChosen;
    self.deleteButton.alpha=0.0; // hide deleteButton to enable user to chosen or unchosen
    self.markImage=[UIImage imageNamed:isChosen ? @"ChosenIcon_Yes" : @"ChosenIcon_No"];

}
-(void)hiddenMarkImage{

    _isChosen=NO;
    self.markImage=nil;

}

#pragma mark -draw
-(void)drawRect:(CGRect)rect{

    // draw bkg image
    UIImage *bkgImage=[UIImage imageNamed:@"bkg_Small"];
    [bkgImage drawInRect:rect];

    // draw boardImage
    UIImage *boardImage=[UIImage imageNamed:@"ChessBoardImage_Small"];
    CGRect boardRect=CGRectInset(rect, CGRectGetWidth(rect)/8, CGRectGetHeight(rect)/8);
    [boardImage drawInRect:boardRect];

    //draw pieces
    [self drawPieces:boardRect];

    //draw oppositeName and dateString Bkg
    UIBezierPath *path=[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, CGRectGetWidth(rect), 40)];
    [[UIColor colorWithRed:1 green:212.0/255 blue:121.0/255 alpha:0.7] setFill];
    [path fill];

    // draw oppositeName
    NSAttributedString *oppositeName=[[NSAttributedString alloc]initWithString:self.oppositeName
                                                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12 weight:UIFontWeightLight],
                                                                        NSForegroundColorAttributeName:[UIColor darkTextColor],
                                                                                 }];
    CGRect oppositeNameRect=CGRectMake(0, 0, CGRectGetWidth(rect), 20);
    [oppositeName drawInRect:oppositeNameRect];

    // draw datestring
    NSAttributedString *dateString=[[NSAttributedString alloc]initWithString:self.dateString
                                                                    attributes:[oppositeName attributesAtIndex:0 effectiveRange:NULL]];
    [dateString drawInRect:CGRectOffset(oppositeNameRect, 0, CGRectGetHeight(oppositeNameRect))];

    // set delete button frame
    self.deleteButton.frame=CGRectMake(0,0, CGRectGetWidth(rect), CGRectGetHeight(oppositeNameRect)*2);

    // draw mark image
    CGRect markImageRect= CGRectMake(CGRectGetWidth(rect)-CGRectGetHeight(oppositeNameRect)*2,0,CGRectGetHeight(oppositeNameRect)*2, CGRectGetHeight(oppositeNameRect)*2);
    [self.markImage drawInRect:markImageRect];



}

-(void)drawPieces:(CGRect)boardFrame{

    [self drawPiecesInRect:boardFrame isOpposite:YES];
    [self drawPiecesInRect:boardFrame isOpposite:NO];
}

-(void)drawPiecesInRect:(CGRect)boardFrame isOpposite:(BOOL)opposite{

    CGFloat gridWith=CGRectGetWidth(boardFrame)/3; //width = height
    CGFloat pieceWidth=CGRectGetWidth(boardFrame)/4.5;//width = height
    for (NSString* positionString in opposite ? self.enemyPositions : self.allyPositions) {
        NSInteger positionX = positionString.integerValue/10;
        NSInteger positionY = positionString.integerValue%10;
        CGPoint center=CGPointMake(CGRectGetMinX(boardFrame)+(positionX-1)*gridWith, CGRectGetMinY(boardFrame)+(4-positionY)*gridWith);
        CGRect  frame=CGRectMake(center.x-pieceWidth/2, center.y-pieceWidth/2, pieceWidth, pieceWidth);
        [[UIImage imageNamed:opposite? @"Piece_Red_Small" : @"Piece_Blue_Small"] drawInRect:frame];
    }

}
#pragma mark - gesture and action
- (void)longPressToDelete:(id)sender {
    if ( ((UIGestureRecognizer *)sender).state==UIGestureRecognizerStateBegan ) {
        if (self.deleteButton.alpha == 0) {
            [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut
                             animations:^{self.deleteButton.alpha=1;}
                             completion:nil];
            return;
        }else{
            [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut
                             animations:^{self.deleteButton.alpha=0;}
                             completion:nil];
        }
    }
}

-(void)deleteSelf:(UIButton *)sender{

    [self.delegate deleteHistory:self.history];
}

#pragma mark - set up
-(void)awakeFromNib{
    [self setup];
}
-(void)setup{
    self.backgroundColor=[UIColor clearColor];
    // add gesture
    UILongPressGestureRecognizer *longPress=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressToDelete:)];
    [self addGestureRecognizer:longPress];

    // add deleteButton
    UIButton *button=[[UIButton alloc]init];
    [button setBackgroundColor:[UIColor colorWithRed:1 green:212.0/255 blue:121.0/255 alpha:1]];
    [button setAttributedTitle:[[NSAttributedString alloc]initWithString:History_Delete_Cell
                                                              attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18 weight:UIFontWeightLight],
                                                                           NSForegroundColorAttributeName:[UIColor redColor]}]
                      forState:UIControlStateNormal];
    [button addTarget:self action:@selector(deleteSelf:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    self.deleteButton=button;
    self.deleteButton.alpha=0;

}
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

@end