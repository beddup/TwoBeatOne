//
//  TBO_Game.m
//  Two Beat One
//
//  Created by Amay on 4/29/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "TBO_Game.h"
#import "defines.h"
#import "TBO_Custom_Game.h"
#import "TBO_Standard_Game.h"
#import "TBOAudioPlayer.h"
#import "TBOGameSetting.h"

//------------------------------------
// Piece Implementation
//------------------------------------

@implementation Piece

-(instancetype)initWithPosition:(Position *)position isOpposite:(BOOL)isOpposite{
    self=[super init];
    if (self) {
        _position=position;
        _isOpposite=isOpposite;
        _isChosen=NO;
    }
    return self;
}
-(id)valueForKey:(NSString *)key{
    if ([key isEqualToString:@"position"]) {
        return self.position;
    }
    return nil;
}
-(void)moveTo:(Position*)newPosition
{
    self.position=newPosition;
}

@end


//------------------------------------
// Game Implementation
//------------------------------------
@interface TBO_Game()

@property(weak,nonatomic)Piece * pieceWhichIsChosen;
@property(strong,nonatomic)NSMutableDictionary *historySteps; //record all history steps
@property(nonatomic,readwrite)BOOL myTurn;
@property(nonatomic,readwrite)StateOfGame stateOfGame;
@property(nonatomic,readwrite)NSUInteger stepCount;
@property(strong,nonatomic,readwrite)NSMutableArray *enemies; //all position of enemies
@property(strong,nonatomic,readwrite)NSMutableArray *allies;  // all position of allies
@property(nonatomic,readwrite)BOOL isRecording;
@property(strong,nonatomic) TBOAudioPlayer *soundPlayer;//sound playing manager

@end


@implementation TBO_Game
#pragma mark - Instantiation
-(instancetype)init{
    self=[super init];
    if (self) {
        self.stateOfGame=GameStateJustBuilt;
        self.enemies = [@[] mutableCopy];
        self.allies  = [@[] mutableCopy];
    }
    return self;
}
#pragma mark - Property
-(TBOAudioPlayer *)soundPlayer{
    if (!_soundPlayer &&
        [TBOGameSetting sharedGameSetting].soundON) {

        _soundPlayer=[[TBOAudioPlayer alloc]init];

    }
    return _soundPlayer;
}
#pragma  mark - public API
-(void)startWithFirstTurn:(BOOL)myTurn{
    [self reset];
    self.myTurn=myTurn;
}
-(void)reset{

    self.myTurn=NO;
    self.stateOfGame=GameStateJustBuilt;
    self.enemies=nil;
    self.allies=nil;
    self.pieceWhichIsChosen=nil;
    self.stepCount=0;
    self.isRecording=NO;
    self.historySteps=nil;
    
}
-(void)startRecord:(NSString*)oppositeName{

    self.isRecording=YES;
    self.historySteps=[@{@"opposite":oppositeName,
                         @"dateAndTime":[NSDate date],
                         @"positionWhenStartRecord":@{@"allies":[self.allies valueForKeyPath:@"position.string"] ,
                                                      @"enemies":[self.enemies valueForKeyPath:@"position.string"]},

                         @"isMyTurn":self.myTurn? @(YES):@(NO),
                         @"steps":[NSMutableArray new],
                         @"isChosen":@(NO) // used in  history collection
                         }
                       mutableCopy];
    
}

-(void)addPiecePosition:(Position *)position isOpposite:(BOOL)opposite{
    [self.soundPlayer playAudioWhenAddChessPiece];
}
-(void)moveFromPosition:(Position *)position to:(Position *)toPosition{
    if (self.stateOfGame==GameStateProcceed) {
        [self.soundPlayer playAudioWhenMove];
        Piece *piece=[self pieceAtPosition:position];
        [self.historySteps[@"steps"] addObject:@{@"oldPosition":position.string,
                                                 @"newPosition":toPosition.string}];

        [piece moveTo:toPosition];
        [self checkMove:piece];
        self.myTurn=piece.isOpposite;
    }
}
-(void)positionWasHit:(Position *)position{
    Piece *piece=[self pieceAtPosition:position];
    piece ? [self pieceWasHit:piece] : [self emptyPositionWasHit:position];
}
-(void)pieceWasHit:(Piece * )piece{

    self.pieceWhichIsChosen.isChosen=NO;
    piece.isChosen=YES;
    self.pieceWhichIsChosen=piece;

}
-(void)emptyPositionWasHit:(Position * )position{} //abstract, need override by subclass

#pragma mark - Looking for piece
-(Piece *)pieceAtPosition:(Position *)position isOpposite:(BOOL)opposite{
    if (![position isValid]) {
        return nil;
    }
    NSArray *arrayToBeSearched=opposite ? self.enemies : self.allies;
    for (Piece *piece in arrayToBeSearched ) {
        if ([piece.position.string isEqualToString:position.string]) {
            return piece;
        }
    }
    return nil;
}
-(Piece*)pieceAtPosition:(Position*)position{
    Piece *piece=[self pieceAtPosition:position isOpposite:NO];
    return piece ? piece : [self pieceAtPosition:position isOpposite:YES];
}


#pragma mark - check game based on move

-(void)checkMove:(Piece *)piece{

    Piece *leftNearByPiece=[self pieceAtPosition:[piece.position nearByPosition:PositionDirectionLeft] isOpposite:piece.isOpposite];
    Piece *rightNearByPiece=[self pieceAtPosition:[piece.position nearByPosition:PositionDirectionRight] isOpposite:piece.isOpposite];
    Piece *upNearByPiece=[self pieceAtPosition:[piece.position nearByPosition:PositionDirectionUp]isOpposite:piece.isOpposite];
    Piece *downNearByPiece=[self pieceAtPosition:[piece.position nearByPosition:PositionDirectionDown]isOpposite:piece.isOpposite];

    if (leftNearByPiece) {
        [self findPossiblePieceToBeKilledBy:@[piece,leftNearByPiece]
                                directions:@[@(PositionDirectionRight),@(PositionDirectionLeft)]];
    }else if (rightNearByPiece ) {
        [self findPossiblePieceToBeKilledBy:@[piece,rightNearByPiece]
                                directions:@[@(PositionDirectionLeft),@(PositionDirectionRight)]];
    }
    if (upNearByPiece ) {
        [self findPossiblePieceToBeKilledBy:@[piece,upNearByPiece]
                                directions:@[@(PositionDirectionDown),@(PositionDirectionUp)]];
    }else if (downNearByPiece ) {
        [self findPossiblePieceToBeKilledBy:@[piece,downNearByPiece]
                                directions:@[@(PositionDirectionUp),@(PositionDirectionDown)]];
    }
}

-(void)findPossiblePieceToBeKilledBy:(NSArray *)two directions:(NSArray *)directions{

        Position *possibleToBeKilledPosition1=[((Piece*)two[0]).position nearByPosition:[directions[0] integerValue]];
        Position *possibleToBeKilledPosition2=[((Piece*)two[1]).position nearByPosition:[directions[1] integerValue]];

        Position *possibleTail1=[possibleToBeKilledPosition1 nearByPosition:[directions[0] integerValue]];
        Position *possibleTail2=[possibleToBeKilledPosition2 nearByPosition:[directions[1] integerValue]];
        //if there are tails, nothing killed
        if ([self pieceAtPosition:possibleTail1] || [self pieceAtPosition:possibleTail2]) {
            return;
        }

        Piece *possibleToBeKilledPiece1=[self pieceAtPosition:possibleToBeKilledPosition1];
        Piece *possibleToBeKilledPiece2=[self pieceAtPosition:possibleToBeKilledPosition2];
        // if 2112 ,nothing killed
        if (possibleToBeKilledPiece1 && possibleToBeKilledPiece2) {
            return;
        }
        // if 211 or 112, then 2 was killed
        if (possibleToBeKilledPiece1 && possibleToBeKilledPiece1.isOpposite != ((Piece*)two[0]).isOpposite) {
            [self pieceAtPositionKilled:possibleToBeKilledPosition1];
        }else if (possibleToBeKilledPiece2 && possibleToBeKilledPiece2.isOpposite != ((Piece*)two[0]).isOpposite ){
            [self pieceAtPositionKilled:possibleToBeKilledPosition2];
        }
}

-(void)pieceAtPositionKilled:(Position*)position{
    Piece *pieceToBeKilled=[self pieceAtPosition:position];
    pieceToBeKilled.isOpposite ? [self.enemies removeObject:pieceToBeKilled] : [self.allies removeObject:pieceToBeKilled];
    [self.historySteps[@"steps"] addObject:@{@"oldPosition":position.string,
                                             @"newPosition":@"00"}];

    [self.delegate pieceAtPositionKilled:position];
    [self checkGameProgress];
}

-(void)checkGameProgress{
    if (self.enemies.count<=1 || self.allies.count<=1) {
        [self gameEnd:self.allies.count>self.enemies.count];
        return;
    }
    if (self.myTurn) {
        for (Piece *piece in self.allies) {
            if ([self canMove:piece]) {
                return;
            }
        }
        [self gameEnd:NO];
        return;
    }
    for (Piece *piece in self.enemies) {
        if ([self canMove:piece]) {
            return;
        }
    }
    [self gameEnd:YES];
}
-(BOOL)canMove:(Piece *)piece{

    Position * upPositon   =[piece.position nearByPosition:PositionDirectionUp];
    Position * downPositon =[piece.position nearByPosition:PositionDirectionDown];
    Position * leftPositon =[piece.position nearByPosition:PositionDirectionLeft];
    Position * rightPositon=[piece.position nearByPosition:PositionDirectionRight];

    if (([upPositon isValid]    &&  ![self pieceAtPosition:upPositon])   ||
        ([downPositon isValid]  &&  ![self pieceAtPosition:downPositon]) ||
        ([leftPositon isValid]  &&  ![self pieceAtPosition:leftPositon]) ||
        ([rightPositon isValid] &&  ![self pieceAtPosition:rightPositon])) {

        return YES;
    }
    return NO;

}
-(void)gameEnd:(BOOL)meWin{

    self.stateOfGame=GameStateEnd;
    [self.delegate gameEnd:meWin];

    if (!self.historySteps) {
        return;
    }

    [self storeRecord];

}


#pragma mark - store Record

-(void)storeRecord{

    [self.historySteps setObject:@{@"allies":[self.allies valueForKeyPath:@"position.string"],
                                   @"enemies":[self.enemies valueForKeyPath:@"position.string"]}
                          forKey:@"positionWhenEnd"];

    NSMutableArray *history=nil;

    if( ![[NSFileManager defaultManager]fileExistsAtPath:historyPath]){
        [[NSFileManager defaultManager] createFileAtPath:historyPath contents:nil attributes:nil];
        history=[NSMutableArray array];
    }
    else{
        history=[NSMutableArray arrayWithContentsOfFile:historyPath];
    }
    [history addObject:self.historySteps];
    if (![history writeToFile:historyPath
                   atomically:NO]){}
    self.historySteps=nil;
}

-(void)didReceiveMemoryWarning{
    self.soundPlayer=nil;
}


@end
