//
//  FacebookAudienceNetworkRewardedAd.swift
//  facebook_audience_network
//
//  Created by xiaolit on 2023/6/14.
//

import Foundation
import Flutter
import FBAudienceNetwork

class FacebookAudienceNetworkRewardedAdPlugin: NSObject, FBRewardedVideoAdDelegate {
    let channel: FlutterMethodChannel
    var rewardedAd: FBRewardedVideoAd!
    
    init(_channel: FlutterMethodChannel) {
//        print("FacebookAudienceNetworkRewardedAdPlugin > init")
        
        channel = _channel
        
        super.init()
        
        channel.setMethodCallHandler { (call, result) in
            switch call.method{
            case "loadRewardedAd":
//                print("FacebookAudienceNetworkInterstitialAdPlugin > loadInterstitialAd")
                result(self.loadAd(call))
            case "showRewardedAd":
//                print("FacebookAudienceNetworkInterstitialAdPlugin > showInterstitialAd")
                result(self.showAD(call))
            case "destroyRewardedAd":
//                print("FacebookAudienceNetworkInterstitialAdPlugin > destroyInterstitialAd")
                result(self.destroyAd())
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
//        print("FacebookAudienceNetworkRewardedAdPlugin > init > end")
    }
    
    
    func loadAd(_ call: FlutterMethodCall) -> Bool {
        if nil == self.rewardedAd || !self.rewardedAd.isAdValid {
//            print("FacebookAudienceNetworkRewardedAdPlugin > loadAd > create")
            let args: NSDictionary = call.arguments as! NSDictionary
            let id: String = args["id"] as! String
            self.rewardedAd = FBRewardedVideoAd.init(placementID: id)
            self.rewardedAd.delegate = self
        }
        self.rewardedAd.load()
        return true
    }
    
    func showAD(_ call: FlutterMethodCall) -> Bool {
        if !self.rewardedAd.isAdValid {
//            print("FacebookAudienceNetworkRewardedAdPlugin > showAD > not AdVaild")
            return false
        }
        let args: NSDictionary = call.arguments as! NSDictionary
        let delay: Int = args["delay"] as! Int
        
        //MARK:- Need to remove because it' already called with delay.
        //self.interstitialAd.show(fromRootViewController: UIApplication.shared.keyWindow?.rootViewController)
        
//        print("@@@ delay %d", delay)
        
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return false
        }
        // If your deployment target is earlier than iOS 13
        guard let rootViewController = window.rootViewController else {
            return false
        }
        
        if 0 < delay {
            let time = DispatchTime.now() + .seconds(delay)
            DispatchQueue.main.asyncAfter(deadline: time) {
//                self.rewardedAd.show
                self.rewardedAd.show(fromRootViewController: rootViewController)
            }
        } else {
            self.rewardedAd.show(fromRootViewController: rootViewController)
        }
        return true
    }
    
    func destroyAd() -> Bool {
        if nil == self.rewardedAd {
            return false
        } else {
            rewardedAd.delegate = nil
            rewardedAd = nil
        }
        return true
    }
    
    func rewardedVideoAdVideoComplete(_ rewardedVideoAd: FBRewardedVideoAd) {
//        print("RewardedVideoAdView > rewardedVideoAdVideoComplete")
        
        let placement_id: String = rewardedVideoAd.placementID
        let invalidated: Bool = rewardedVideoAd.isAdValid
        let arg: [String: Any] = [
            FANConstant.PLACEMENT_ID_ARG: placement_id,
            FANConstant.INVALIDATED_ARG: invalidated,
        ]
        self.channel.invokeMethod(FANConstant.REWARDED_COMPLETE_METHOD, arguments: arg)
    }
    
    
    func rewardedVideoAdDidClick(_ rewardedVideoAd: FBRewardedVideoAd) {
//        print("RewardedVideoAdView > rewardedVideoAdDidClick")
        
        let placement_id: String = rewardedVideoAd.placementID
        let invalidated: Bool = rewardedVideoAd.isAdValid
        let arg: [String: Any] = [
            FANConstant.PLACEMENT_ID_ARG: placement_id,
            FANConstant.INVALIDATED_ARG: invalidated,
        ]
        self.channel.invokeMethod(FANConstant.CLICKED_METHOD, arguments: arg)
    }
    
    func rewardedVideoAdDidClose(_ rewardedVideoAd: FBRewardedVideoAd) {
//        print("RewardedVideoAdView > rewardedVideoAdDidClose")
        //Add event for RewardedAd dismissed.
        let placement_id: String = rewardedVideoAd.placementID
        let invalidated: Bool = rewardedVideoAd.isAdValid
        let arg: [String: Any] = [
            FANConstant.PLACEMENT_ID_ARG: placement_id,
            FANConstant.INVALIDATED_ARG: invalidated,
        ]
        self.channel.invokeMethod(FANConstant.REWARDED_CLOSED_METHOD, arguments: arg)
    }
    
    func rewardedVideoAdWillClose(_ rewardedVideoAd: FBRewardedVideoAd) {
//        print("RewardedAdView > rewardedVideoAdWillClose")
    }
    
    func rewardedVideoAdDidLoad(_ rewardedVideoAd: FBRewardedVideoAd) {
//        print("RewardedVideoAdView > rewardedVideoAdDidLoad")
        
        let placement_id: String = rewardedVideoAd.placementID
        let invalidated: Bool = rewardedVideoAd.isAdValid
        let arg: [String: Any] = [
            FANConstant.PLACEMENT_ID_ARG: placement_id,
            FANConstant.INVALIDATED_ARG: invalidated,
        ]
        self.channel.invokeMethod(FANConstant.LOADED_METHOD, arguments: arg)
    }
    
    func rewardedVideoAd(_ rewardedVideoAd: FBRewardedVideoAd, didFailWithError error: Error) {
//        print("RewardedVideoAdView > rewardedVideoAd failed")
//        print(error.localizedDescription)
        
        let placement_id: String = rewardedVideoAd.placementID
        let invalidated: Bool = rewardedVideoAd.isAdValid
        let errorStr: String = error.localizedDescription
        let arg: [String: Any] = [
            FANConstant.PLACEMENT_ID_ARG: placement_id,
            FANConstant.INVALIDATED_ARG: invalidated,
            FANConstant.ERROR_ARG:errorStr,
        ]
        self.channel.invokeMethod(FANConstant.ERROR_METHOD, arguments: arg)
    }
    
    func rewardedVideoAdServerRewardDidFail(_ rewardedVideoAd: FBRewardedVideoAd) {
//        print("RewardedVideoAdView > rewardedVideoAd failed")
        
        let placement_id: String = rewardedVideoAd.placementID
        let invalidated: Bool = rewardedVideoAd.isAdValid
        let arg: [String: Any] = [
            FANConstant.PLACEMENT_ID_ARG: placement_id,
            FANConstant.INVALIDATED_ARG: invalidated,
        ]
        self.channel.invokeMethod(FANConstant.ERROR_METHOD, arguments: arg)
    }
    
    func rewardedVideoAdWillLogImpression(_ rewardedVideoAd: FBRewardedVideoAd) {
//        print("RewardedVideoAdView > rewardedVideoAdWillLogImpression")
        
        let placement_id: String = rewardedVideoAd.placementID
        let invalidated: Bool = rewardedVideoAd.isAdValid
        let arg: [String: Any] = [
            FANConstant.PLACEMENT_ID_ARG: placement_id,
            FANConstant.INVALIDATED_ARG: invalidated,
        ]
        self.channel.invokeMethod(FANConstant.LOGGING_IMPRESSION_METHOD, arguments: arg)
    }
}
