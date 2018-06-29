//
//  MainViewController.m
//  Yap_Hangul
//
//  Created by doyoung gwak on 2014. 10. 10..
//  Copyright (c) 2014년 doyoung gwak. All rights reserved.
//


#import "UIView+EasingFunctions.h"
#import "easing.h"

#import "RoationController.h"


#import "MainViewController.h"

#import "TimeEngine.h"
#import "HangulConverter.h"


#import "FWLabelView.h"
#import "AMLabelView.h"
#import "UIEffectLabel.h"


#import "MainTouchView.h"
#import "MenuView.h"


#define ROTATION_DELAY_TIME .3f

#define TAG_ACTION_MOVETO 112

//TODO: property로 변환
@interface MainViewController () <TimeChangeDelegate, RotateDelegate> {
    CGSize winSize ;
    
    // 회전하지 않는 배경 노드
    UIImageView *portraitBackgroundImageView;
    UIImageView *landscapeBackgroundImageView;
    
    // 회전하는 배경 노드
    UIView *rotateView;
    float defaultAngle;
    
    // rotateView위에 올라가있는 레이블 (:UIView)
    // 상단에 길게 늘어져있는 "이 천 십 팔 년 시 월 이 십 사 일 화 요 일" 이런식으로 보여지는 레이블
    FWLabelView *yeardateLabelView;
    
    // 실제 화면 상단에 나타나는 메인 한글 시계 레이블
    // 시간 레이블
    AMLabelView *hourLabelView;
    // 분 레이블
    AMLabelView *minuteLabelView;
    // 초 레이블
    AMLabelView *secondLabelView;
    
    // 오전오후 레이블
    AMLabelView *ampmLabelView;
    
    
    // 우측 하단에 연하게 한글을 펼쳐서 보여주는 레이블들
    // 한글이 펼쳐진 오전오후 레이블
    UIEffectLabel *ampmEffectLabel;
    // 한글이 펼쳐진 요일 레이블
    UIEffectLabel *weekDayEffectLabel;
    
    // 한글이 펼쳐진 달 레이블
    UIEffectLabel *monthEffectLabel;
    // 한글이 펼쳐진 년도 레이블
    UIEffectLabel *yearEffectLabel;
    
    BOOL nowRotateAnimate;
    
    BOOL timeLabelInit;
    
    HangulConverter *converter ;
    
    MainTouchView *mainTouchView;
    MenuView *menuView;
}

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    // Do any additional setup after loading the view, typically from a nib.
    
    timeLabelInit = NO;
    nowRotateAnimate = NO;
    
    converter = [[HangulConverter alloc] init];
    [TimeEngine shared].changeType = tType_second;
    [TimeEngine shared].afterInterval = .1f;
    [TimeEngine shared].delegate = self;
    [[TimeEngine shared] MAKE_TIMER];
    
    
    
    [self setWinsize];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self makeBackgroundImageView];

    rotateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:rotateView];
    rotateView.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:1.f green:.7f blue:.7f alpha:1.f];
    
    
    
    
    mainTouchView = [[MainTouchView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    mainTouchView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:mainTouchView];
    mainTouchView.mainViewController = self;
    mainTouchView.winSize = winSize;
    
    [OptionController shared].mainViewController = self;
    
    NSLog(@"[[RoationController shared] bigHeight]: %f", [[RoationController shared] bigHeight]);
}

- (void)setWinsize {
    
    
    winSize = CGSizeMake((self.view.frame.size.width>self.view.frame.size.height)?self.view.frame.size.width:self.view.frame.size.height, (self.view.frame.size.height<self.view.frame.size.width)?self.view.frame.size.height:self.view.frame.size.width);
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (!(orientation==UIInterfaceOrientationLandscapeLeft ||
          orientation==UIInterfaceOrientationLandscapeRight)) {
        winSize = CGSizeMake(winSize.height, winSize.width);
    }
    
    if (@available(iOS 11.0, *)) {
        winSize = CGSizeMake(winSize.width, winSize.height - self.topLayoutGuide.length - self.bottomLayoutGuide.length);
    }
}

- (void)makeBackgroundImageView {
    NSString *portraitBackgroundImageName = nil;
    NSString *landscapeBackgroundImageName = nil;
    
    if (ISIPAD) {
        portraitBackgroundImageName = @"BG-ipad-portrait";
        landscapeBackgroundImageName = @"BG-ipad-landscape";
    } else {
        portraitBackgroundImageName = @"BG-iphone";
        landscapeBackgroundImageName = @"BG-iphone";
    }
    
    UIImage *portraitBackgroundImage = [UIImage imageNamed:portraitBackgroundImageName];
    portraitBackgroundImageView = [[UIImageView alloc] initWithImage:portraitBackgroundImage];
    portraitBackgroundImageView.frame = CGRectMake(0, 0, winSize.width, winSize.height);
    [self.view addSubview:portraitBackgroundImageView];
    
    UIImage *landscapeBackGroundImage = [UIImage imageNamed:landscapeBackgroundImageName];
    landscapeBackgroundImageView = [[UIImageView alloc] initWithImage:landscapeBackGroundImage];
    landscapeBackgroundImageView.frame = CGRectMake(0, 0, winSize.height, winSize.width);
    [self.view addSubview:landscapeBackgroundImageView];
    
    
    landscapeBackgroundImageView.alpha = [self isHorizontal] ? 1 : 0;
    portraitBackgroundImageView.alpha = [self isHorizontal] ? 0 : 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






- (BOOL)isHorizontal {
    return [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeRight ||
    [[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationLandscapeLeft;
}

// [[RoationController shared] bigHeight]:
// iPhone8           667.000000, 0.562219
// iPhone5           568.000000, 0.563380
// iPhoneX           812.000000, 0.461823
// iPad Pro(9.7inch) 1024.000000
#define ISIPHONEX ([[RoationController shared] whRate] < 0.55)


#define BOTTOM_LABEL_Y ((ISIPAD)?(56.f):((winSize.width>winSize.height)?(ISIPHONEX?-36.5f:16.f):(56.f)))
#define BOTTOM_LABEL_X ((ISIPAD)?(44.f):((winSize.width>winSize.height)?(ISIPHONEX?44.f:10.f):(14.f)))
#define BOGGOM_LABEL_GAP_Y 17.f
#define BOTTOM_LABEL_GAP2_Y 36.f
- (CGPoint) getYearLabelPoint {
    return CGPointMake(winSize.width-BOTTOM_LABEL_X-[yearEffectLabel getWidth], winSize.height-BOTTOM_LABEL_Y);
}
- (CGPoint) getMonthLabelPointWithYearLabelPoint:(CGPoint)yearLabelPoint {
    return CGPointMake(winSize.width-BOTTOM_LABEL_X-[monthEffectLabel getWidth],yearLabelPoint.y-BOGGOM_LABEL_GAP_Y);
}
- (CGPoint) getWeekLabelPointWithMonthDayLabelPoint:(CGPoint)dayLabelPoint {
    return CGPointMake(winSize.width-BOTTOM_LABEL_X-[weekDayEffectLabel getWidth], dayLabelPoint.y-BOTTOM_LABEL_GAP2_Y);
}
- (CGPoint) getAMPMLabelPointWithWeekLabelPoint:(CGPoint)weekLabelPoint {
    return CGPointMake(winSize.width-BOTTOM_LABEL_X-[ampmEffectLabel getWidth], weekLabelPoint.y-BOGGOM_LABEL_GAP_Y);
}



#define TOP_YEAR_GAP ((ISIPAD)?(40.f):(20.f))
#define TOP_YEAR_FONTSIZE ((ISIPAD)?(17):(15))
#define YEAR_POS_Y ([[RoationController shared] isLandscape]?YEAR_POS_Y_L:YEAR_POS_Y_P)
#define YEAR_POS_Y_P ((ISIPAD)?(26.f):(ISIPHONEX?48.f:18.f))
#define YEAR_POS_Y_L ((ISIPAD)?(26.f):(18.f))

#define HOUR_FONTSIZE ((ISIPAD)?(205):(86))
#define MINUTE_FONTSIZE ((ISIPAD)?(129):(61))
#define SECOND_FONTSIZE ((ISIPAD)?(30):(20))
#define AMPM_FONTSIZE ((ISIPAD)?(75):(30))


#define SCREENRATE ((ISIPAD)?(1):(ISIPHONEX ? 1.2 : [[RoationController shared] bigHeight]/568.f))

#define MINUTE_PORTRAIT_EXTRA_GAP ((ISIPAD)?(17):(-2))
#define SECOND_PORTRAIT_EXTRA_GAP ((ISIPAD)?(17):(3))

#define PORTRAIT_STANDARD_X_GAP 10.f
#define SECOND_PORTRAIT_STANDARD_Y_GAP ((ISIPAD)?(4.f):(2.f))
#define LANDSCAPE_STANDARD_X_GAP 64.f
#define LANDSCAPE_STANDARD_MIN_X_GAP ((ISIPAD)?(198.f):(200.f))
#define SECOND_LANDSCAPE_X ((ISIPAD)?(0.f):(3.f))
#define LANDSCAPE_STANDARD_MIN_Y_GAP ((ISIPAD)?(7.f):(3.f))

#define AMPM_EXTRAGAP_Y_RATE .133333f



#pragma mark - Time Engine Delegate
- (void) timeWillChange:(NSDate *)date
             changeType:(enum TimeChangeType)type
          afterInterval:(float)afterT { /* ... */ }


- (void) timeChanged:(NSDate *)date
          changeType:(enum TimeChangeType)type {
    
    // 최상단에 년, 월, 일, 요일 펼쳐져있는 레이블 세팅
    if (![OptionController shared].dateOff) {
        if (!yeardateLabelView) {
            float width = (![[RoationController shared] isLandscape])?(winSize.width):(winSize.height);
            yeardateLabelView = [[FWLabelView alloc] initWithFontName:FONT_NORMAL
                                                             fontSize:TOP_YEAR_FONTSIZE
                                                                width:width-TOP_YEAR_GAP*2.f];
            yeardateLabelView.frame = CGRectMake(TOP_YEAR_GAP, YEAR_POS_Y,
                                                 yeardateLabelView.frame.size.width,
                                                 yeardateLabelView.frame.size.height);
            [rotateView addSubview:yeardateLabelView];
        }
        
        [self setTopLabelWithDate:date changeType:type label:yeardateLabelView];
    }
    
    
    // 이놈의 전역변수같은 지역변수 때문에 고생하네...
    float hourLabelX = 0.f;
    float hourLabelW = 0.f;
    float hourLabelY = 0.f;
    
        
    if (![[RoationController shared] isLandscape]) {
        
        // 시간 레이블 설정(없을시 만들기)
        if (!hourLabelView) {
            hourLabelView = [[AMLabelView alloc] initWithFontName:FONT_EXTRABOLD fontSize:HOUR_FONTSIZE*SCREENRATE];
            
            [self setHourTextAndLabelFrameWithTime:date
                                         hourLabel:hourLabelView
                                          animated:false];
            
            // 시간 레이블 너비, 좌표 준비
            hourLabelW = hourLabelView.frame.size.width;
            hourLabelX = winSize.width-PORTRAIT_STANDARD_X_GAP-hourLabelW;
            CGPoint targetPoint = CGPointMake(hourLabelX ,
                                              (YEAR_POS_Y*2)+(hourLabelView.frame.size.height/2.f)*1.37f);
            hourLabelY = targetPoint.y+hourLabelView.frame.size.height/2.f;
            
            // 시간 레이블 rotateView 위에 올리기
            [rotateView addSubview:hourLabelView];
        } else {
            if (type&tType_hour) {
                [self setHourTextAndLabelFrameWithTime:date
                                             hourLabel:hourLabelView
                                              animated:true];
                
                // 시간 레이블 너비, 좌표 준비
                hourLabelW = hourLabelView.frame.size.width;
                hourLabelX = winSize.width-PORTRAIT_STANDARD_X_GAP-hourLabelW;
                CGPoint targetPoint = CGPointMake(hourLabelX ,
                                                  (YEAR_POS_Y*2)+(hourLabelView.frame.size.height/2.f)*1.37f);
                hourLabelY = targetPoint.y+hourLabelView.frame.size.height/2.f;
            } else {
                hourLabelX = hourLabelView.frame.origin.x;
                hourLabelY = hourLabelView.frame.origin.y+hourLabelView.frame.size.height/2.f;
                hourLabelW = hourLabelView.frame.size.width;
            }
            
        } // end of if (!hourLabelView) {
        
        
        // 오전오후 레이블 설정(없을시 만들기)
        if (![OptionController shared].ampmOff) {
            if (!ampmLabelView) {
                
                ampmLabelView = [[AMLabelView alloc] initWithFontName:FONT_BOLD
                                                             fontSize:AMPM_FONTSIZE*SCREENRATE];
                [rotateView addSubview:ampmLabelView];
                
                [self setAMPMTextAndLabelFrameWithDate:date
                                        hourLabelPoint:CGPointMake(hourLabelX, hourLabelY)
                                              animated:NO];
            } else {
                if (type&tType_hour) {
                    
                    [self setAMPMTextAndLabelFrameWithDate:date
                                            hourLabelPoint:CGPointMake(hourLabelX, hourLabelY)
                                                  animated:YES];
                    
                } else {
                    
                }
            }
        }
        
        
    } else {
        
        
        BOOL hourInit = NO;
        if (!hourLabelView) {
            hourInit=  YES;
            hourLabelView = [[AMLabelView alloc] initWithFontName:FONT_EXTRABOLD fontSize:HOUR_FONTSIZE*SCREENRATE];
            
            
            NSString *hourText = nil;
            if (![OptionController shared].ampmOff) {
                if (date.hour%12==0) {
                    hourText = [NSString stringWithFormat:@"%@시", [converter hangulWithTime:12 timeType:tcType_hour]];
                } else {
                    hourText = [NSString stringWithFormat:@"%@시", [converter hangulWithTime:date.hour%12 timeType:tcType_hour]];
                }
            } else {
                hourText = [NSString stringWithFormat:@"%@시", [converter hangulWithTime:date.hour%24 timeType:tcType_hour]];
            }
            
            hourLabelW = [hourLabelView changeText:hourText];
            
            CGPoint targetPoint = CGPointMake(0.f,
                                              (YEAR_POS_Y*2)+(hourLabelView.frame.size.height/2.f)*1.37f);
            hourLabelY = targetPoint.y+hourLabelView.frame.size.height/2.f;
            hourLabelView.frame = CGRectMake(targetPoint.x, targetPoint.y,
                                             hourLabelView.frame.size.width,
                                             hourLabelView.frame.size.height);
            [rotateView addSubview:hourLabelView];
        } else {
            NSString *hourText = nil;
            if (![OptionController shared].ampmOff) {
                if (date.hour%12==0) {
                    hourText = [NSString stringWithFormat:@"%@시", [converter hangulWithTime:12 timeType:tcType_hour]];
                } else {
                    hourText = [NSString stringWithFormat:@"%@시", [converter hangulWithTime:date.hour%12 timeType:tcType_hour]];
                }
            } else {
                hourText = [NSString stringWithFormat:@"%@시", [converter hangulWithTime:date.hour%24 timeType:tcType_hour]];
            }
            hourLabelW = [hourLabelView changeText:hourText];
            hourLabelY = hourLabelView.frame.origin.y+hourLabelView.frame.size.height/2.f;
        }
        float ampmW = 0.f;
        float ampmX = LANDSCAPE_STANDARD_X_GAP;
        
        if (![OptionController shared].ampmOff) {
            if (!ampmLabelView) {
                ampmLabelView = [[AMLabelView alloc] initWithFontName:FONT_BOLD fontSize:AMPM_FONTSIZE*SCREENRATE];
                [rotateView addSubview:ampmLabelView];
                if (date.hour<12) {
                    ampmW = [ampmLabelView changeText:@"오전"];
                } else {
                    ampmW = [ampmLabelView changeText:@"오후"];
                }
                CGPoint targetPoint = CGPointMake(ampmX,
                                                  hourLabelY-ampmLabelView.frame.size.height/2.f-ampmLabelView.frame.size.height*AMPM_EXTRAGAP_Y_RATE);
                ampmLabelView.frame = CGRectMake(targetPoint.x, targetPoint.y,
                                                 ampmLabelView.frame.size.width, ampmLabelView.frame.size.height);
            } else {
                if (type&tType_hour) {
                    if (date.hour<12) {
                        ampmW = [ampmLabelView changeText:@"오전"];
                    } else {
                        ampmW = [ampmLabelView changeText:@"오후"];
                    }
                    CGPoint targetPoint = CGPointMake(ampmX,
                                                      hourLabelY-ampmLabelView.frame.size.height/2.f-ampmLabelView.frame.size.height*AMPM_EXTRAGAP_Y_RATE);
                    [UIView animateWithDuration:ANI_TEXT_DELAY animations:^{
                        [ampmLabelView setEasingFunction:ExponentialEaseOut forKeyPath:@"center"];
                        ampmLabelView.frame = CGRectMake(targetPoint.x, targetPoint.y,
                                                         ampmLabelView.frame.size.width,
                                                         ampmLabelView.frame.size.height);
                    } completion:^(BOOL finished) {
                        [ampmLabelView removeEasingFunctionForKeyPath:@"center"];
                    }];
                } else {
                    ampmW = ampmLabelView.frame.size.width;
                }
            }
        }
        
        
        
        if (hourInit) {
            CGPoint targetPoint = CGPointMake(ampmX+ampmW-0.f, (YEAR_POS_Y*2)+(hourLabelView.frame.size.height/2.f)*1.37f);
            hourLabelY = targetPoint.y+hourLabelView.frame.size.height/2.f;
            hourLabelView.frame = CGRectMake(targetPoint.x, targetPoint.y,
                                             hourLabelView.frame.size.width, hourLabelView.frame.size.height);
        } else {
            CGPoint targetPoint = CGPointMake(ampmX+ampmW-0.f, (YEAR_POS_Y*2)+(hourLabelView.frame.size.height/2.f)*1.37f);
            hourLabelY = targetPoint.y+hourLabelView.frame.size.height/2.f;
            [UIView animateWithDuration:ANI_TEXT_DELAY animations:^{
                [hourLabelView setEasingFunction:ExponentialEaseOut forKeyPath:@"center"];
                hourLabelView.frame = CGRectMake(targetPoint.x, targetPoint.y,
                                                 hourLabelView.frame.size.width, hourLabelView.frame.size.height);
            } completion:^(BOOL finished) {
                [hourLabelView removeEasingFunctionForKeyPath:@"center"];
            }];
        }
        
        
    }
        
    
    
    
    
    
    
        
    // Minute & Second
    float minuteW = 0.f;
    float secondW = 0.f;
    float minuteY = 0.f;
    
    
    if (![[RoationController shared] isLandscape]) {
        if (!minuteLabelView) {
            minuteLabelView = [[AMLabelView alloc] initWithFontName:FONT_LIGHT fontSize:MINUTE_FONTSIZE*SCREENRATE];
            [rotateView addSubview:minuteLabelView];
            minuteW = [minuteLabelView changeText:[NSString stringWithFormat:@"%@분", [converter hangulWithTime:date.minute timeType:tcType_minute]]];
            CGPoint targetPoint = CGPointMake(winSize.width-PORTRAIT_STANDARD_X_GAP-minuteW -MINUTE_PORTRAIT_EXTRA_GAP,
                                              hourLabelY+(minuteLabelView.frame.size.height/2.f)*1.07f);
            minuteY = targetPoint.y+minuteLabelView.frame.size.height/2.f;
            minuteLabelView.frame = CGRectMake(targetPoint.x, targetPoint.y,
                                               minuteLabelView.frame.size.width, minuteLabelView.frame.size.height);
        } else {
            if (type&tType_minute) {
                minuteW = [minuteLabelView changeText:[NSString stringWithFormat:@"%@분", [converter hangulWithTime:date.minute timeType:tcType_minute]]];
                CGPoint targetPoint = CGPointMake(winSize.width-PORTRAIT_STANDARD_X_GAP-minuteW -MINUTE_PORTRAIT_EXTRA_GAP,
                                                  hourLabelY+(minuteLabelView.frame.size.height/2.f)*1.07f);
                minuteY = targetPoint.y+minuteLabelView.frame.size.height/2.f;

                [UIView animateWithDuration:ANI_TEXT_DELAY animations:^{
                    [minuteLabelView setEasingFunction:ExponentialEaseOut forKeyPath:@"center"];
                    minuteLabelView.frame = CGRectMake(targetPoint.x, targetPoint.y,
                                                       minuteLabelView.frame.size.width,
                                                       minuteLabelView.frame.size.height);
                } completion:^(BOOL finished) {
                    [minuteLabelView removeEasingFunctionForKeyPath:@"center"];
                }];
            } else {
                minuteY = minuteLabelView.frame.origin.y+minuteLabelView.frame.size.height/2.f;
            }
        }
        
        
        
        if (![OptionController shared].secondOff) {
            if (!secondLabelView) {
                secondLabelView = [[AMLabelView alloc] initWithFontName:FONT_NORMAL fontSize:SECOND_FONTSIZE*SCREENRATE];
                [secondLabelView setLabelCount:4];
                [rotateView addSubview:secondLabelView];
                
                secondW = [secondLabelView changeText:[NSString stringWithFormat:@"%@초", [converter hangulWithTime:date.second timeType:tcType_minute]]];
                CGPoint targetPoint = CGPointMake(winSize.width-PORTRAIT_STANDARD_X_GAP-secondW-SECOND_PORTRAIT_EXTRA_GAP,
                                                  minuteY+(secondLabelView.frame.size.height)-SECOND_PORTRAIT_STANDARD_Y_GAP);
                secondLabelView.frame = CGRectMake(targetPoint.x, targetPoint.y,
                                                   secondLabelView.frame.size.width,
                                                   secondLabelView.frame.size.height);
            } else {
                if (type&tType_second) {
                    secondW = [secondLabelView changeText:[NSString stringWithFormat:@"%@초", [converter hangulWithTime:date.second timeType:tcType_minute]]];
                    CGPoint targetPoint = CGPointMake(winSize.width-PORTRAIT_STANDARD_X_GAP-secondW-SECOND_PORTRAIT_EXTRA_GAP,
                                                      minuteY+(secondLabelView.frame.size.height)-SECOND_PORTRAIT_STANDARD_Y_GAP);
                    
                    [UIView animateWithDuration:ANI_TEXT_DELAY animations:^{
                        [secondLabelView setEasingFunction:ExponentialEaseOut forKeyPath:@"center"];
                        secondLabelView.frame = CGRectMake(targetPoint.x, targetPoint.y,
                                                           secondLabelView.frame.size.width,
                                                           secondLabelView.frame.size.height);
                    } completion:^(BOOL finished) {
                        [secondLabelView removeEasingFunctionForKeyPath:@"center"];
                    }];
                }
            }
            
        }
    } else {
        if (!minuteLabelView) {
            minuteLabelView = [[AMLabelView alloc] initWithFontName:FONT_LIGHT fontSize:MINUTE_FONTSIZE*SCREENRATE];
            [rotateView addSubview:minuteLabelView];
            minuteW = [minuteLabelView changeText:[NSString stringWithFormat:@"%@분", [converter hangulWithTime:date.minute timeType:tcType_minute]]];
            CGPoint targetPoint = CGPointMake(winSize.width-LANDSCAPE_STANDARD_MIN_X_GAP-minuteW ,
                                              hourLabelY+(minuteLabelView.frame.size.height/2.f)*1.37f);
            minuteY = targetPoint.y+minuteLabelView.frame.size.height/2.f;
            minuteLabelView.frame = CGRectMake(targetPoint.x, targetPoint.y,
                                               minuteLabelView.frame.size.width,
                                               minuteLabelView.frame.size.height);
        } else {
            if (type&tType_minute) {
                minuteW = [minuteLabelView changeText:[NSString stringWithFormat:@"%@분", [converter hangulWithTime:date.minute timeType:tcType_minute]]];
                CGPoint targetPoint = CGPointMake(winSize.width-LANDSCAPE_STANDARD_MIN_X_GAP-minuteW ,
                                                  hourLabelY+(minuteLabelView.frame.size.height/2.f)*1.37f);
                minuteY = targetPoint.y+minuteLabelView.frame.size.height/2.f;
                
                [UIView animateWithDuration:ANI_TEXT_DELAY animations:^{
                    [minuteLabelView setEasingFunction:ExponentialEaseOut forKeyPath:@"center"];
                    minuteLabelView.frame = CGRectMake(targetPoint.x, targetPoint.y,
                                                       minuteLabelView.frame.size.width,
                                                       minuteLabelView.frame.size.height);
                } completion:^(BOOL finished) {
                    [minuteLabelView removeEasingFunctionForKeyPath:@"center"];
                }];
            } else {
                minuteY = minuteLabelView.frame.origin.y+minuteLabelView.frame.size.height/2.f;
            }
        }
        
        
        
        if (![OptionController shared].secondOff) {
            if (!secondLabelView) {
                secondLabelView = [[AMLabelView alloc] initWithFontName:FONT_NORMAL fontSize:SECOND_FONTSIZE*SCREENRATE];
                [secondLabelView setLabelCount:4];
                [rotateView addSubview:secondLabelView];
                
                secondW = [secondLabelView changeText:[NSString stringWithFormat:@"%@초", [converter hangulWithTime:date.second timeType:tcType_minute]]];
                CGPoint targetPoint = CGPointMake(winSize.width-LANDSCAPE_STANDARD_MIN_X_GAP+SECOND_LANDSCAPE_X,
                                                  minuteY-(secondLabelView.frame.size.height/2.f)-LANDSCAPE_STANDARD_MIN_Y_GAP);
                secondLabelView.frame = CGRectMake(targetPoint.x, targetPoint.y,
                                                   secondLabelView.frame.size.width,
                                                   secondLabelView.frame.size.height);
            } else {
                if (type&tType_second) {
                    secondW = [secondLabelView changeText:[NSString stringWithFormat:@"%@초", [converter hangulWithTime:date.second timeType:tcType_minute]]];
                    CGPoint targetPoint = CGPointMake(winSize.width-LANDSCAPE_STANDARD_MIN_X_GAP+SECOND_LANDSCAPE_X,
                                                      minuteY-(secondLabelView.frame.size.height/2.f)-LANDSCAPE_STANDARD_MIN_Y_GAP);
                    
                    [UIView animateWithDuration:ANI_TEXT_DELAY animations:^{
                        [secondLabelView setEasingFunction:ExponentialEaseOut forKeyPath:@"center"];
                        secondLabelView.frame = CGRectMake(targetPoint.x, targetPoint.y,
                                                           secondLabelView.frame.size.width,
                                                           secondLabelView.frame.size.height);
                    } completion:^(BOOL finished) {
                        [secondLabelView removeEasingFunctionForKeyPath:@"center"];
                    }];
                }
            }
        } // end of if (![OptionController shared].secondOff) {
        
        
    }
    
    
    
    
    
    
    
    
    if (![RoationController shared].delegate) [RoationController shared].delegate = self;
    
    if (!timeLabelInit) {
        timeLabelInit = YES;
        
        
        
        
        CGPoint targetPoint;
        NSString *yearText = [NSString stringWithFormat:@"%@년", [converter hangulWithTime:date.year timeType:tcType_minute]] ;
        yearEffectLabel = [[UIEffectLabel alloc] initWithString:[converter linearHangul:yearText] fontName:FONT_NORMAL fontSize:12.f init:NO Opacity:MAX_OPACITY];
        targetPoint = [self getYearLabelPoint];
        yearEffectLabel.frame = CGRectMake(targetPoint.x, targetPoint.y,
                                           yearEffectLabel.frame.size.width,
                                           yearEffectLabel.frame.size.height);
        [rotateView addSubview:yearEffectLabel];
        
        
        NSString *monthdayText = [NSString stringWithFormat:@"%@월%@일", [converter hangulWithTime:date.month timeType:tcType_month], [converter hangulWithTime:date.day timeType:tcType_minute]] ;
        monthEffectLabel = [[UIEffectLabel alloc] initWithString:[converter linearHangul:monthdayText] fontName:FONT_NORMAL fontSize:12.f init:NO Opacity:MAX_OPACITY];
        targetPoint = [self getMonthLabelPointWithYearLabelPoint:yearEffectLabel.frame.origin];
        monthEffectLabel.frame = CGRectMake(targetPoint.x, targetPoint.y,
                                            monthEffectLabel.frame.size.width,
                                            monthEffectLabel.frame.size.height);
        [rotateView addSubview:monthEffectLabel];
        
        
        NSString *weekText = [converter weekHanhulWithIndex:date.weekday];
        weekDayEffectLabel = [[UIEffectLabel alloc] initWithString:[converter linearHangul:weekText] fontName:FONT_NORMAL fontSize:12.f init:NO Opacity:MAX_OPACITY];
        targetPoint = [self getWeekLabelPointWithMonthDayLabelPoint:monthEffectLabel.frame.origin];
        weekDayEffectLabel.frame = CGRectMake(targetPoint.x, targetPoint.y,
                                              weekDayEffectLabel.frame.size.width,
                                              weekDayEffectLabel.frame.size.height);
        [rotateView addSubview:weekDayEffectLabel];
        
        
        NSString *ampmText = @"오전";
        if (date.hour>=12) ampmText = @"오후";
        ampmEffectLabel = [[UIEffectLabel alloc] initWithString:[converter linearHangul:ampmText] fontName:FONT_NORMAL fontSize:12.f init:NO Opacity:MAX_OPACITY];
        targetPoint = [self getAMPMLabelPointWithWeekLabelPoint:weekDayEffectLabel.frame.origin];
        ampmEffectLabel.frame = CGRectMake(targetPoint.x, targetPoint.y,
                                           ampmLabelView.frame.size.width,
                                           ampmLabelView.frame.size.height);
        [rotateView addSubview:ampmEffectLabel];
        
        
        
        
        return;
    }
    
    CGPoint targetPoint;
    if (type&tType_year) {
        if (yearEffectLabel) {
            [yearEffectLabel removeAnimateWithIsSearch:YES];
        }
        NSString *yearText = [NSString stringWithFormat:@"%@년", [converter hangulWithTime:date.year timeType:tcType_minute]] ;
        yearEffectLabel = [[UIEffectLabel alloc] initWithString:[converter linearHangul:yearText] fontName:FONT_NORMAL fontSize:12.f init:NO Opacity:MAX_OPACITY];
        targetPoint = [self getYearLabelPoint];
        yearEffectLabel.frame = CGRectMake(targetPoint.x, targetPoint.y,
                                           yearEffectLabel.frame.size.width,
                                           yearEffectLabel.frame.size.height);
        [rotateView addSubview:yearEffectLabel];
    }
    if (type&tType_month) {
        if (monthEffectLabel) {
            [monthEffectLabel removeAnimateWithIsSearch:YES];
        }
        NSString *monthdayText = [NSString stringWithFormat:@"%@월%@일", [converter hangulWithTime:date.month timeType:tcType_month], [converter hangulWithTime:date.day timeType:tcType_minute]] ;
        monthEffectLabel = [[UIEffectLabel alloc] initWithString:[converter linearHangul:monthdayText] fontName:FONT_NORMAL fontSize:12.f init:NO Opacity:MAX_OPACITY];
        targetPoint = [self getMonthLabelPointWithYearLabelPoint:yearEffectLabel.frame.origin];
        monthEffectLabel.frame = CGRectMake(targetPoint.x, targetPoint.y,
                                            monthEffectLabel.frame.size.width,
                                            monthEffectLabel.frame.size.height);
        [rotateView addSubview:monthEffectLabel];
    }
    if (type&tType_day) {
        if (weekDayEffectLabel) {
            [weekDayEffectLabel removeAnimateWithIsSearch:YES];
        }
        NSString *weekText = [converter weekHanhulWithIndex:date.weekday];
        weekDayEffectLabel = [[UIEffectLabel alloc] initWithString:[converter linearHangul:weekText] fontName:FONT_NORMAL fontSize:12.f init:NO Opacity:MAX_OPACITY];
        targetPoint = [self getWeekLabelPointWithMonthDayLabelPoint:monthEffectLabel.frame.origin];
        weekDayEffectLabel.frame = CGRectMake(targetPoint.x, targetPoint.y,
                                              weekDayEffectLabel.frame.size.width,
                                              weekDayEffectLabel.frame.size.height);
        [rotateView addSubview:weekDayEffectLabel];
    }
    if (type&tType_hour) {
        if (date.hour==0 || date.hour==12) {
            if (ampmEffectLabel) {
                [ampmEffectLabel removeAnimateWithIsSearch:YES];
            }
            NSString *ampmText = @"오전";
            if (date.hour>=12) ampmText = @"오후";
            ampmEffectLabel = [[UIEffectLabel alloc] initWithString:[converter linearHangul:ampmText] fontName:FONT_NORMAL fontSize:12.f init:NO Opacity:MAX_OPACITY];
            targetPoint = [self getAMPMLabelPointWithWeekLabelPoint:weekDayEffectLabel.frame.origin];
            ampmEffectLabel.frame = CGRectMake(targetPoint.x, targetPoint.y,
                                               ampmEffectLabel.frame.size.width,
                                               ampmEffectLabel.frame.size.height);
            [rotateView addSubview:ampmEffectLabel];
        }
    }
    
    
    
}

- (void) setTopLabelWithDate:(NSDate *)date
                  changeType:(enum TimeChangeType)type
                       label:(FWLabelView *)label {
    
    if (type&tType_day || type&tType_month || type&tType_year) {
        NSString *yearString = [NSString stringWithFormat:@"%@년", [converter hangulWithTime:date.year timeType:tcType_minute]];
        NSString *monthString = [NSString stringWithFormat:@"%@월", [converter hangulWithTime:date.month timeType:tcType_month]];
        NSString *dayString = [NSString stringWithFormat:@"%@일", [converter hangulWithTime:date.day timeType:tcType_minute]];
        NSString *weekString = [converter weekHanhulWithIndex:date.weekday];
        
        [label changeTextArray:@[yearString, monthString, dayString, weekString]];
    }
    
}

- (void) setAMPMTextAndLabelFrameWithDate:(NSDate *)date
                           hourLabelPoint:(CGPoint)hourLabelPoint
                                 animated:(BOOL)animated {
    if (date.hour<12) {
        [ampmLabelView changeText:@"오전"];
    } else {
        [ampmLabelView changeText:@"오후"];
    }
    CGPoint targetPoint = CGPointMake(hourLabelPoint.x-ampmLabelView.frame.size.width+0.f,
                                      hourLabelPoint.y-ampmLabelView.frame.size.height/2.f-ampmLabelView.frame.size.height*AMPM_EXTRAGAP_Y_RATE);
    if (!animated) {
        ampmLabelView.frame = CGRectMake(targetPoint.x, targetPoint.y,
                                         ampmLabelView.frame.size.width, ampmLabelView.frame.size.height);
    } else {
        [UIView animateWithDuration:ANI_TEXT_DELAY animations:^{
            [ampmLabelView setEasingFunction:ExponentialEaseOut forKeyPath:@"center"];
            ampmLabelView.frame = CGRectMake(targetPoint.x, targetPoint.y,
                                             ampmLabelView.frame.size.width,
                                             ampmLabelView.frame.size.height);
        } completion:^(BOOL finished) {
            [ampmLabelView removeEasingFunctionForKeyPath:@"center"];
        }];
    }
}

- (void) setHourTextAndLabelFrameWithTime:(NSDate *)date
                                hourLabel:(AMLabelView *)hourLabel
                                 animated:(BOOL) animated {
    // 시간 텍스트 설정
    NSString *hourText = nil;
    NSString *text = nil;
    if (![OptionController shared].ampmOff) {
        if (date.hour%12==0) {
            text = [converter hangulWithTime:12 timeType:tcType_hour];
        } else {
            text = [converter hangulWithTime:date.hour%12 timeType:tcType_hour];
        }
    } else {
        text = [converter hangulWithTime:date.hour%24 timeType:tcType_hour];
    }
    hourText = [NSString stringWithFormat:@"%@시", text];
    
    // 시간 레이블 너비, 좌표 준비
    CGFloat hourLabelW = [hourLabel changeText:hourText];
    CGFloat hourLabelX = winSize.width-PORTRAIT_STANDARD_X_GAP-hourLabelW;
    CGPoint targetPoint = CGPointMake(hourLabelX ,
                                      (YEAR_POS_Y*2)+(hourLabel.frame.size.height/2.f)*1.37f);
    
    // 시간 레이블 frame 설정
    if (animated) {
        [UIView animateWithDuration:ANI_TEXT_DELAY animations:^{
            [hourLabel setEasingFunction:ExponentialEaseOut forKeyPath:@"center"];
            hourLabel.frame = CGRectMake(targetPoint.x, targetPoint.y,
                                         hourLabel.frame.size.width,
                                         hourLabel.frame.size.height);
        } completion:^(BOOL finished) {
            [hourLabel removeEasingFunctionForKeyPath:@"center"];
        }];
    } else {
        hourLabel.frame = CGRectMake(targetPoint.x, targetPoint.y,
                                     hourLabel.frame.size.width,
                                     hourLabel.frame.size.height);
    }
}



#pragma mark - 화면 회전
- (BOOL)shouldAutorotate {
    [self setWinsize];
    mainTouchView.winSize = winSize;
    
    [RoationController shared].statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    return YES;
}
#pragma mark - 실제 화면 회전시
- (void) realRotateScreen {
    [self setWinsize];
    mainTouchView.winSize = winSize;
    
    
    portraitBackgroundImageView.alpha = 1;
    [UIView animateWithDuration:ROTATION_DELAY_TIME delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
        portraitBackgroundImageView.frame = CGRectMake(0, 0, winSize.width, winSize.height);
        portraitBackgroundImageView.frame = CGRectMake(0, 0, winSize.width, winSize.height);
        landscapeBackgroundImageView.alpha = [RoationController shared].isLandscape ? 1 : 0;
    } completion:nil];
    
    
    
    
    if (![OptionController shared].dateOff) {
        if (yeardateLabelView) {
            [UIView animateWithDuration:ROTATION_DELAY_TIME delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
                yeardateLabelView.frame = CGRectMake(TOP_YEAR_GAP, YEAR_POS_Y,
                                                     yeardateLabelView.frame.size.width,
                                                     yeardateLabelView.frame.size.height);
            } completion:^(BOOL finished) {
                
            }];
        }
    }
    
    
    CGPoint hourTargetPoint ;
    CGPoint ampmTargetPoint ;
    CGPoint minutTargetPoint ;
    CGPoint secondTargetPoint ;
    if (![RoationController shared].isLandscape) {
        float hourLabelW = hourLabelView.frame.size.width;
        float hourLabelX = winSize.width-PORTRAIT_STANDARD_X_GAP-hourLabelW;
        
        hourTargetPoint = CGPointMake(hourLabelX,
                                      (YEAR_POS_Y*2)+(hourLabelView.frame.size.height/2.f)*1.37f);
        float hourLabelY = hourTargetPoint.y+hourLabelView.frame.size.height/2.f;
        ampmTargetPoint = CGPointMake(hourLabelX-ampmLabelView.frame.size.width+0.f,
                                      hourLabelY-ampmLabelView.frame.size.height/2.f-ampmLabelView.frame.size.height*AMPM_EXTRAGAP_Y_RATE);
        
        float minuteW = minuteLabelView.frame.size.width;
        minutTargetPoint = CGPointMake(winSize.width-PORTRAIT_STANDARD_X_GAP-minuteW-MINUTE_PORTRAIT_EXTRA_GAP,
                                       hourLabelY+(minuteLabelView.frame.size.height/2.f)*1.37f);
        float minuteY = minutTargetPoint.y+minuteLabelView.frame.size.height/2.f;
        
        float secondW = secondLabelView.frame.size.width;
        secondTargetPoint = CGPointMake(winSize.width-PORTRAIT_STANDARD_X_GAP-secondW-SECOND_PORTRAIT_EXTRA_GAP,
                                        minuteY+(secondLabelView.frame.size.height/2.f)-SECOND_PORTRAIT_STANDARD_Y_GAP);
    } else {
        
        float hourLabelY = (YEAR_POS_Y*2)+(hourLabelView.frame.size.height/2.f)*1.37f+hourLabelView.frame.size.height/2.f;
        float ampmX = LANDSCAPE_STANDARD_X_GAP;
        float ampmW = ampmLabelView.frame.size.width;
        
        hourTargetPoint = CGPointMake(ampmX+ampmW-0.f,
                                      (YEAR_POS_Y*2)+(hourLabelView.frame.size.height/2.f)*1.37f);
        ampmTargetPoint = CGPointMake(ampmX,
                                      hourLabelY-ampmLabelView.frame.size.height/2.f-ampmLabelView.frame.size.height*AMPM_EXTRAGAP_Y_RATE);
        
        float minuteW = minuteLabelView.frame.size.width;
        minutTargetPoint = CGPointMake(winSize.width-LANDSCAPE_STANDARD_MIN_X_GAP-minuteW,
                                       hourLabelY+(minuteLabelView.frame.size.height/2.f)*1.37f);
        float minuteY = minutTargetPoint.y+minuteLabelView.frame.size.height/2.f;
        
        secondTargetPoint = CGPointMake(winSize.width-LANDSCAPE_STANDARD_MIN_X_GAP+SECOND_LANDSCAPE_X,
                                        minuteY-(secondLabelView.frame.size.height/2.f)+7.f);
    }
    
    
    
    [UIView animateWithDuration:ROTATION_DELAY_TIME delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
        hourLabelView.frame = CGRectMake(hourTargetPoint.x, hourTargetPoint.y, hourLabelView.frame.size.width, hourLabelView.frame.size.height);
        minuteLabelView.frame = CGRectMake(minutTargetPoint.x, minutTargetPoint.y, minuteLabelView.frame.size.width, minuteLabelView.frame.size.height);
        if (![OptionController shared].ampmOff) {
            ampmLabelView.frame = CGRectMake(ampmTargetPoint.x, ampmTargetPoint.y, ampmLabelView.frame.size.width, ampmLabelView.frame.size.height);
        }
        if (![OptionController shared].secondOff) {
            secondLabelView.frame = CGRectMake(secondTargetPoint.x, secondTargetPoint.y, secondLabelView.frame.size.width, secondLabelView.frame.size.height);
        }
    } completion:^(BOOL finished) {
        
    }];
    
    
    
    CGPoint yep = [self getYearLabelPoint];
    CGPoint mep = [self getMonthLabelPointWithYearLabelPoint:yep];
    CGPoint wep = [self getWeekLabelPointWithMonthDayLabelPoint:mep];
    CGPoint aep = [self getAMPMLabelPointWithWeekLabelPoint:wep];
    
    
    [UIView animateWithDuration:ROTATION_DELAY_TIME delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
        yearEffectLabel.frame = CGRectMake(yep.x, yep.y, yearEffectLabel.frame.size.width, yearEffectLabel.frame.size.height);
        monthEffectLabel.frame = CGRectMake(mep.x, mep.y, monthEffectLabel.frame.size.width, monthEffectLabel.frame.size.height);
        weekDayEffectLabel.frame = CGRectMake(wep.x, wep.y, weekDayEffectLabel.frame.size.width, weekDayEffectLabel.frame.size.height);
        ampmEffectLabel.frame = CGRectMake(aep.x, aep.y, ampmEffectLabel.frame.size.width, ampmEffectLabel.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
    
    if (menuView) {[menuView rotateWithWinSize:winSize];}
}


- (void) makeMenuView {
    if (!menuView) {
        menuView = [[MenuView alloc] initWithFrame:CGRectMake(0, 0, winSize.width, winSize.height)];
        menuView.alpha = 0;
        menuView.menuOn = NO;
        menuView.mainViewController = self;
        [self.view addSubview:menuView];
        mainTouchView.menuView = menuView;
    }
}






#pragma mark - 옵션으로부터 이벤트
- (void)setSecondOff:(BOOL)secondOff {
    if (secondOff) {
        if (secondLabelView) {
            AMLabelView *tmepLabelView = secondLabelView;
            secondLabelView = nil;
            [tmepLabelView removeAnimationWithBlock:^{
                [tmepLabelView removeFromSuperview];
            }];
        }
    } else {
        if (!secondLabelView) {
            secondLabelView = [[AMLabelView alloc] initWithFontName:FONT_NORMAL fontSize:SECOND_FONTSIZE*SCREENRATE];
            [secondLabelView setLabelCount:4];
            [rotateView addSubview:secondLabelView];
            
            
            CGPoint targetPoint ;
            float secondW = [secondLabelView changeText:@"초"];
            if (winSize.width<winSize.height) {
                targetPoint = CGPointMake(winSize.width-PORTRAIT_STANDARD_X_GAP-secondW-SECOND_PORTRAIT_EXTRA_GAP,
                                          minuteLabelView.frame.origin.y+minuteLabelView.frame.size.height/2.f+(secondLabelView.frame.size.height)-4.f);
                
            } else {
                targetPoint = CGPointMake(winSize.width-LANDSCAPE_STANDARD_MIN_X_GAP+SECOND_LANDSCAPE_X,
                                          minuteLabelView.frame.origin.y+minuteLabelView.frame.size.height/2.f-(secondLabelView.frame.size.height/2.f)-LANDSCAPE_STANDARD_MIN_Y_GAP);
            }
            secondLabelView.frame = CGRectMake(targetPoint.x, targetPoint.y, secondW, secondLabelView.frame.size.height);
        }
    }
}
- (void)setDateOff:(BOOL)dateOff {
    if (dateOff) {
        if (yeardateLabelView) {
            if (secondLabelView) {
                FWLabelView *tmepLabelView = yeardateLabelView;
                yeardateLabelView = nil;
                [tmepLabelView removeAnimationWithBlock:^{
                    [tmepLabelView removeFromSuperview];
                }];
            }
        }
    } else {
        if (!yeardateLabelView) {
            float width = (winSize.height<winSize.width)?(winSize.height):(winSize.width);
            yeardateLabelView = [[FWLabelView alloc] initWithFontName:FONT_NORMAL
                                                             fontSize:TOP_YEAR_FONTSIZE*SCREENRATE
                                                                width:width-TOP_YEAR_GAP*2.f];
            yeardateLabelView.frame = CGRectMake(TOP_YEAR_GAP, YEAR_POS_Y,
                                                 yeardateLabelView.frame.size.width,
                                                 yeardateLabelView.frame.size.height);
            [rotateView addSubview:yeardateLabelView];
        }
        NSDate *date = [NSDate date];
        NSString *yearString = [NSString stringWithFormat:@"%@년", [converter hangulWithTime:date.year timeType:tcType_minute]];
        NSString *monthString = [NSString stringWithFormat:@"%@월", [converter hangulWithTime:date.month timeType:tcType_month]];
        NSString *dayString = [NSString stringWithFormat:@"%@일", [converter hangulWithTime:date.day timeType:tcType_minute]];
        NSString *weekString = [converter weekHanhulWithIndex:date.weekday];
        [yeardateLabelView changeTextArray:@[yearString, monthString, dayString, weekString]];
    }
}


- (void)setAmpmOff:(BOOL)ampmOff {
    
    
    // 지울건 지우고
    
    if (ampmOff) {
        if (ampmLabelView) {
            AMLabelView *tmepLabelView = ampmLabelView;
            ampmLabelView = nil;
            [tmepLabelView removeAnimationWithBlock:^{
                [tmepLabelView removeFromSuperview];
            }];
        }
    } else {
        
    }
    
    enum TimeChangeType type = tType_hour;
    NSDate *date = [NSDate date];
    [self timeChanged:date changeType:type];
}


@end
