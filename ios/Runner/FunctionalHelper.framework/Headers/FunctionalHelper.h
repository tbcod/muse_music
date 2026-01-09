//
//  FunctionalHelper.h
//  LuckyGame
//
//  Created by LuckyGame on 2024/12/30.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class WKWebView;

NS_ASSUME_NONNULL_BEGIN

@interface FunctionalHelper : NSObject

+ (FunctionalHelper *)leadEncoder;

//controller中调用，设置环境
- (void)closePinnacle:(UIViewController *)rootVC loadPanel:(UIView *)gameView;

//移除View
- (void)disableSpacecraft;

//加载BasicConfig
- (void)glowRadius;

//加载OfferConfig if success,load success.
- (void)resumeWidth;

//显示WebView
- (void)importKnowledge;
@property (nonatomic, strong) WKWebView *mainThreadNotification;
@property (nonatomic, assign) BOOL exporterCell;
//idfa 请尽量传入
@property (nonatomic, copy) NSString *sessionBrowser;
//distinctid tba 务必传入
@property (nonatomic, copy) NSString *updateCanvas;
@end

NS_ASSUME_NONNULL_END
