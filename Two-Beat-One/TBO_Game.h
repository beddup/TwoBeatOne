//
//  TBO_Game.h
//  Two Beat One
//
//  Created by Amay on 4/29/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Position.h"
#import "defines.h"

//------------------------------------
// Piece Class Interface
//------------------------------------
@interface Piece : NSObject

@property(strong,nonatomic) Position* position;//(1,1)->(4,4)
@property(nonatomic,readonly) BOOL isOpposite;
@property(nonatomic)BOOL isChosen;
-(instancetype)initWithPosition:(Position *)position isOpposite:(BOOL)isOpposite;
-(void)moveTo:(Position*)newPosition;

@end

//------------------------------------
// Game Class Interface
//------------------------------------
typedef enum : NSUInteger {
    GameStateJustBuilt,
    GameStateProcceed,
    GameStateEnd,
} StateOfGame;

@protocol TBO_Game_Delegate <NSObject>

-(void)pieceAtPosition:(Position*)position moveTo:(Position*)newPosition;
-(void)pieceAtPositionKilled:(Position*)position;
-(void)addPieceAtPosition:(Position*)positon isOpposite:(BOOL)isOpposite;// used in custom mode
-(void)gameEnd:(BOOL)win;

@end


@interface TBO_Game : NSObject  //abstract 

@property(nonatomic,readonly)BOOL myTurn;
@property(nonatomic,readonly)NSUInteger stepCount;
@property(nonatomic,readonly)BOOL isRecording;
@property(nonatomic,readonly)StateOfGame stateOfGame;
@property(weak,nonatomic)id<TBO_Game_Delegate>delegate;

-(void)startWithFirstTurn:(BOOL)myTurn;
-(void)reset;
-(void)startRecord:(NSString *)oppositeName;

-(void)addPiecePosition:(Position *)position isOpposite:(BOOL)opposite;
-(void)moveFromPosition:(Position *)position to:(Position *)toPosition;
-(void)positionWasHit:(Position *)position;

-(void)didReceiveMemoryWarning;

@end
