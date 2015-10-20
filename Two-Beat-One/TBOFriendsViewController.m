//
//  TBOFriendsViewController.m
//  Two Beat One
//
//  Created by Amay on 5/30/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "TBOFriendsViewController.h"
#import "TBOGameGCCommunicator.h"
#import "NoticeViewWithBlurEffect.h"
#import "TBOGameSetting.h"
#import <GameKit/GameKit.h>


@interface TBOFriendsViewController()

@property(strong,nonatomic)NSArray *friends;
@property (weak, nonatomic) UIRefreshControl *refresher;

@end

@implementation TBOFriendsViewController


-(void)viewDidLoad{
    [super viewDidLoad];

    // fetch the friend of local player
    if(!(self.friends=[[TBOGameGCCommunicator sharedTBOGameCommunicator] friends])){
        [self fetchFriends];
    };
    UIImageView *bkg=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bkg"]];
    [self.tableView setBackgroundView:bkg];
    [self configureRefreashControl];
    
}
-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    if (!self.friends) {
        [self.tableView setContentOffset:CGPointMake(0, -60) animated:YES];
        [self.refresher beginRefreshing];
    }
}
-(void)configureRefreashControl{
    
    UIRefreshControl *rfc=[[UIRefreshControl alloc]init];
    [rfc addTarget:self action:@selector(fetchFriends) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:rfc];
    self.refresher=rfc;
}

- (void)fetchFriends{
    [[GKLocalPlayer localPlayer] loadFriendPlayersWithCompletionHandler:^(NSArray *friendPlayers, NSError *error) {
        if (!error) {
            NSLog(@"fetch success");
            self.friends=friendPlayers;
        }
    }];
}

-(void)setFriends:(NSArray *)friends{
    _friends=friends;
    dispatch_async(dispatch_get_main_queue(), ^{
        
       [self.tableView reloadData];
       [self.refresher endRefreshing];
    });

}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   return self.friends.count;
}

#define BrowingFriendOrPlayer_Friend_Before_Hit  NSLocalizedStringFromTable(@"BrowingFriendOrPlayer_Friend_Before_Hit", @"BrowingFriendOrPlayer", @"hit to invite")

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPat{
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"friend"];
    cell.backgroundColor=[UIColor clearColor];
    GKPlayer *player=self.friends[indexPat.row];
    [player loadPhotoForSize:GKPhotoSizeNormal withCompletionHandler:^(UIImage *photo, NSError *error) {
        if (!error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.imageView.frame=CGRectInset(cell.imageView.frame, 5, 5);
                
                cell.imageView.image=photo;
            });
        }
    }];
    cell.imageView.image=[UIImage imageNamed:@"defaultPlayerImage"];
    cell.textLabel.text=player.alias;
    cell.textLabel.font=[UIFont fontWithName:CUSTOMEFONT_W3 size:20];
    cell.textLabel.textColor=[UIColor colorWithRed:1 green:1 blue:220.0/255 alpha:1];

    cell.detailTextLabel.text=BrowingFriendOrPlayer_Friend_Before_Hit;//@"点击邀请";
    cell.detailTextLabel.font=[UIFont fontWithName:CUSTOMEFONT_W3 size:20];
    cell.detailTextLabel.textColor=cell.textLabel.textColor;

    
    return cell;
}


#define BrowingFriendOrPlayer_Cell_Detail_Text_After_Hit  NSLocalizedStringFromTable(@"BrowingFriendOrPlayer_Cell_Detail_Text_After_Hit", @"BrowingFriendOrPlayer", @"invitation send")


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    GKPlayer *player=self.friends[indexPath.row];
    [[TBOGameGCCommunicator sharedTBOGameCommunicator] inviteFriend:player];

    UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
    cell.detailTextLabel.text=BrowingFriendOrPlayer_Cell_Detail_Text_After_Hit;//@"已发出邀请";
    cell.detailTextLabel.font=[UIFont fontWithName:CUSTOMEFONT_W3 size:16];

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 60.0;
}

#define BrowingFriendOrPlayer_Title  NSLocalizedStringFromTable(@"BrowingFriendOrPlayer_Title", @"BrowingFriendOrPlayer", @"Title")

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
    label.text=BrowingFriendOrPlayer_Title;//@"好友";
    label.font=[UIFont fontWithName:CUSTOMEFONT_W5 size:24];
    label.textColor=[UIColor colorWithRed:1 green:1 blue:220.0/255 alpha:1];
    [view addSubview:label];
    
    return view;
    
}
-(void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}
@end
