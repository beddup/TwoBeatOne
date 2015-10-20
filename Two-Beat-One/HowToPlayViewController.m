//
//  HowToPlayViewController.m
//  Two Beat One
//
//  Created by Amay on 5/9/15.
//  Copyright (c) 2015 Beddup. All rights reserved.
//

#import "HowToPlayViewController.h"
#import "defines.h"
#import "GameChosingView.h"
#import "TBOGameSetting.h"
#import "UIView+CenterConstraint.h"
#import "TBOGameGCCommunicator.h"

#define How_To_Play_New_Game NSLocalizedStringFromTable(@"How_To_Play_New_Game", @"HTP-VC", nil)
#define HTP_Image_Name NSLocalizedStringFromTable(@"HTP_Image_Name", @"HTP-VC", nil)

@interface HowToPlayViewController ()<UIScrollViewDelegate>

@property (weak, nonatomic)  UIScrollView *HTPScrollView;
@property (weak, nonatomic)  UIPageControl *pageControll;
@property (weak, nonatomic) UIButton *closeButton;

@end

@implementation HowToPlayViewController

#pragma mark - view controller life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"bkg"]];

    [self setupScrollView];
    [self setupPageControll];
    [self setupCloseButton];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [self updateSubviewsFrameInSrollView];
}

-(void)updateSubviewsFrameInSrollView{

    CGFloat width=CGRectGetWidth(self.view.frame);
    CGFloat height=CGRectGetHeight(self.view.frame);

    self.HTPScrollView.contentSize=CGSizeMake(6*width, height);
    self.preferredContentSize=CGSizeMake(500, 600);

    self.HTPScrollView.frame=self.view.bounds;

    [self.HTPScrollView viewWithTag:1].frame=CGRectMake(0, 0, width, height);
    [self.HTPScrollView viewWithTag:2].frame=CGRectMake(width, 0, width, height);;
    [self.HTPScrollView viewWithTag:3].frame=CGRectMake(width*2, 0, width, height);;
    [self.HTPScrollView viewWithTag:4].frame=CGRectMake(width*3, 0, width, height);;
    [self.HTPScrollView viewWithTag:5].frame=CGRectMake(width*4, 0, width, height);;
    [self.HTPScrollView viewWithTag:6].frame=CGRectMake(width*5, 0, width, height);;

    self.pageControll.center=CGPointMake(width/2, height-20);
    self.closeButton.center=CGPointMake(width-25, 25);

}

#pragma mark - add content to scroll view
-(void)setupScrollView{

    UIScrollView *scrollView=[[UIScrollView alloc]init];
    scrollView.backgroundColor=[UIColor clearColor];
    scrollView.delegate=self;
    self.HTPScrollView=scrollView;
    self.HTPScrollView.pagingEnabled=YES;

    [self addHTPtoScrollView:1];
    [self addHTPtoScrollView:2];

    [self.view addSubview:scrollView];
}
-(void)addHTPtoScrollView:(NSInteger)step{
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        NSString *imageName=[NSString stringWithFormat:@"HTP_%ld_%@",(long)step,HTP_Image_Name];
        UIImage *image=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle]
                                                         pathForResource:imageName
                                                         ofType:@"png"]];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImageView *imageView=[[UIImageView alloc]initWithImage:image];
            imageView.tag=step;
            imageView.contentMode=UIViewContentModeScaleAspectFit;
            [self.HTPScrollView addSubview:imageView];
        });
    });
}
-(void)setupPageControll{
    UIPageControl *pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
    [self.view addSubview:pageControl];
    self.pageControll=pageControl;
    self.pageControll.numberOfPages=6;
    self.pageControll.currentPage=0;
}
-(void)setupCloseButton{
    UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [button setBackgroundImage:[UIImage imageNamed:@"Close_Button_Image"]
                      forState:UIControlStateNormal];
    [self.view addSubview:button];
    self.closeButton=button;
    [button addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma  mark - action
- (void)close:(UIButton *)button {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
-(BOOL)prefersStatusBarHidden{
    return YES;
}
#pragma scroll view delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSInteger page=(NSInteger)((scrollView.contentOffset.x+self
                          .view.frame.size.width/2)/self.view.frame.size.width);
    self.pageControll.currentPage=page;

    NSInteger currentStep=page+1;
    if (![self.HTPScrollView viewWithTag:currentStep+1]) {
        [self addHTPtoScrollView:currentStep+1];
    }
    if (![self.HTPScrollView viewWithTag:currentStep-1]) {
        [self addHTPtoScrollView:currentStep-1];
    }

}

- (void)didReceiveMemoryWarning {
    NSInteger currentDisplayStep=self.pageControll.currentPage+1;
    for (NSInteger i=1; i<7; i++) {
        if (labs(currentDisplayStep-i)>1) {
            [[self.HTPScrollView viewWithTag:i] removeFromSuperview];
        }
    }
}
@end
