//
//  TBONearByPlayeysController.m
//  Two Beat One
//
//  Created by Amay on 5/31/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//
#import "TBONearByPlayeysController.h"
#import "TBOGameMCCommuniator.h"
#import "TBOGameCommunicator+DataParser.h"
#import "TBOGameSetting.h"
#import "NoticeViewWithBlurEffect.h"
#import <GameKit/GameKit.h>
@interface TBONearByPlayeysController()<MCNearbyServiceBrowserDelegate>

@property(strong,nonatomic)NSArray *nearByPlayers;
@property (weak, nonatomic) UIRefreshControl *refresher;

@property(strong,nonatomic)MCNearbyServiceBrowser *browser;

@property(nonatomic)BOOL isInvitating;

@property(strong,nonatomic)NSTimer *timer;

@end


@implementation TBONearByPlayeysController

@synthesize nearByPlayers=_nearByPlayers;
NSString * const serviceType=@"tbo";

-(void)viewDidLoad{
    [self.browser startBrowsingForPeers];
    [super viewDidLoad];
    UIImageView *bkg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bkg"]];
    [self.tableView setBackgroundView:bkg];
    [self configureRefreashControl];

}
-(MCNearbyServiceBrowser *)browser{
    if (!_browser) {
        _browser=[[MCNearbyServiceBrowser alloc]initWithPeer:[TBOGameMCCommuniator localPeer]
                                                 serviceType:MC_SERVICE_TYPE];
        _browser.delegate=self;
    }
    return _browser;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView setContentOffset:CGPointMake(0, -60) animated:YES];
    [self.refresher beginRefreshing];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!self.splitViewController) {
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(displayNoticeView:)
                                                    name:DISPLAY_NOTICE_VIEW_NOTIFICATION
                                                  object:nil];
    }

}
-(void)viewDidDisappear:(BOOL)animated{
    [self.browser stopBrowsingForPeers];
    self.browser=nil;
    [self.timer invalidate];
    self.timer=nil;
    timeLeftToUpdateDetailText=Default_Time_Out;
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:DISPLAY_NOTICE_VIEW_NOTIFICATION
                                                 object:nil];

}
-(void)configureRefreashControl{
    
    UIRefreshControl *rfc=[[UIRefreshControl alloc]init];
    [self.tableView addSubview:rfc];
    self.refresher=rfc;
    [self.refresher addTarget:self.browser action:@selector(startBrowsingForPeers) forControlEvents:UIControlEventValueChanged];
}
-(NSArray *)nearByPlayers{
    if (!_nearByPlayers) {
        _nearByPlayers=@[];
    }
    return _nearByPlayers;
}
-(void)setNearByPlayers:(NSMutableArray *)nearByPlayers
{
    _nearByPlayers=nearByPlayers;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView reloadData];
        [self.refresher endRefreshing];
        
    });
    
}
-(void)setIsInvitating:(BOOL)isInvitating{
    _isInvitating=isInvitating;
    self.tableView.allowsSelection=!isInvitating;
}
#pragma mark -  advertiser delegate
-(void)displayNoticeView:(NSNotification *)notification{
    UIView *noticeView=(UIView *)notification.object;
    noticeView.center=self.view.center;
    [self.view addSubview:noticeView];
}
#pragma mark -  browser delegate
- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info{

    if (![[self.nearByPlayers valueForKey:@"displayName"] containsObject:peerID.displayName]) {
        self.nearByPlayers=[self.nearByPlayers arrayByAddingObject:peerID];
    }
}
// A nearby peer has stopped advertising
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID{
    [[self.nearByPlayers mutableCopy] removeObject:peerID];
    self.nearByPlayers=_nearByPlayers;
}

//@optional
// Browsing did not start due to an error
- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error{
    NSLog(@"%@",[error localizedDescription]);
}

#pragma  mark - table view

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.nearByPlayers.count;
}

#define BrowingFriendOrPlayer_NearBy_Player_Before_Hit  NSLocalizedStringFromTable(@"BrowingFriendOrPlayer_NearBy_Player_Before_Hit", @"BrowingFriendOrPlayer", @"hit to invite")

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"nearByPlayer"];
    cell.backgroundColor=[UIColor clearColor];
    GKPlayer *player=self.nearByPlayers[indexPath.row];
    cell.textLabel.text=player.displayName;
    cell.textLabel.font=[UIFont fontWithName:CUSTOMEFONT_W3 size:20];
    cell.textLabel.textColor=[UIColor colorWithRed:1 green:1 blue:220.0/255 alpha:1];
    cell.textLabel.textAlignment=NSTextAlignmentCenter;
    
    cell.detailTextLabel.text=BrowingFriendOrPlayer_NearBy_Player_Before_Hit;//@"点击邀请";
    cell.detailTextLabel.font=[UIFont fontWithName:CUSTOMEFONT_W3 size:20];
    cell.detailTextLabel.textColor=cell.textLabel.textColor;
    cell.detailTextLabel.textAlignment=NSTextAlignmentCenter;

    return cell;
}

#define BrowingFriendOrPlayer_Cell_Detail_Invitating NSLocalizedStringFromTable(@"BrowingFriendOrPlayer_Cell_Detail_Invitating", @"BrowingFriendOrPlayer", @"inviting time out :default time out")

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (!self.isInvitating) {
        MCPeerID *peer=self.nearByPlayers[indexPath.row];
        [[TBOGameMCCommuniator sharedTBOGameCommunicator] browser:self.browser
                                                       invitePeer:peer];
        UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:indexPath];
        cell.detailTextLabel.text= [BrowingFriendOrPlayer_Cell_Detail_Invitating stringByAppendingString:[@(Default_Time_Out) stringValue]];
        self.isInvitating=YES;
        
        
        self.timer= [NSTimer timerWithTimeInterval:1.0
                                            target:self
                                          selector:@selector(updateDetailText:)
                                          userInfo:@{@"cell":cell}
                                           repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    }
}

static NSInteger timeLeftToUpdateDetailText=Default_Time_Out;
-(void)updateDetailText:(NSTimer *)timer{

    NSLog(@"working");
    timeLeftToUpdateDetailText--;
    UITableViewCell *cell=timer.userInfo[@"cell"];
    if(timeLeftToUpdateDetailText){
        cell.detailTextLabel.text=[BrowingFriendOrPlayer_Cell_Detail_Invitating stringByAppendingString:[@(timeLeftToUpdateDetailText) stringValue]];//[NSString stringWithFormat:@"正在邀请(%@)",@(timeLeftToUpdateDetailText)];
        return;
    }
    cell.detailTextLabel.text=BrowingFriendOrPlayer_NearBy_Player_Before_Hit;//@"点击邀请";
    self.isInvitating=NO;
    timeLeftToUpdateDetailText=Default_Time_Out;
    [timer invalidate];
    [[TBOGameMCCommuniator sharedTBOGameCommunicator] cancelInvitation];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60.0;
}

#define BrowingFriendOrPlayer_NearBy_Title NSLocalizedStringFromTable(@"BrowingFriendOrPlayer_NearBy_Title", @"BrowingFriendOrPlayer", @"title")

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 60.0)];
    CGFloat widthOfCloseButton=CGRectGetWidth(self.view.frame)/10 > 44 ? 44:CGRectGetWidth(self.view.frame)/10;
    UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, widthOfCloseButton, widthOfCloseButton)];
    button.center=CGPointMake(CGRectGetWidth(view.frame)-30, CGRectGetHeight(view.frame)/2);
    [button setBackgroundImage:[UIImage imageNamed:@"closeNotice"] forState:UIControlStateNormal];
    [view addSubview:button];
    [button addTarget:self
               action:@selector(dismiss)
     forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height)];
    label.textAlignment=NSTextAlignmentCenter;
    label.text=BrowingFriendOrPlayer_NearBy_Title;//@"附近的玩家";
    label.font=[UIFont fontWithName:CUSTOMEFONT_W5 size:24];
    label.textColor=[UIColor colorWithRed:1 green:1 blue:220.0/255 alpha:1];
    [view addSubview:label];
    
    return view;
    
}
-(void)dismiss{
    [self.browser stopBrowsingForPeers];
    self.browser=nil;
    [self.timer invalidate];
    timeLeftToUpdateDetailText=Default_Time_Out;
    if (self.isInvitating) {
        [[TBOGameMCCommuniator sharedTBOGameCommunicator] cancelInvitation];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}



@end
