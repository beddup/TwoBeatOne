//
//  ChessBoard.h
//  Two Beat One
//
//  Created by Amay on 5/14/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChessPieceView.h"
#import "defines.h"


@interface ChessBoard : UIImageView

// upate UI element
-(void)reset:(GameMode)gameMode;
-(void)addChessPieceAtPosition:(Position *)position isOpposite:(BOOL)opposite;
-(void)chessPieceAtPosition:(Position *)fromPosition moveToPosition:(Position *)toPosition;
-(void)removeChessPiece:(ChessPieceView *)chessPiece;

-(ChessPieceView *)chessPieceAtPosition:(Position*)position;
-(void)positionWasHit:(Position *)position;

@end
