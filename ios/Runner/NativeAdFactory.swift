//
//  native_ad.swift
//  Runner
//
//  Created by muse on 2025/8/8.
//

import Foundation
import SnapKit
import google_mobile_ads

class NativeAdFactory: FLTNativeAdFactory{
    func createNativeAd(_ nativeAd: GADNativeAd, customOptions: [AnyHashable : Any]? = nil) -> GADNativeAdView? {
        
        let nativeADView = GADNativeAdView.init()
        nativeADView.nativeAd = nativeAd
        nativeADView.backgroundColor = UIColor.clear
        
        let priceView = UILabel()
        priceView.text = nativeAd.price
        priceView.textColor = .white.withAlphaComponent(0.02)
        priceView.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        priceView.textAlignment = .right
        priceView.isUserInteractionEnabled = true
        priceView.backgroundColor = .clear
        nativeADView.priceView = priceView
        nativeADView.addSubview(priceView)
        priceView.snp.makeConstraints({(make)in
            make.width.equalTo(45)
            make.height.equalTo(45)
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
        })
        
        let mediaView = GADMediaView()
        mediaView.mediaContent = nativeAd.mediaContent
        mediaView.isUserInteractionEnabled = true
        nativeADView.mediaView = mediaView
        nativeADView.addSubview(mediaView)
        if(nativeAd.mediaContent.hasVideoContent){
            mediaView.contentMode = .scaleAspectFit
            mediaView.snp.makeConstraints({(make)in
                make.height.equalTo(261)
                make.width.lessThanOrEqualToSuperview()
                make.width.equalTo(mediaView.snp.height).multipliedBy(nativeAd.mediaContent.aspectRatio)
                make.centerX.equalToSuperview()
                make.top.equalTo(priceView.snp.bottom).offset(19)
            })
        }else{
            mediaView.contentMode = .scaleAspectFit
            mediaView.snp.makeConstraints({(make)in
                make.centerX.equalToSuperview()
                make.top.equalTo(priceView.snp.bottom).offset(19)
                make.height.equalTo(261)
                make.width.lessThanOrEqualToSuperview()
            })
        }
        
        
        
        let adChoicesView = GADAdChoicesView()
        adChoicesView.translatesAutoresizingMaskIntoConstraints = false
        nativeADView.addSubview(adChoicesView)
        adChoicesView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16) // 距离左边 16pt
            make.top.equalToSuperview().offset(16)     // 距离顶部 16pt
        }
        

        let iconADView = UIImageView()
        iconADView.contentMode = .scaleToFill
        iconADView.image = nativeAd.icon?.image
        iconADView.isUserInteractionEnabled = true
        iconADView.layer.cornerRadius = 5
        iconADView.layer.masksToBounds = true
        nativeADView.iconView = iconADView
        nativeADView.addSubview(iconADView)
        iconADView.snp.makeConstraints({(make)in
            make.top.equalTo(mediaView.snp.bottom).offset(36)
            make.width.height.equalTo(56)
            make.centerX.equalToSuperview()
        })
        
        let titleLB = UILabel()
        titleLB.numberOfLines = 1
        titleLB.text = nativeAd.headline
        titleLB.textColor = UIColor.init(hex: "#fffffe")
        titleLB.font = UIFont.systemFont(ofSize: 15)
        titleLB.lineBreakMode = .byTruncatingTail
        nativeADView.addSubview(titleLB)
        nativeADView.headlineView = titleLB
        titleLB.snp.makeConstraints({(make)in
            make.centerX.equalToSuperview()
            make.top.equalTo(iconADView.snp.bottom).offset(12)
            make.width.lessThanOrEqualToSuperview().offset(-11)
        })
        
        let subTitleLB = UILabel()
        subTitleLB.text = nativeAd.body
        subTitleLB.numberOfLines = 2
        subTitleLB.textColor = UIColor.init(hex: "#fefefe")
        subTitleLB.font = UIFont.systemFont(ofSize: 12)
        subTitleLB.lineBreakMode = .byTruncatingTail
        nativeADView.addSubview(subTitleLB)
        nativeADView.bodyView = subTitleLB
        subTitleLB.snp.makeConstraints({(make)in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLB.snp.bottom).offset(12)
            make.width.lessThanOrEqualToSuperview().offset(-12)
        })
        
        if(nativeAd.advertiser?.isEmpty == false){
            let adverLB = UIButton.init()
            adverLB.isUserInteractionEnabled = false
            adverLB.setTitle(nativeAd.advertiser, for: .normal)
            adverLB.setTitleColor(UIColor.clear, for: .normal)
            adverLB.titleLabel?.textAlignment = .center
            adverLB.titleLabel?.font = UIFont.systemFont(ofSize: 10)
            adverLB.contentEdgeInsets = .init(top: 2, left: 3, bottom:2, right: 3)
            nativeADView.addSubview(adverLB)
            adverLB.snp.makeConstraints({(make)in
                make.top.equalTo(mediaView.snp.top).offset(0)
                make.leading.equalTo(mediaView.snp.leading).offset(-0)
            })
        }
        
        let actionLB = UILabel()
        actionLB.text = nativeAd.callToAction ?? "Install"
        actionLB.textAlignment  = .center
        actionLB.textColor = UIColor.black
        actionLB.backgroundColor = UIColor.init(hex: "#b79efe")
        actionLB.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        actionLB.numberOfLines = 1
        actionLB.layer.cornerRadius = 14
        actionLB.layer.masksToBounds = true
        nativeADView.storeView = actionLB
        nativeADView.callToActionView?.isUserInteractionEnabled = true
        nativeADView.addSubview(actionLB)
        actionLB.snp.makeConstraints({(make)in
            make.centerX.equalToSuperview()
                make.top.equalTo(subTitleLB.snp.bottom).offset(42)
                make.height.equalTo(44)
                make.width.equalToSuperview().offset(-44)
        })
        actionLB.layoutIfNeeded()

        if let starRating = nativeAd.starRating {
            let starRatingLabel = UILabel()
            starRatingLabel.text = String(describing: starRating)
            starRatingLabel.textColor = .clear
            starRatingLabel.font = UIFont.systemFont(ofSize: 16)
            starRatingLabel.textAlignment = .right
            starRatingLabel.isUserInteractionEnabled = true;
        } else {
        }
        
        if(nativeAd.advertiser?.isEmpty == false && nativeAd.headline?.isEmpty == true){
            print("该广告没有提供????")
        }
        
        return nativeADView
    }
    
//class NativeAdFactory: FLTNativeAdFactory{
//    func createNativeAd(_ nativeAd: NativeAd, customOptions: [AnyHashable : Any]? = nil) -> NativeAdView? {
//
//        let nativeADView = NativeAdView.init()
//        nativeADView.nativeAd = nativeAd
//        nativeADView.backgroundColor = UIColor.clear
//        
//        let priceView = UILabel()
//        priceView.text = nativeAd.price
//        priceView.textColor = .white.withAlphaComponent(0.02)
//        priceView.font = UIFont.systemFont(ofSize: 12, weight: .bold)
//        priceView.textAlignment = .right
//        priceView.isUserInteractionEnabled = true
//        priceView.backgroundColor = .clear
//        nativeADView.priceView = priceView
//        nativeADView.addSubview(priceView)
//        priceView.snp.makeConstraints({(make)in
//            make.width.equalTo(45)
//            make.height.equalTo(45)
//            make.leading.equalToSuperview()
//            make.top.equalToSuperview()
//        })
//        
//        let mediaView = MediaView()
//        mediaView.mediaContent = nativeAd.mediaContent
//        mediaView.isUserInteractionEnabled = true
//        nativeADView.mediaView = mediaView
//        nativeADView.addSubview(mediaView)
//        if(nativeAd.mediaContent.hasVideoContent){
//            mediaView.contentMode = .scaleAspectFit
//            mediaView.snp.makeConstraints({(make)in
//                make.height.equalTo(261)
//                make.width.lessThanOrEqualToSuperview()
//                make.width.equalTo(mediaView.snp.height).multipliedBy(nativeAd.mediaContent.aspectRatio)
//                make.centerX.equalToSuperview()
//                make.top.equalTo(priceView.snp.bottom).offset(19)
//            })
//        }else{
//            mediaView.contentMode = .scaleAspectFit
//            mediaView.snp.makeConstraints({(make)in
//                make.centerX.equalToSuperview()
//                make.top.equalTo(priceView.snp.bottom).offset(19)
//                make.height.equalTo(261)
//                make.width.lessThanOrEqualToSuperview()
//            })
//        }
//        
//        
//        
//        let adChoicesView = AdChoicesView()
//        adChoicesView.translatesAutoresizingMaskIntoConstraints = false
//        nativeADView.addSubview(adChoicesView)
//        adChoicesView.snp.makeConstraints { make in
//            make.leading.equalToSuperview().offset(16) // 距离左边 16pt
//            make.top.equalToSuperview().offset(16)     // 距离顶部 16pt
//        }
//        
//
//        let iconADView = UIImageView()
//        iconADView.contentMode = .scaleToFill
//        iconADView.image = nativeAd.icon?.image
//        iconADView.isUserInteractionEnabled = true
//        iconADView.layer.cornerRadius = 5
//        iconADView.layer.masksToBounds = true
//        nativeADView.iconView = iconADView
//        nativeADView.addSubview(iconADView)
//        iconADView.snp.makeConstraints({(make)in
//            make.top.equalTo(mediaView.snp.bottom).offset(36)
//            make.width.height.equalTo(56)
//            make.centerX.equalToSuperview()
//        })
//        
//        let titleLB = UILabel()
//        titleLB.numberOfLines = 1
//        titleLB.text = nativeAd.headline
//        titleLB.textColor = UIColor.init(hex: "#fffffe")
//        titleLB.font = UIFont.systemFont(ofSize: 15)
//        titleLB.lineBreakMode = .byTruncatingTail
//        nativeADView.addSubview(titleLB)
//        nativeADView.headlineView = titleLB
//        titleLB.snp.makeConstraints({(make)in
//            make.centerX.equalToSuperview()
//            make.top.equalTo(iconADView.snp.bottom).offset(12)
//            make.width.lessThanOrEqualToSuperview().offset(-11)
//        })
//        
//        let subTitleLB = UILabel()
//        subTitleLB.text = nativeAd.body
//        subTitleLB.numberOfLines = 2
//        subTitleLB.textColor = UIColor.init(hex: "#fefefe")
//        subTitleLB.font = UIFont.systemFont(ofSize: 12)
//        subTitleLB.lineBreakMode = .byTruncatingTail
//        nativeADView.addSubview(subTitleLB)
//        nativeADView.bodyView = subTitleLB
//        subTitleLB.snp.makeConstraints({(make)in
//            make.centerX.equalToSuperview()
//            make.top.equalTo(titleLB.snp.bottom).offset(12)
//            make.width.lessThanOrEqualToSuperview().offset(-12)
//        })
//        
//        if(nativeAd.advertiser?.isEmpty == false){
//            let adverLB = UIButton.init()
//            adverLB.isUserInteractionEnabled = false
//            adverLB.setTitle(nativeAd.advertiser, for: .normal)
//            adverLB.setTitleColor(UIColor.clear, for: .normal)
//            adverLB.titleLabel?.textAlignment = .center
//            adverLB.titleLabel?.font = UIFont.systemFont(ofSize: 10)
//            adverLB.contentEdgeInsets = .init(top: 2, left: 3, bottom:2, right: 3)
//            nativeADView.addSubview(adverLB)
//            adverLB.snp.makeConstraints({(make)in
//                make.top.equalTo(mediaView.snp.top).offset(0)
//                make.leading.equalTo(mediaView.snp.leading).offset(-0)
//            })
//        }
//        
//        let actionLB = UILabel()
//        actionLB.text = nativeAd.callToAction ?? "Install"
//        actionLB.textAlignment  = .center
//        actionLB.textColor = UIColor.black
//        actionLB.backgroundColor = UIColor.init(hex: "#b79efe")
//        actionLB.font = UIFont.systemFont(ofSize: 15, weight: .bold)
//        actionLB.numberOfLines = 1
//        actionLB.layer.cornerRadius = 14
//        actionLB.layer.masksToBounds = true
//        nativeADView.storeView = actionLB
//        nativeADView.callToActionView?.isUserInteractionEnabled = true
//        nativeADView.addSubview(actionLB)
//        actionLB.snp.makeConstraints({(make)in
//            make.centerX.equalToSuperview()
//                make.top.equalTo(subTitleLB.snp.bottom).offset(42)
//                make.height.equalTo(44)
//                make.width.equalToSuperview().offset(-44)
//        })
//        actionLB.layoutIfNeeded()
//
//        if let starRating = nativeAd.starRating {
//            let starRatingLabel = UILabel()
//            starRatingLabel.text = String(describing: starRating)
//            starRatingLabel.textColor = .clear
//            starRatingLabel.font = UIFont.systemFont(ofSize: 16)
//            starRatingLabel.textAlignment = .right
//            starRatingLabel.isUserInteractionEnabled = true;
//        } else {
//        }
//        
//        if(nativeAd.advertiser?.isEmpty == false && nativeAd.headline?.isEmpty == true){
//            print("该广告没有提供????")
//        }
//        
//        return nativeADView
//    }
    
//    func createNativeAdOld(_ nativeAd: NativeAd, customOptions: [AnyHashable : Any]? = nil) -> NativeAdView? {
//        
//        let nativeADView = NativeAdView.init()
//        nativeADView.nativeAd = nativeAd
//        nativeADView.backgroundColor = UIColor.init(hex: "#f2f2f2")
//        
//        
//        let mediaBgView = UIView()
//        mediaBgView.backgroundColor = UIColor.init(hex: "#e4e4e4")
//        nativeADView.addSubview(mediaBgView)
//        mediaBgView.snp.makeConstraints({(make)in
//            make.leading.equalToSuperview()
//            make.trailing.equalToSuperview()
//            make.top.equalToSuperview().offset(2)
//            make.height.equalTo(172)
//        })
//        
//        
//        let mediaView = MediaView()
//        mediaView.mediaContent = nativeAd.mediaContent
//        mediaView.contentMode = .scaleAspectFill
//        mediaView.clipsToBounds = true
//        mediaBgView.addSubview(mediaView)
//        mediaView.snp.makeConstraints({(make)in
//            make.edges.equalToSuperview()
//        })
//        nativeADView.mediaView = mediaView
//        nativeADView.mediaView?.isHidden = false
//        
//        let adChoicesView = AdChoicesView()
//        adChoicesView.translatesAutoresizingMaskIntoConstraints = false
//        nativeADView.addSubview(adChoicesView)
//        adChoicesView.snp.makeConstraints { make in
//            make.leading.equalToSuperview().offset(16) // 距离左边 16pt
//            make.top.equalToSuperview().offset(16)     // 距离顶部 16pt
//        }
//        
//        
//        let iconADView = UIImageView()
//        iconADView.contentMode = .scaleToFill
//        iconADView.image = nativeAd.icon?.image
//        iconADView.alpha = 0.01
//        iconADView.isUserInteractionEnabled = true
//        iconADView.layer.cornerRadius = 20
//        iconADView.layer.masksToBounds = true
//        nativeADView.addSubview(iconADView)
//        iconADView.snp.makeConstraints({(make)in
//            //            make.leading.equalTo(mediaBgView.snp.leading).offset(12)
//            //            make.top.equalTo(mediaBgView.snp.bottom).offset(10)
//            make.trailing.equalTo(mediaBgView.snp.trailing).offset(0)
//            make.top.equalTo(mediaBgView.snp.top).offset(0)
//            make.width.height.equalTo(40).priority(999)
//        })
//        nativeADView.iconView = iconADView
//        
//        let titleLB = UILabel()
//        titleLB.text = nativeAd.headline
//        titleLB.numberOfLines = 1
//        titleLB.textColor = UIColor.init(hex: "#03011A")
//        titleLB.font = UIFont.systemFont(ofSize: 14)
//        titleLB.lineBreakMode = .byTruncatingTail
//        nativeADView.addSubview(titleLB)
//        titleLB.snp.makeConstraints({(make)in
//            //            make.leading.equalTo(iconADView.snp.trailing).offset(8)
//            //            make.top.equalTo(iconADView.snp.top).offset(3)
//            make.leading.equalTo(mediaBgView.snp.leading).offset(12)
//            make.top.equalTo(mediaBgView.snp.bottom).offset(10)
//            make.width.lessThanOrEqualTo(201)
//        })
//        nativeADView.headlineView = titleLB
//        titleLB.lineBreakMode = .byTruncatingTail
//        
//        let subTitleLB = UILabel()
//        subTitleLB.text = nativeAd.body
//        subTitleLB.numberOfLines = 1
//        subTitleLB.textColor = UIColor.init(hex: "#595959")
//        subTitleLB.font = UIFont.systemFont(ofSize: 12)
//        subTitleLB.lineBreakMode = .byTruncatingTail
//        nativeADView.addSubview(subTitleLB)
//        subTitleLB.snp.makeConstraints({(make)in
//            //            make.bottom.equalTo(iconADView.snp.bottom).offset(-3)
//            make.leading.equalTo(titleLB.snp.leading)
//            make.top.equalTo(titleLB.snp.bottom).offset(2)
//            make.width.lessThanOrEqualTo(201)
//        })
//        nativeADView.bodyView = subTitleLB
//        
//        if(nativeAd.advertiser?.isEmpty == false){
//            let adverLB = UIButton.init()
//            adverLB.isUserInteractionEnabled = false
//            adverLB.setTitle(nativeAd.advertiser, for: .normal)
//            adverLB.setTitleColor(UIColor.init(hex: "#141414"), for: .normal)
//            adverLB.titleLabel?.textAlignment = .center
//            adverLB.titleLabel?.font = UIFont.systemFont(ofSize: 10)
//            adverLB.contentEdgeInsets = .init(top: 2, left: 3, bottom:2, right: 3)
//            adverLB.backgroundColor = UIColor.init(hex: "#A5D1FF")
//            mediaBgView.addSubview(adverLB)
//            adverLB.snp.makeConstraints({(make)in
//                make.top.equalTo(mediaBgView.snp.top).offset(0)
//                make.leading.equalTo(mediaBgView.snp.leading).offset(-0)
//            })
//            nativeADView.advertiserView = adverLB;
//        }
//        
//        let actionLB = UILabel()
//        nativeADView.addSubview(actionLB)
//        actionLB.text = nativeAd.callToAction ?? "Install"
//        actionLB.textAlignment  = .center
//        actionLB.textColor = UIColor.white
//        actionLB.backgroundColor = UIColor.init(hex: "#8569FF")
//        actionLB.font = UIFont.systemFont(ofSize: 14, weight: .medium)
//        actionLB.numberOfLines = 1
//        actionLB.layer.cornerRadius = 20
//        actionLB.layer.masksToBounds = true
//        actionLB.snp.makeConstraints({(make)in
//            make.leading.equalToSuperview().offset(16)
//            make.trailing.equalToSuperview().offset(-16)
//            make.top.equalTo(subTitleLB.snp.bottom).offset(20)
//            make.height.equalTo(40)
//        })
//        actionLB.layoutIfNeeded()
//        nativeADView.storeView = actionLB
//        nativeADView.callToActionView?.isUserInteractionEnabled = true
//        
//        if let starRating = nativeAd.starRating {
//            let starRatingLabel = UILabel()
//            starRatingLabel.text = String(describing: starRating) // "4.5"
//            starRatingLabel.textColor = .clear//UIColor(hex: "#FFA500")  //，和 App Store 一致
//            starRatingLabel.font = UIFont.systemFont(ofSize: 16)
//            starRatingLabel.textAlignment = .right
//            starRatingLabel.isUserInteractionEnabled = true;
//            
//            nativeADView.addSubview(starRatingLabel)
//            
//            starRatingLabel.snp.makeConstraints { make in
////                make.top.equalTo(nativeADView.snp.top).offset(16)
////                make.trailing.equalTo(nativeADView.snp.trailing).offset(-16)
//            }
//        } else {
//            print("该广告没有提供星级评分")
//        }
//        
//        return nativeADView
//    }
    
    
}
