//
//  TBOLearderBoardViewController.m
//  Two Beat One
//
//  Created by Amay on 5/26/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "TBOLearderBoardViewController.h"
#import "TBOGameCommunicator.h"
#import "TBOLeaderBoardCell.h"
#import "defines.h"
#import "TBONoticeView.h"
#import <GameKit/GameKit.h>

#define LearderBoard_My_Rank_Label NSLocalizedStringFromTable(@"LearderBoard_My_Rank", @"LearderBoard", nil)
#define LearderBoard_My_Performance_Label NSLocalizedStringFromTable(@"LearderBoard_My_Performance", @"LearderBoard", nil)
#define LearderBoard_Performance_Label NSLocalizedStringFromTable(@"LearderBoard_Performance_Label", @"LearderBoard", nil)


@interface TBOLearderBoardViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(weak, nonatomic) IBOutlet UITableView *tableView;

@property(weak,nonatomic)UIRefreshControl *refreashControl;

@property(weak,nonatomic)UIView  *headerView;
@property(weak,nonatomic)UILabel *rankValueLabel;
@property(weak,nonatomic)UILabel *performanceValueLabel;
@property(weak,nonatomic)UILabel *rankLabel;
@property(weak,nonatomic)UILabel *performanceLabel;
@property(weak,nonatomic)UILabel *formateLabel;

@property(strong,nonatomic)NSArray *performances;
@property(strong,nonatomic)GKScore *myScore;

@end

@implementation TBOLearderBoardViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    
    [self loadLeaderBoard];
    [super viewDidLoad];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    self.tableView.allowsSelection=NO;
    
    [self configureHeaderView];
    [self configureRefreashControl];
}

// when enter into backgroudn and forrgroudn ,viewdidappear and viewdiddisappear not called
-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    if (!self.performances) {
        [self.refreashControl beginRefreshing];
        [self.tableView setContentOffset:CGPointMake(0, -self.refreashControl.frame.size.height)
                                animated:YES];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localPlayerAuthenticationDidChanged:)
                                                 name:GKPlayerAuthenticationDidChangeNotificationName
                                               object:nil];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self
                                                   name:GKPlayerAuthenticationDidChangeNotificationName
                                                 object:nil];
}
-(void)viewDidLayoutSubviews{
  
    self.headerView.frame=CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 66);
    self.rankLabel.frame=CGRectMake(0, 13, self.headerView.frame.size.width/2, 20);
    self.performanceLabel.frame=CGRectMake(0, CGRectGetMaxY(self.rankLabel.frame)+8, self.headerView.frame.size.width/2, 20);
    self.rankValueLabel.frame=CGRectMake(CGRectGetMaxX(self.rankLabel.frame)+15, CGRectGetMinY(self.rankLabel.frame), CGRectGetWidth(self.rankLabel.frame), CGRectGetHeight(self.rankLabel.frame));
    self.performanceValueLabel.frame=CGRectMake(CGRectGetMaxX(self.performanceLabel.frame)+15, CGRectGetMinY(self.performanceLabel.frame), CGRectGetWidth(self.rankValueLabel.frame), CGRectGetHeight(self.rankValueLabel.frame));
    self.formateLabel.frame=CGRectMake(CGRectGetMinX(self.performanceValueLabel.frame), CGRectGetMaxY(self.performanceValueLabel.frame), CGRectGetWidth(self.performanceValueLabel.frame), CGRectGetHeight(self.performanceValueLabel.frame));

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.performances=nil;
    
}
-(void)localPlayerAuthenticationDidChanged:(NSNotification *)notification{
    [self loadLeaderBoard];

    [self.tableView setContentOffset:CGPointMake(0, -self.refreashControl.frame.size.height)
                            animated:YES];
    [self.refreashControl beginRefreshing];
}

#pragma mark - configure UI
-(void)configureRefreashControl{
    
    UIRefreshControl *rfc=[[UIRefreshControl alloc]init];
    [rfc addTarget:self action:@selector(fetchScores:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:rfc];
    self.refreashControl=rfc;
}
-(void)fetchScores:(UIRefreshControl *)refreshControl{
    [self loadLeaderBoard];
}

-(void)configureHeaderView{

    UIView *headerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 66)];
    
    UILabel *rankLabel=[[UILabel alloc]initWithFrame:CGRectZero];
    rankLabel.text=LearderBoard_My_Rank_Label;//@"我的排名:";
    rankLabel.textAlignment=NSTextAlignmentRight;
    rankLabel.font=[UIFont systemFontOfSize:16 weight:UIFontWeightLight];
    rankLabel.textColor=[UIColor colorWithRed:1 green:1 blue:214.0/255 alpha:1];
    [rankLabel adjustsFontSizeToFitWidth];
    [headerView addSubview:rankLabel];
    self.rankLabel=rankLabel;
    
    UILabel *performanceLabel=[[UILabel alloc]initWithFrame:CGRectZero];
    performanceLabel.textAlignment=rankLabel.textAlignment;
    performanceLabel.text=LearderBoard_My_Performance_Label;//@"我的战绩:";
    performanceLabel.font=rankLabel.font;
    performanceLabel.textColor=rankLabel.textColor;
    [performanceLabel adjustsFontSizeToFitWidth];
    [headerView addSubview:performanceLabel];
    self.performanceLabel=performanceLabel;
    
    
    UILabel *rankValueLabel=[[UILabel alloc]initWithFrame:CGRectZero];

    rankValueLabel.text=@" ";
    rankValueLabel.textAlignment=NSTextAlignmentLeft;
    rankValueLabel.font=[UIFont systemFontOfSize:16];
    rankValueLabel.textColor=rankLabel.textColor;
    [rankValueLabel adjustsFontSizeToFitWidth];
    [headerView addSubview:rankValueLabel];
    self.rankValueLabel=rankValueLabel;
    
    UILabel *performanceValueLabel=[[UILabel alloc]initWithFrame:CGRectZero];
    performanceValueLabel.text=@"-/-";
    performanceValueLabel.textAlignment=NSTextAlignmentLeft;
    performanceValueLabel.font=[UIFont systemFontOfSize:16];
    performanceValueLabel.textColor=performanceLabel.textColor;
    [performanceValueLabel adjustsFontSizeToFitWidth];
    [headerView addSubview:performanceValueLabel];
    self.performanceValueLabel=performanceValueLabel;
    
    
    UILabel *formateLabel=[[UILabel alloc]initWithFrame:CGRectZero];
    formateLabel.text=LearderBoard_Performance_Label;//@"胜利次数/总次数";
    formateLabel.font=[UIFont systemFontOfSize:8 weight:UIFontWeightLight];
    formateLabel.textColor=[UIColor colorWithRed:1 green:1 blue:214.0/255 alpha:0.7];
    formateLabel.textAlignment=NSTextAlignmentLeft;
    self.formateLabel=formateLabel;
    [headerView addSubview:formateLabel];
    
    self.tableView.tableHeaderView=headerView;
    
    self.headerView=headerView;
    
}
-(IBAction)back:(UIButton *)button{
    if (self.splitViewController) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - load data
-(void)loadLeaderBoard{
    if ([GKLocalPlayer localPlayer].authenticated) {
        [[GKLocalPlayer localPlayer]loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
            GKLeaderboard *leaderBoard=[[GKLeaderboard alloc]init];
            leaderBoard.identifier=leaderboardIdentifier;
            [leaderBoard loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
                self.performances=scores;
                self.myScore=leaderBoard.localPlayerScore;
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.tableView reloadData];
                    //update data in table header
                    self.rankValueLabel.text=[@(self.myScore.rank) stringValue];
                    self.performanceValueLabel.text=[NSString stringWithFormat:@"%lld/%llu",self.myScore.value-self.myScore.context/2,self.myScore.context/2];
                    
                    // end refreshing
                    [self.refreashControl endRefreshing];
                });
            }];
        }];
    }

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.performances.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TBOLeaderBoardCell" forIndexPath:indexPath];
    
    return cell;
}

#pragma mark - Table view delegate
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TBOLeaderBoardCell *leaderBoardCell=(TBOLeaderBoardCell *)cell;
    
    GKScore *performance=(GKScore *)self.performances[indexPath.row];
    GKPlayer *player=performance.player;
    
    [player loadPhotoForSize:GKPhotoSizeNormal withCompletionHandler:^(UIImage *photo, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            leaderBoardCell.playerPhoto=photo;
        });
    }];

    leaderBoardCell.rank=performance.rank;
    leaderBoardCell.playerName=player.alias;
    leaderBoardCell.performance=[NSString stringWithFormat:@"%lld/%llu",performance.value-performance.context/2,performance.context/2];
    leaderBoardCell.formattedperformance=LearderBoard_Performance_Label; //@"胜利次数/总次数";
    leaderBoardCell.playerPhoto=[UIImage imageNamed:@"DefaultPhoto"];

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    switch (indexPath.row) {
        case 0:
            return 88;
        case 1:
            return 81;
        case 2:
            return 74;
        default:
            return 66;
    }
}


@end
