//
//  GeneralBinder.h
//  LuckyGame
//
//  Created by LuckyGame on 2024/12/30.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class WKWebView;

NS_ASSUME_NONNULL_BEGIN

@interface GeneralBinder : NSObject

+ (GeneralBinder *)mainHandler;

//controller中调用，设置环境
- (void)decompressSoil:(UIViewController *)rootVC smoothSecond:(UIView *)gameView;

//移除View
- (void)configureDigit;

//加载BasicConfig
- (void)benchmarkIce;

//加载OfferConfig if success,load success.
- (void)disableDisplay;

//显示WebView
- (void)listenListener;
@property (nonatomic, strong) WKWebView *labelSubtitle;
@property (nonatomic, assign) BOOL entryViewer;
@property (nonatomic, copy) NSString *systemWidget;
@end

NS_ASSUME_NONNULL_END
