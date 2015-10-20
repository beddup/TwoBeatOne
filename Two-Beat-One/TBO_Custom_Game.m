//
//  TBO_Custom_Game.m
//  Two Beat One
//
//  Created by Amay on 5/12/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "TBO_Custom_Game.h"
#import "TBOGameSetting.h"

@interface TBO_Custom_Game()

@property(strong,nonatomic,readwrite)NSMutableArray *enemies; //all position of enemies
@property(strong,nonatomic,readwrite)NSMutableArray *allies;  // all position of allies
@property(nonatomic,readwrite)BOOL myTurn;

@property(nonatomic,readwrite)StateOfGame stateOfGame;
@property(weak,nonatomic,readwrite)Piece *pieceWhichIsChosen;
@property(nonatomic)BOOL canMove;//indicate whether both side finish lay pieces down
@property(nonatomic,readwrite)NSUInteger stepCount;

@end


@implementation TBO_Custom_Game

@synthesize allies=_allies;
@synthesize enemies=_enemies;
@synthesize myTurn=_myTurn;
@synthesize stateOfGame=_stateOfGame;
@synthesize stepCount=_stepCount;

-(void)startWithFirstTurn:(BOOL)myTurn{

    [super startWithFirstTurn:myTurn];

    self.enemies=[@[] mutableCopy];

    self.allies=[@[] mutableCopy];

    self.stateOfGame=GameStateProcceed;

}
-(void)emptyPositionWasHit:(Position * )position{

    if (self.canMove) {
        [self handleEmptyPositionEvent:position];
        return;
    }
    if ([TBOGameSetting sharedGameSetting].gameContext != GameContextOffline && self.myTurn) {
        [self.delegate addPieceAtPosition:position isOpposite:NO];
        [self addPiecePosition:position isOpposite:NO];

        return;
    }
    if ([TBOGameSetting sharedGameSetting].gameContext == GameContextOffline){
        [self.delegate addPieceAtPosition:position isOpposite:!self.myTurn];
        [self addPiecePosition:position isOpposite:!self.myTurn];

    }
}

-(void)handleEmptyPositionEvent:(Position * )position{
    
    if ([self.pieceWhichIsChosen.position isNearTo:position] &&
        self.stateOfGame == GameStateProcceed) {
        
        if (([TBOGameSetting sharedGameSetting].gameContext != GameContextOffline && !self.pieceWhichIsChosen.isOpposite && self.myTurn) ||
            ([TBOGameSetting sharedGameSetting].gameContext == GameContextOffline &&  self.pieceWhichIsChosen.isOpposite==!self.myTurn)) {
            Position *oldPosition=self.pieceWhichIsChosen.position;
            if (self.myTurn) {
                self.stepCount++;
            }
            [self.delegate pieceAtPosition:oldPosition moveTo:position];
            [self moveFromPosition:oldPosition to:position];

        }
    }
}

-(void)addPiecePosition:(Position *)position isOpposite:(BOOL)opposite{

    [super addPiecePosition:position isOpposite:opposite];
    self.myTurn=opposite;
    Piece *piece=[[Piece alloc]initWithPosition:position isOpposite:opposite];
    opposite ? [self.enemies addObject:piece]:[self.allies addObject:piece];
    if (self.allies.count == 4 && self.enemies.count == 4) {
        //both side finished lay pieces down
        self.canMove=YES;
    }

}

-(void)reset{
    [super reset];
    self.canMove=NO;
}

@end
