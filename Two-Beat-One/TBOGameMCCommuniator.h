//
//  TBOGameMCCommuniator.h
//  Two Beat One
//
//  Created by Amay on 5/30/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "TBOGameCommunicator.h"
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface TBOGameMCCommuniator : TBOGameCommunicator

-(void)startAdvertising;
-(void)stopAdvertising;

-(void)browseNearByPlayers:(UIViewController *)presentingVC;

@end
