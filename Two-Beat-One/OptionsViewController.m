//
//  optionsViewController.m
//  Two Beat One
//
//  Created by Amay on 5/6/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "OptionsViewController.h"
#import "TBOHistoryCollectionViewController.h"
#import "GameChosingView.h"
#import "TwoBeatOneGameViewController.h"
#import "HowToPlayViewController.h"
#import "TBOPlayHistoryViewController.h"
#import "TBOGameSetting.h"
#import "UIView+CenterConstraint.h"
#import "TBOGameGCCommunicator.h"
@interface OptionsViewController()

@property (weak, nonatomic) IBOutlet UIButton *soundSwitch;
@property (weak, nonatomic) IBOutlet UIButton *showHistory;
@property (weak, nonatomic) IBOutlet UIButton *showLeaderBoard;
@property (weak, nonatomic) IBOutlet UIImageView *gridBKG;
@property(weak,nonatomic)GameChosingView *gameChosingPad;

@end

@implementation OptionsViewController


-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=YES;
    [self updateSoundButtonUI];
    [self setBKGImage];
    
    if (!self.splitViewController) {
        UIPanGestureRecognizer *panToTransition=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panToTransition:)];
        [self.view addGestureRecognizer:panToTransition];
    }

    UITapGestureRecognizer *tapToDismisGameChosingPad=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissGameChosingPad:)];
    [self.view addGestureRecognizer:tapToDismisGameChosingPad];

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.transiton.isInteractive=YES;
}
-(void)viewDidAppear:(BOOL)animated{
}
-(void)viewWillLayoutSubviews{
    [self.view layoutSubviews];
}
-(void)viewDidLayoutSubviews{
}
-(void)viewWillDisappear:(BOOL)animated{
}
-(void)viewDidDisappear:(BOOL)animated{
}
-(void)setBKGImage{
    // set grid bgk
    NSString *path=[[NSBundle mainBundle]pathForResource:@"options_BKG"
                                                  ofType:@"png"];
    self.gridBKG.image=[UIImage imageWithContentsOfFile:path];

    // set showHistory button BGK image
    NSString *showHistoryBKGImagePath=[[NSBundle mainBundle]pathForResource:@"HistoryIcon"
                                                                     ofType:@"png"];
    [self.showHistory setBackgroundImage:[UIImage imageWithContentsOfFile:showHistoryBKGImagePath]
                                forState:UIControlStateNormal];

    // set showleaderBoard button BGK image
    NSString *showleaderBoardBKGImagePath=[[NSBundle mainBundle]pathForResource:@"LeaderBoardIcon"
                                                                         ofType:@"png"];
    [self.showLeaderBoard setBackgroundImage:[UIImage imageWithContentsOfFile:showleaderBoardBKGImagePath]
                                    forState:UIControlStateNormal];
}
#pragma  mark - handle gestures
-(void)panToTransition:(UIPanGestureRecognizer *)gesture{
    CGPoint translation=[gesture translationInView:self.view];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.transiton.beginInteractiveTransition=NO;
    }
    if (translation.x > 50 && !self.transiton.beginInteractiveTransition) {
        self.transiton.beginInteractiveTransition=YES;
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }

    [self.transiton handlePanTransitionGesture:gesture];

}
-(void)dismissGameChosingPad:(UITapGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self.gameChosingPad removeFromSuperview];
        self.gameChosingPad=nil;
    }
}

-(void)updateSoundButtonUI{

    NSString *path=[[NSBundle mainBundle]pathForResource:[TBOGameSetting sharedGameSetting].soundON ? @"SoundONIcon":@"SoundOffIcon"
                                                  ofType:@"png"];
    [self.soundSwitch setBackgroundImage:[UIImage imageWithContentsOfFile:path]
                           forState:UIControlStateNormal];
}

#pragma mark - IBAction
- (IBAction)changeSoundSetting:(UIButton *)sender {
    
   [TBOGameSetting sharedGameSetting].soundON=!([TBOGameSetting sharedGameSetting].soundON);
    [self updateSoundButtonUI];
    
}
- (IBAction)rank:(id)sender {
    [self performSegueWithIdentifier:@"showLeaderBoard" sender:nil];
}

- (IBAction)showHistories:(id)sender {
    
    id detailVCNavigator=self.splitViewController.viewControllers[1];
    if ([detailVCNavigator isKindOfClass:[UINavigationController class]]) {
        [((UINavigationController *)detailVCNavigator).viewControllers[0] performSegueWithIdentifier:@"Show History" sender:nil];
        return;
    }
    [self performSegueWithIdentifier:@"Show History" sender:nil];

}
-(IBAction)showHowToPlay:(UIButton *)button{

    
    id detailVCNavigator=self.splitViewController.viewControllers[1];
    if ([detailVCNavigator isKindOfClass:[UINavigationController class]]) {
        [((UINavigationController *)detailVCNavigator).viewControllers[0] performSegueWithIdentifier:@"How To Play" sender:nil];
        return;
    }
    [self performSegueWithIdentifier:@"How To Play" sender:nil];
}

- (IBAction)startNewGame:(id)sender {
    
    if (self.gameChosingPad) {
        return;
    }
    self.gameChosingPad=[[[NSBundle mainBundle] loadNibNamed:@"GameChosingView"
                                                                    owner:nil
                                                                  options:nil] lastObject];
    [self.view addSubview:self.gameChosingPad];
    [UIView makeView:self.gameChosingPad centerInView:self.view withSize:self.gameChosingPad.bounds.size];

}


- (IBAction)pleasecomment:(id)sender {

    NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",APP_ID];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];

}
-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)setShowHistory:(UIButton *)showHistory{
    _showHistory=showHistory;
}
@end
