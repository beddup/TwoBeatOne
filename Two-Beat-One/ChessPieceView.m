//
//  ChessPiece.m
//  Two Beat One
//
//  Created by Amay on 5/14/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "ChessPieceView.h"
#import "ChessBoard.h"
@interface ChessPieceView()

@end

@implementation ChessPieceView

-(instancetype)initWithSide:(BOOL)isOpposite{
    self=[super init];
    if (self) {
        _opposite=isOpposite;
        self.image=[UIImage  imageNamed:isOpposite ? @"Piece_Red" : @"Piece_Blue"];
        [self sizeToFit];
        _chosen=NO;
    }
    return self;
}

-(void)setPosition:(Position *)position
{
    _position=position;
    self.tag=[position.string integerValue];
}

-(void)setChosen:(BOOL)chosen{
    
    _chosen=chosen;
    if(self.isChosen){
        self.image=[UIImage imageNamed:self.isOpposite ? @"Piece_Red_Chosen":@"Piece_Blue_Chosen"];
    }
    else{
        self.image=[UIImage imageNamed:self.isOpposite ? @"Piece_Red":@"Piece_Blue"];

    }
}

@end
