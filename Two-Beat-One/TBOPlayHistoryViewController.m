//
//  TBOPlayHistoryViewController.m
//  Two Beat One
//
//  Created by Amay on 5/24/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "TBOPlayHistoryViewController.h"
#import "ChessBoard.h"
#import "TBOHistoryPlayer.h"
@interface TBOPlayHistoryViewController ()

@property (weak, nonatomic) IBOutlet ChessBoard *chessBoard;
@property (weak, nonatomic) IBOutlet UIButton *previousStepButton;
@property (weak, nonatomic) IBOutlet UIButton *nextStepButton;
@property(strong,nonatomic)TBOHistoryPlayer *historyPlayer;


@end

@implementation TBOPlayHistoryViewController
#pragma mark - vc life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setButtonBKGImage];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.historyPlayer.chessBoard=self.chessBoard;
}

-(void)setButtonBKGImage{
    // set previousStepButton button BGK image
    NSString *previousStepButtonBKGImagePath=[[NSBundle mainBundle]pathForResource:@"Record_PreviousStep"
                                                                         ofType:@"png"];
    [self.previousStepButton setBackgroundImage:[UIImage imageWithContentsOfFile:previousStepButtonBKGImagePath]
                                    forState:UIControlStateNormal];

    // set nextStepButton button BGK image
    NSString *nextStepButtonButtonBKGImagePath=[[NSBundle mainBundle]pathForResource:@"Record_NextStep"
                                                                            ofType:@"png"];
    [self.nextStepButton setBackgroundImage:[UIImage imageWithContentsOfFile:nextStepButtonButtonBKGImagePath]
                                       forState:UIControlStateNormal];
}

#pragma mark - properties
-(TBOHistoryPlayer *)historyPlayer{
    if (!_historyPlayer) {
        _historyPlayer=[[TBOHistoryPlayer alloc]init];
        _historyPlayer.history=self.history;
    }
    return _historyPlayer;
}
-(void)setHistory:(NSDictionary *)history{
    _history=history;
    self.historyPlayer.history=history;
}

#pragma mark -action
-(IBAction)next:(UIButton *)button{
    [self.historyPlayer nextStep];
}
-(IBAction)previous:(UIButton *)button{
    [self.historyPlayer previousStep];
}

- (IBAction)close:(UIButton *)button {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.historyPlayer=nil;
}
@end
