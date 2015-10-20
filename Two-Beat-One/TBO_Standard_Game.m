//
//  TBO_Standard_Game.m
//  Two Beat One
//
//  Created by Amay on 5/12/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "TBO_Standard_Game.h"
#import "TBOGameSetting.h"
@interface TBO_Standard_Game()

@property(strong,nonatomic,readwrite)NSMutableArray *enemies; //all position of enemies
@property(strong,nonatomic,readwrite)NSMutableArray *allies;  // all position of allies
@property(nonatomic,readwrite)StateOfGame stateOfGame;

@property(weak,nonatomic,readwrite)Piece *pieceWhichIsChosen;
@property(nonatomic,readwrite)NSUInteger stepCount;




@end

@implementation TBO_Standard_Game

@synthesize allies=_allies;
@synthesize enemies=_enemies;
@synthesize stateOfGame=_stateOfGame;
@synthesize stepCount=_stepCount;

-(void)startWithFirstTurn:(BOOL)myTurn{
    [super startWithFirstTurn:myTurn];
    self.allies=[@[[[Piece alloc]initWithPosition:[[Position alloc] initWithX:1 Y:1] isOpposite:NO],
               [[Piece alloc]initWithPosition:[[Position alloc] initWithX:2 Y:1] isOpposite:NO],
               [[Piece alloc]initWithPosition:[[Position alloc] initWithX:3 Y:1] isOpposite:NO],
               [[Piece alloc]initWithPosition:[[Position alloc] initWithX:4 Y:1] isOpposite:NO],
               ] mutableCopy];

    self.enemies=[@[[[Piece alloc]initWithPosition:[[Position alloc] initWithX:1 Y:4] isOpposite:YES],
                [[Piece alloc]initWithPosition:[[Position alloc] initWithX:2 Y:4] isOpposite:YES],
                [[Piece alloc]initWithPosition:[[Position alloc] initWithX:3 Y:4] isOpposite:YES],
                [[Piece alloc]initWithPosition:[[Position alloc] initWithX:4 Y:4] isOpposite:YES],
                ] mutableCopy];
    self.stateOfGame=GameStateProcceed;
}

-(void)emptyPositionWasHit:(Position * )position{

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


@end
