//
//  TBOGameGCCommunicator.h
//  Two Beat One
//
//  Created by Amay on 5/30/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "TBOGameCommunicator.h"
#import <GameKit/GameKit.h>
@interface TBOGameGCCommunicator : TBOGameCommunicator


-(BOOL)isAuthernticationCompleted;
-(void)authenticateLocalUser;
-(void)checkAuthenticationProgress;

-(BOOL)oppositeIsFriend;

-(void)makeFriendWithOpposite:(UIViewController *)presentingVC;
-(void)findMatch:(UIViewController *)presentingVC;


@end
