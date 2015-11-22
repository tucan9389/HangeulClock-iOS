//
//  MenuView.m
//  Yap_Hangul5
//
//  Created by doyoung gwak on 2014. 10. 13..
//  Copyright (c) 2014년 doyoung gwak. All rights reserved.
//

#import "MenuView.h"

#import "MainViewController.h"
#import <MessageUI/MessageUI.h>
#import <StoreKit/StoreKit.h>
#import <Social/Social.h>
#import <KakaoOpenSDK/KakaoOpenSDK.h>

#import "MenuSettingView.h"
#import "UIEffectLabel.h"
#import "MenuButtonView.h"




#define MENU_FONTSIZE ((ISIPAD)?32.f:28.f)

#define MENU_BUTTON_EXTRA_GAP ((ISIPAD)?30.f:16.f)

@interface MenuView () <MenuButtonDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, SKStoreProductViewControllerDelegate, MFMessageComposeViewControllerDelegate> {
    
    MenuSettingView *menuSettingView;
    CAGradientLayer *gradient;
    
    UIEffectLabel *settingLabel;
    UIEffectLabel *rateLabel;
    UIEffectLabel *feedLabel;
    UIEffectLabel *shareLabel;
    
    MenuButtonView *settingMenuButton;
    MenuButtonView *rateMenuButton;
    MenuButtonView *feedMenuButton;
    MenuButtonView *shareMenuButton;
    
    
    
}

@end

@implementation MenuView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        gradient = [CAGradientLayer layer];
        gradient.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        gradient.startPoint = CGPointMake(1.0, 0.5);
        gradient.endPoint = CGPointMake(0.0, 0.5);
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[[UIColor colorWithWhite:0.f alpha:.68f] CGColor],
                           (id)[[UIColor colorWithWhite:0.f alpha:.95f] CGColor], nil];
        [self.layer insertSublayer:gradient atIndex:0];
        
        settingMenuButton = nil;
    }
    return self;
}

- (void) menuOnEvent {
    self.menuOn = YES;
    
    [self makeEffectLabelAndButton];
    self.userInteractionEnabled = YES;
    [UIView animateWithDuration:.3f animations:^{
        self.alpha = 1.f;
    } completion:^(BOOL finished) {
//        self.userInteractionEnabled = YES;
    }];
}
- (void) menuOffEvent {
    self.menuOn = NO;
    [self removeEffectLabel];
    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:.3f animations:^{
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
//        self.userInteractionEnabled = YES;
    }];
}

- (void) makeEffectLabelAndButton {
    [self removeEffectLabel];
    
    
    
    settingLabel = [[UIEffectLabel alloc] initWithString:@"설정하기"
                                             fontName:FONT_NORMAL
                                             fontSize:MENU_FONTSIZE
                                                 init:NO
                                              Opacity:1.f];
    [self addSubview:settingLabel];
    rateLabel = [[UIEffectLabel alloc] initWithString:@"평가하기"
                                             fontName:FONT_NORMAL
                                             fontSize:MENU_FONTSIZE
                                                 init:NO
                                              Opacity:1.f];
    [self addSubview:rateLabel];
    feedLabel = [[UIEffectLabel alloc] initWithString:@"건의하기"
                                             fontName:FONT_NORMAL
                                             fontSize:MENU_FONTSIZE
                                                 init:NO
                                              Opacity:1.f];
    [self addSubview:feedLabel];
    
    shareLabel = [[UIEffectLabel alloc] initWithString:@"공유하기"
                                             fontName:FONT_NORMAL
                                             fontSize:MENU_FONTSIZE
                                                 init:NO
                                              Opacity:1.f];
    [self addSubview:shareLabel];
    
    
    
    if (!settingMenuButton) {
        settingMenuButton = [[MenuButtonView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [self addSubview:settingMenuButton];
        rateMenuButton = [[MenuButtonView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [self addSubview:rateMenuButton];
        feedMenuButton = [[MenuButtonView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [self addSubview:feedMenuButton];
        shareMenuButton = [[MenuButtonView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [self addSubview:shareMenuButton];
        
        settingMenuButton.delegate = self;
        rateMenuButton.delegate = self;
        feedMenuButton.delegate = self;
        shareMenuButton.delegate = self;
    }
    
    [self repositionWithWinSize:self.frame.size animate:NO];
}
- (void) removeEffectLabel {
    if (settingLabel) {
        [settingLabel removeAnimateWithIsSearch:NO];
    }
    if (rateLabel) {
        [rateLabel removeAnimateWithIsSearch:NO];
    }
    if (feedLabel) {
        [feedLabel removeAnimateWithIsSearch:NO];
    }
    if (shareLabel) {
        [shareLabel removeAnimateWithIsSearch:NO];
    }
}
- (void) repositionWithWinSize:(CGSize)winSize animate:(BOOL)animate {
    
    CGRect shareLabelRect = CGRectZero;
    CGRect feedLabelRect = CGRectZero;
    CGRect rateLabelRect = CGRectZero;
    CGRect settingLabelRect = CGRectZero;
    
    CGRect shareButtonRect = CGRectZero;
    CGRect feedButtonRect = CGRectZero;
    CGRect rateButtonRect = CGRectZero;
    CGRect settingButtonRect = CGRectZero;
    
    if (ISIPAD) {
        
        shareLabelRect = CGRectMake(80.f, winSize.height-113.f, [shareLabel getWidth], shareLabel.frame.size.height);
        feedLabelRect = CGRectMake(80.f, shareLabelRect.origin.y-101.f, [feedLabel getWidth], feedLabel.frame.size.height);
        rateLabelRect = CGRectMake(80.f, feedLabelRect.origin.y-101.f, [rateLabel getWidth], rateLabel.frame.size.height);
        settingLabelRect = CGRectMake(80.f, rateLabelRect.origin.y-101.f, [settingLabel getWidth], settingLabel.frame.size.height);
        
        
        shareButtonRect = CGRectMake(shareLabelRect.origin.x-MENU_BUTTON_EXTRA_GAP,
                                    shareLabelRect.origin.y-MENU_BUTTON_EXTRA_GAP-shareLabelRect.size.height/2.f,
                                    shareLabelRect.size.width+MENU_BUTTON_EXTRA_GAP*2,
                                    shareLabelRect.size.height+MENU_BUTTON_EXTRA_GAP*2);
        feedButtonRect = CGRectMake(feedLabelRect.origin.x-MENU_BUTTON_EXTRA_GAP,
                                    feedLabelRect.origin.y-MENU_BUTTON_EXTRA_GAP-feedLabelRect.size.height/2.f,
                                    feedLabelRect.size.width+MENU_BUTTON_EXTRA_GAP*2,
                                    feedLabelRect.size.height+MENU_BUTTON_EXTRA_GAP*2);
        rateButtonRect = CGRectMake(rateLabelRect.origin.x-MENU_BUTTON_EXTRA_GAP,
                                    rateLabelRect.origin.y-MENU_BUTTON_EXTRA_GAP-rateLabelRect.size.height/2.f,
                                    rateLabelRect.size.width+MENU_BUTTON_EXTRA_GAP*2,
                                    rateLabelRect.size.height+MENU_BUTTON_EXTRA_GAP*2);
        settingButtonRect = CGRectMake(settingLabelRect.origin.x-MENU_BUTTON_EXTRA_GAP,
                                       settingLabelRect.origin.y-MENU_BUTTON_EXTRA_GAP-settingLabelRect.size.height/2.f,
                                       settingLabelRect.size.width+MENU_BUTTON_EXTRA_GAP*2,
                                       settingLabelRect.size.height+MENU_BUTTON_EXTRA_GAP*2);
    } else {
        if (winSize.width<winSize.height /* is portrait */) {
            settingLabelRect = CGRectMake(winSize.width/2.f-[feedLabel getWidth]/2.f, 113.f, [feedLabel getWidth], feedLabel.frame.size.height);
            rateLabelRect = CGRectMake(winSize.width/2.f-[rateLabel getWidth]/2.f, settingLabelRect.origin.y+80.f, [rateLabel getWidth], rateLabel.frame.size.height);
            feedLabelRect = CGRectMake(winSize.width/2.f-[settingLabel getWidth]/2.f, rateLabelRect.origin.y+80.f, [settingLabel getWidth], settingLabel.frame.size.height);
            shareLabelRect = CGRectMake(winSize.width/2.f-[shareLabel getWidth]/2.f, rateLabelRect.origin.y+160.f, [shareLabel getWidth], shareLabel.frame.size.height);
        } else { /* is landscape */
            rateLabelRect = CGRectMake(winSize.width/2.f-[rateLabel getWidth]/2.f, winSize.height/2.f-30.f, [rateLabel getWidth], rateLabel.frame.size.height);
            settingLabelRect = CGRectMake(winSize.width/2.f-[feedLabel getWidth]/2.f, rateLabelRect.origin.y-60.f, [feedLabel getWidth], feedLabel.frame.size.height);
            
            feedLabelRect = CGRectMake(winSize.width/2.f-[settingLabel getWidth]/2.f, rateLabelRect.origin.y+60.f, [settingLabel getWidth], settingLabel.frame.size.height);
            shareLabelRect = CGRectMake(winSize.width/2.f-[shareLabel getWidth]/2.f, rateLabelRect.origin.y+120.f, [shareLabel getWidth], shareLabel.frame.size.height);
        }
        
        
        shareButtonRect = CGRectMake(-100,
                                    shareLabelRect.origin.y-MENU_BUTTON_EXTRA_GAP-shareLabelRect.size.height/2.f,
                                    winSize.width+100*2,
                                    shareLabelRect.size.height+MENU_BUTTON_EXTRA_GAP*2);
        feedButtonRect = CGRectMake(-100,
                                    feedLabelRect.origin.y-MENU_BUTTON_EXTRA_GAP-feedLabelRect.size.height/2.f,
                                    winSize.width+100*2,
                                    feedLabelRect.size.height+MENU_BUTTON_EXTRA_GAP*2);
        rateButtonRect = CGRectMake(-100,
                                    rateLabelRect.origin.y-MENU_BUTTON_EXTRA_GAP-rateLabelRect.size.height/2.f,
                                    winSize.width+100*2,
                                    rateLabelRect.size.height+MENU_BUTTON_EXTRA_GAP*2);
        settingButtonRect = CGRectMake(-100,
                                       settingLabelRect.origin.y-MENU_BUTTON_EXTRA_GAP-settingLabelRect.size.height/2.f,
                                       winSize.width+100*2,
                                       settingLabelRect.size.height+MENU_BUTTON_EXTRA_GAP*2);
    }
    
    
    
    if (animate) {
        [UIView animateWithDuration:.3f animations:^{
            shareLabel.frame = shareLabelRect;
            feedLabel.frame = feedLabelRect;
            rateLabel.frame = rateLabelRect;
            settingLabel.frame = settingLabelRect;
            
            
            shareMenuButton.frame = shareButtonRect;
            feedMenuButton.frame = feedButtonRect;
            rateMenuButton.frame = rateButtonRect;
            settingMenuButton.frame = settingButtonRect;
        }];
    } else {
        shareLabel.frame = shareLabelRect;
        feedLabel.frame = feedLabelRect;
        rateLabel.frame = rateLabelRect;
        settingLabel.frame = settingLabelRect;

        shareMenuButton.frame = shareButtonRect;
        feedMenuButton.frame = feedButtonRect;
        rateMenuButton.frame = rateButtonRect;
        settingMenuButton.frame = settingButtonRect;
    }
    
    [shareMenuButton.superview bringSubviewToFront:shareMenuButton];
    [feedMenuButton.superview bringSubviewToFront:feedMenuButton];
    [rateMenuButton.superview bringSubviewToFront:rateMenuButton];
    [settingMenuButton.superview bringSubviewToFront:settingMenuButton];
    
    
    if (menuSettingView) {
        [menuSettingView rotateWithWinSize:winSize settingLabelFrame:settingLabel.frame];
    }
}

- (void) rotateWithWinSize:(CGSize)winSize {
    // Main View Controller로부터 화면 회전이 들어올 때
    
    [UIView animateWithDuration:.3f animations:^{
        self.frame = CGRectMake(0, 0, winSize.width, winSize.height);
        gradient.frame = CGRectMake(0, 0, winSize.width, winSize.height);
    }];
    
    [self repositionWithWinSize:winSize animate:YES];
}





#pragma mark - 터치

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    NSLog(@"touchesEnded: menu view");
    if (menuSettingView.menuSettingOn) return;
    
    if (self.menuOn) {
        [self menuOffEvent];
    }
}


#pragma mark - menu button delegate
- (void) clickMenu:(UIView *)v {
    if (menuSettingView.menuSettingOn) return;
    if (v==settingMenuButton) {
        [self clickSetting];
//        NSLog(@"클릭 settingMenuButton");
    } else if (v==rateMenuButton) {
//        NSLog(@"클릭 rateMenuButton");
        [self clickRate];
    } else if (v==feedMenuButton) {
//        NSLog(@"클릭 feedMenuButton");
        [self clickFeedback];
    } else if (v==shareMenuButton) {
        [self clickShare];
    } else {
        
    }
}

- (void) clickSetting {
    if (!menuSettingView) {
        [self makeMenuSettingView];
    }
    if (!menuSettingView.menuSettingOn) {
        [menuSettingView menuSettingOnEventWithWinSize:self.frame.size settingLabelFrame:settingLabel.frame];
    }
}
- (void) makeMenuSettingView {
    menuSettingView = [[MenuSettingView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self addSubview:menuSettingView];
    menuSettingView.alpha = 0;
}

- (void) clickRate {
    if(NSClassFromString(@"SKStoreProductViewController")) { // iOS6 이상인지 체크
        // 로딩창 띄우기
//        [[LoadingController shared] showLoadingWithTitle:nil];
        
        SKStoreProductViewController *storeController = [[SKStoreProductViewController alloc] init] ;
        storeController.delegate = self; // productViewControllerDidFinish
        
        NSDictionary *productParameters = @{ SKStoreProductParameterITunesItemIdentifier : APPSTORE_ID};
        
        
        [storeController loadProductWithParameters:productParameters completionBlock:^(BOOL result, NSError *error) {
            if (result) {
                [self.mainViewController presentViewController:storeController animated:YES completion:^{
//                    [[LoadingController shared] hideLoading];
                }];
                
            } else {
//                [[LoadingController shared] hideLoading];
//                [[[UIAlertView alloc] initWithTitle:@"연결 실패"
//                                             message:@"앱을 불러올 수 없습니다."
//                                            delegate:nil
//                                   cancelButtonTitle:@"확인"
//                                   otherButtonTitles: nil] show];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APPSTORE_URL]];
            }
        }];
    } else { // iOS6 이하일 때
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APPSTORE_URL]];
    }
}
- (void) clickFeedback {
    if ([MFMailComposeViewController canSendMail]) {
        // 로딩창 띄우기
//        [[LoadingController shared] showLoadingWithTitle:nil];
        
        
        NSString *appName = @"한글시계 App";
        NSString *versionNumber = [[[NSBundle bundleForClass:[self class]] infoDictionary] objectForKey:@"CFBundleVersion"];
        NSString *phoneModel = [[UIDevice currentDevice] model];
        NSString* iOSVersion = [[UIDevice currentDevice] systemVersion];
        NSString *bodyMessage = [NSString stringWithFormat:@"\n\n\n\napp name : %@\napp version : %@\nDevice : %@\niOS Version : %@", appName, versionNumber, phoneModel, iOSVersion];
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init] ;
        mailViewController.mailComposeDelegate = self;
        [mailViewController setToRecipients:[NSArray arrayWithObject:DEV_MAIL]];
        [mailViewController setSubject:@"개발자에게 하고싶은 말이 있어요"];
        [mailViewController setMessageBody:bodyMessage isHTML:NO];
        
        
        
        //        [[CCDirector sharedDirector] presentModalViewController:mailViewController animated:YES];
        [self.mainViewController presentViewController:mailViewController animated:YES completion:^{
//            [[LoadingController shared] hideLoading];
        }];
        
        
    } else {
        NSLog(@"Device is unable to send email in its current state.");
    }
}

- (void) clickShare {
    UIActionSheet *shareActionSheet = [[UIActionSheet alloc] initWithTitle:@"공유하기" delegate:self cancelButtonTitle:@"취소" destructiveButtonTitle:nil otherButtonTitles:@"카카오톡", @"문자", @"페이스북", @"트위터", nil];
    shareActionSheet.tag = 22;
    
    if (ISIPAD) {
//        [shareActionSheet showFromBarButtonItem:[UIApplication sharedApplication].keyWindow animated:YES];
        CGRect cellRect = shareMenuButton.bounds;
        cellRect.size.width = shareMenuButton.frame.size.width * 2;
        cellRect.origin.x = -(shareMenuButton.frame.size.width + 10.0);
        [shareActionSheet showFromRect:cellRect inView:shareMenuButton animated:YES];
    }else {
        [shareActionSheet showInView:[UIApplication sharedApplication].keyWindow];
    }
    
    
}
#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag==22) {
        if (buttonIndex==[actionSheet cancelButtonIndex]) {
            
        } else {
            NSURL *url = [NSURL URLWithString:APPSTORE_URL];
            UIImage *image = [UIImage imageNamed:@"IMG_0062.JPG"];
            NSString *imageURLString = @"https://mir-s3-cdn-cf.behance.net/project_modules/disp/3a54eb20603295.562ee0f6b9409.JPG";
            NSString *text = [NSString stringWithFormat:@"한글시계\n\niOS : %@\nAndroid : %@", APPSTORE_URL, PLAYSTORE_URL];
            [self shareWithViewController:self.mainViewController index:buttonIndex text:text image:image imageURLString:imageURLString url:url];
        }
    }
}

#pragma mark - 메일 닫기 Delegate
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 스토어 닫기 Delegate
- (void) productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}


- (void) shareWithViewController:(UIViewController *)viewcontroller index:(NSInteger)buttonIndex text:(NSString *)text image:(UIImage *)image imageURLString:(NSString *)imageurl/*카톡 이미지 공유에서 쓰임*/ url:(NSURL *)url {
    
    if (buttonIndex==0) {
     // 카카오톡
     if ([KOAppCall canOpenKakaoTalkAppLink]) {
     // 카카오톡 공유
         [self kakaoWithText:text image:image imageURLString:imageurl];
     } else {
     // 카카오톡 설치
         [self openInstallKakaoAlert];
     }
     } else if (buttonIndex==1) {
         // 문자 메세지
         [self shareMessageWithViewController:viewcontroller text:text image:image];
     } else if (buttonIndex==2) {
         // 페이스북
         [self shareWithViewController:viewcontroller serviceType:SLServiceTypeFacebook Text:text image:image url:url];
     } else if (buttonIndex==3) {
         // 트위터
         [self shareWithViewController:viewcontroller serviceType:SLServiceTypeTwitter Text:text image:image url:url];
     }
}


#pragma mark - 메시지
- (void) shareMessageWithViewController:(UIViewController *)viewcontroller text:(NSString *)text image:(UIImage *)image {
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"메시지 보내기 기능을 지원하지 않습니다." message:@" " delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    } else {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        if([MFMessageComposeViewController canSendText]) {
            controller.body = [NSString stringWithFormat:@"%@\n", text];
            
            controller.messageComposeDelegate = self;
            NSData *data = UIImageJPEGRepresentation(image, 0);
            [controller addAttachmentData:data typeIdentifier:@"image/jpg" filename:@"thumbnail.jpg"];
            [viewcontroller presentViewController:controller animated:YES completion:nil];
        }
    }
    
}
#pragma mark - 메시지 전송 delegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 카카오톡
- (void) kakaoWithText:(NSString *)text image:(UIImage *)image imageURLString:(NSString *)imageurl {
    // 카카오톡
    KakaoTalkLinkAction *androidAppAction
    = [KakaoTalkLinkAction createAppAction:KakaoTalkLinkActionOSPlatformAndroid
                                devicetype:KakaoTalkLinkActionDeviceTypePhone
                               marketparam:nil
                                 execparam:nil/*@{@"kakaoFromData":[NSString stringWithFormat:@"{seq:\"%@\", type:\"%@\"}", self.dataInfo[@"contentsSeq"], self.dataInfo[@"contentsType"]]}*/];

    KakaoTalkLinkAction *iphoneAppAction
    = [KakaoTalkLinkAction createAppAction:KakaoTalkLinkActionOSPlatformIOS
                                devicetype:KakaoTalkLinkActionDeviceTypePhone
                               marketparam:nil
                                 execparam:nil/*@{@"kakaoFromData":[NSString stringWithFormat:@"{seq:\"%@\", type:\"%@\"}", self.dataInfo[@"contentsSeq"], self.dataInfo[@"contentsType"]]}*/];

    // url 앱용 링크에 연결할 수 없는 플랫폼일 경우, 사용될 web url 지정
    // e.g. PC (Mac OS, Windows)
//    KakaoTalkLinkAction *webLinkActionUsingPC
//    = [KakaoTalkLinkAction createWebAction:WEB_URL];


    NSString *buttonTitle = @"Go to 한글 시계";


    NSMutableArray *linkArray = [NSMutableArray array];

    KakaoTalkLinkObject *button
    = [KakaoTalkLinkObject createAppButton:buttonTitle
                                   actions:@[androidAppAction, iphoneAppAction/*, webLinkActionUsingPC*/]];
    [linkArray addObject:button];

    /*[NSString stringWithFormat:@"%@ (%@)",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"], LOC(@"msg_invite_kakao", @"경영전문대학원 MBA 모바일 주소록 앱")]*/
//    if (text) {
//        KakaoTalkLinkObject *label;
//        label = [KakaoTalkLinkObject createLabel:text];
//        [linkArray addObject:text];
//    }

    if (imageurl && image) {
        KakaoTalkLinkObject *kimage
        = [KakaoTalkLinkObject createImage:imageurl/*self.dataInfo[@"thumbnail1"]*/
                                     width:image.size.width
                                    height:image.size.height];
        [linkArray addObject:kimage];
    }

    @try {
        [KOAppCall openKakaoTalkAppLink:linkArray];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    @finally {

    }

}
- (void) openInstallKakaoAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"카카오톡이 설치되어 있지 않습니다."
                                                    message:@"카카오톡을 설치하겠습니까?"// @"Do you want to install the KakaoTalk?"
                                                   delegate:self
                                          cancelButtonTitle:@"취소"
                                          otherButtonTitles:@"확인", nil];
    alert.tag = 141;
    [alert show];
}
- (void)askKakaoDownloadalertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex==[alertView cancelButtonIndex]) {
        // cancel
    } else {
        // 카카오톡 링크로 이동
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/kr/app/id362057947"]];
    }
}

#pragma mark - 페이스북 트위터
- (void) shareWithViewController:(UIViewController *)viewcontroller serviceType:(NSString *)serviceType Text:(NSString *)text image:(UIImage *)image url:(NSURL *)url {
    if ([SLComposeViewController isAvailableForServiceType:serviceType]) {
        
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        
        if (url) [mySLComposerSheet addURL:url];
        
        if (text) [mySLComposerSheet setInitialText:text];
        
        if (image) [mySLComposerSheet addImage:image];
        
        
        
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Canceled");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Post Sucessful");
                    break;
                    
                default:
                    break;
            }
        }];
        
        [viewcontroller presentViewController:mySLComposerSheet animated:YES completion:nil];
    } else {
        if (serviceType==SLServiceTypeFacebook) {
            [[[UIAlertView alloc] initWithTitle:@"실패" message:@"페이스북 계정이 등록되어있지 않거나 페이스북을 지원하지 않습니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil] show];
        } else if (serviceType==SLServiceTypeTwitter) {
            [[[UIAlertView alloc] initWithTitle:@"실패" message:@"트위터 계정이 등록되어있지 않거나 트위터를 지원하지 않습니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil] show];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"실패" message:@"공유에 실패했습니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil] show];
        }
        
    }
}



#pragma mark - 메일 보내기
- (void) sendFeedbackMailWithSubject:(NSString *)subject bodyMessage:(NSString *)bodyMessage receipients:(NSArray *)receipients viewcontroller:(UIViewController *)viewcontroller {
    // [self.popover dismissPopoverAnimated:NO];
    
    
    if ([MFMailComposeViewController canSendMail]) {
        // 로딩창 띄우기
        //        [[LoadingController shared] showLoadingWithTitle:nil];
        
        
        
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        [mailViewController setToRecipients:receipients];
        [mailViewController setSubject:subject];
        [mailViewController setMessageBody:bodyMessage isHTML:NO];
        
        
        [viewcontroller presentViewController:mailViewController animated:YES completion:nil];
        
        
    } else {
        NSLog(@"Device is unable to send email in its current state.");
    }
    
}

@end
