//
//  TBOHistoryPlayer.h
//  Two Beat One
//
//  Created by Amay on 5/16/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChessBoard.h"


@interface TBOHistoryPlayer : NSObject

@property(strong,nonatomic)NSDictionary *history;
@property(weak,nonatomic)ChessBoard *chessBoard;

-(void)nextStep;
-(void)previousStep;

@end
