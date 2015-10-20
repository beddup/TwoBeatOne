//
//  TBOHistoryPlayer.m
//  Two Beat One
//
//  Created by Amay on 5/16/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "TBOHistoryPlayer.h"
#import "TBOAudioPlayer.h"
#import "TBOGameSetting.h"

@interface TBOHistoryPlayer()

@property(nonatomic)NSInteger  currentStep;
@property(strong,nonatomic)NSMutableArray *steps;
@property(strong,nonatomic)TBOAudioPlayer *soundPlayer;

@end


@implementation TBOHistoryPlayer
-(instancetype)init{
    self=[super init];
    if (self) {
        _currentStep=-1;
    }
    return self;

}

-(TBOAudioPlayer *)soundPlayer{
    if (!_soundPlayer &&
        [TBOGameSetting sharedGameSetting].soundON) {

        _soundPlayer=[[TBOAudioPlayer alloc]init];

    }
    return _soundPlayer;
}

-(void)setHistory:(NSDictionary *)history{
    _history=history;
    _currentStep=-1;
    self.steps=history[@"steps"];

    [self addChessPieces];

}
-(void)addChessPieces{

    if (!self.chessBoard || !self.history) {
        return;
    }
    for (NSString *string in self.history[@"positionWhenStartRecord"][@"allies"]) {
        [self.chessBoard addChessPieceAtPosition:[Position positionByString:string] isOpposite:NO];
    }

    for (NSString *string in self.history[@"positionWhenStartRecord"][@"enemies"]) {
        [self.chessBoard addChessPieceAtPosition:[Position positionByString:string] isOpposite:YES];
    }
}
-(void)setChessBoard:(ChessBoard *)chessBoard{
    _chessBoard=chessBoard;
    [self addChessPieces];
}

-(void)nextStep{
    if (self.currentStep < [self.steps count]-1 || self.currentStep == -1 ) {
        self.currentStep++;
        NSDictionary *step=self.steps[self.currentStep];
        [self.chessBoard chessPieceAtPosition:[Position positionByString:step[@"oldPosition"]]
                               moveToPosition:[Position positionByString:step[@"newPosition"]]];
        [self.soundPlayer playAudioWhenMove];
        [self checkNextStep];
    }
}
-(void)previousStep{
    if (self.currentStep >=0 ) {
        NSDictionary *step=self.steps[self.currentStep];
        if ([step[@"newPosition"] isEqualToString:@"00"]) {
            
            NSString *string= self.steps[self.currentStep-1][@"newPosition"];
            ChessPieceView *CP=[self.chessBoard chessPieceAtPosition:[Position positionByString:string]];
            [self.chessBoard addChessPieceAtPosition:[Position positionByString:step[@"oldPosition"]] isOpposite:!CP.isOpposite];
            
            self.currentStep--;
            step=self.steps[self.currentStep];
        }
        [self.chessBoard chessPieceAtPosition:[Position positionByString:step[@"newPosition"]]
                               moveToPosition:[Position positionByString:step[@"oldPosition"]]];
        [self.soundPlayer playAudioWhenMove];

        self.currentStep--;
        
    }
}
-(void)checkNextStep{

    if (self.currentStep+1<self.steps.count) {
        NSDictionary *step=self.steps[self.currentStep+1];
        if ([step[@"newPosition"] isEqualToString:@"00"]) {
            self.currentStep++;
            Position *p=[Position positionByString:step[@"oldPosition"]];
            [self.chessBoard removeChessPiece:[self.chessBoard
                                              chessPieceAtPosition:p]];
        }
    }
    
}


@end
