//
//  AppDelegate.swift
//  UniversalLinks2
//
//  Created by 최혜선 on 2020/04/10.
//  Copyright © 2020 jamie. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        return true
    }
    
    // iOS 9 이상 버전에 앱을 이미 설치했다면 application:continueUserActivity:restorationHandler: 메서드에서 범용 링크로 수신된 링크를 처리합니다.
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        print("AppDelegate - continue userActivity")
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL else {
                return false
        }
        
        print("url : \(url)")
        
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            let path = components.path
            print("path : \(path)")
        }
        
        guard let rootViewController = window?.rootViewController, let viewController = rootViewController as? ViewController else {
            return false
        }
        
        viewController.URLLabel.text = url.absoluteString
        
        // Firebase Dynamic Link
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(url) { (dynamiclink, error) in
            guard let url = dynamiclink?.url else {
                return
            }
            
            print("dynamic link \(url.absoluteString)")
        }
        
        return handled
    }

    // 메서드에서 앱의 커스텀 URL 스키마를 통해 수신된 링크를 처리합니다. 이 메서드는 iOS 8 이하의 경우에는 앱이 링크를 수신할 때, 그리고 iOS 버전에 상관없이 앱을 설치한 후 처음으로 열었을 때 호출됩니다.
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("open url 함수 실행 \(url)")
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
            
            guard dynamicLink.url?.description != nil && dynamicLink.url != nil else {
                return false
            }
            if let scheme = url.scheme {
                if scheme == "https" {
                    //딥링크 구현
                    print("딥링크")
                    guard let rootViewController = window?.rootViewController, let viewController = rootViewController as? ViewController else {
                        return false
                    }
                    
                    viewController.isDynamicLink.text = "open url 함수 실행 \(url.absoluteString)"
                }
            }
             
        }
        return true
    }
}

