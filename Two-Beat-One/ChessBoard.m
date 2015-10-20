//
//  ChessBoard.m
//  Two Beat One
//
//  Created by Amay on 5/14/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "ChessBoard.h"
#import "TBOGameSetting.h"
@interface ChessBoard()<UIGestureRecognizerDelegate>

@property(strong,nonatomic) NSDictionary * postionMap;
@property(weak,nonatomic)ChessPieceView *chessPieceWhichIsChosen;

@end


@implementation ChessBoard
#pragma  mark - public API

//change UI elements
-(void)reset:(GameMode)gameMode{
    // reset the chessboard based on gameMode
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (gameMode == GameModeStandard) {
        NSArray *startPositions=@[@"14",@"24",@"34",@"44", @"11",@"21",@"31",@"41"];
        for (NSString *positionString in startPositions) {
            BOOL isOpposite=[positionString intValue]%10 == 4 ? YES : NO;
            [self addChessPieceAtPosition:[Position positionByString:positionString] isOpposite:isOpposite];
        }
    }
}

-(void)addChessPieceAtPosition:(Position *)position isOpposite:(BOOL)opposite{

    if ([self chessPieceAtPosition:position]) {
        return;
    }
    ChessPieceView *chessPiece=[[ChessPieceView alloc]initWithSide:opposite];
    chessPiece.position=position;

    // set frame and animate adding
    chessPiece.center=[self mapPosition:position];
    chessPiece.bounds=CGRectMake(0, 0, 5, 5);
    chessPiece.alpha=0.1;
    [self addSubview:chessPiece];
    [UIView animateWithDuration:0.5
                     animations:^{
                         chessPiece.bounds=CGRectMake(0, 0, CGRectGetWidth(self.bounds)/4.5, CGRectGetHeight(self.bounds)/4.5);
                         chessPiece.alpha=1.0;
                     }
     ];

}
-(void)chessPieceAtPosition:(Position *)fromPosition moveToPosition:(Position *)toPosition{

    if (![self chessPieceAtPosition:toPosition]) {
        ChessPieceView *chesspiece=[self chessPieceAtPosition:fromPosition];
        chesspiece.position=toPosition;
        [UIView animateWithDuration:0.5 animations:^{
            chesspiece.center=[self mapPosition:toPosition];
            }];
        }

}
-(void)removeChessPiece:(ChessPieceView *)chessPiece{

    [UIView animateWithDuration:0.5
                          delay:0.4
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         chessPiece.frame=CGRectMake(chessPiece.center.x-1, chessPiece.center.y-1, 2, 2);
                         chessPiece.alpha=0.1;
                     }
                     completion:^(BOOL finished) {
                         [chessPiece removeFromSuperview];}
     ];


}
-(void)positionWasHit:(Position *)position{

    ChessPieceView *chessPiece=[self chessPieceAtPosition:position];
    if (chessPiece) {
        self.chessPieceWhichIsChosen.chosen=NO;
        chessPiece.chosen=YES;
        self.chessPieceWhichIsChosen=chessPiece;
    }
}


//looking for chesspiece
-(ChessPieceView *)chessPieceAtPosition:(Position*)position{
    ChessPieceView *chessPiece=(ChessPieceView *)[self viewWithTag:[position.string integerValue]];
    if ([chessPiece isKindOfClass:[ChessPieceView class]]) {
        return chessPiece;
    }
    return nil;
}

#pragma mark - convert position to location(CGpoint)
-(float) scale{ return CGRectGetWidth(self.frame)/[_postionMap[@"size"][@"width"] floatValue];}

-(CGPoint)mapPosition:(Position *)position{
    return CGPointMake([self.postionMap[position.string][@"x"] floatValue]*[self scale],
                       [self.postionMap[position.string][@"y"] floatValue]*[self scale]);
}
-(NSDictionary *)postionMap{
    if (!_postionMap) {
        NSString *path=[[NSBundle mainBundle]pathForResource:@"PositionMap" ofType:@"plist"];
        _postionMap=[NSDictionary dictionaryWithContentsOfFile:path];
    }
    return _postionMap;
}

#pragma  mark - setup
-(void)awakeFromNib{
    [self setup];
}

-(void)setup{
    self.userInteractionEnabled=YES;
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.tag=105;
}
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;

}



















@end
