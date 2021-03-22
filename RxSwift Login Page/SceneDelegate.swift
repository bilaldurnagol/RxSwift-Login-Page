//
//  SceneDelegate.swift
//  RxSwift Login Page
//
//  Created by Bilal Durnagöl on 22.03.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let winScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: winScene)
        appCoordinator = AppCoordinator(window: window)
        appCoordinator?.start()
    }
}

