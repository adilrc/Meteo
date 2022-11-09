//
//  RootTabBarController.swift
//  Meteo
//
//  Created by Adil Erchouk on 11/5/22.
//

import Combine
import UIKit

/// The root view controller is a tab bar controller.
final class RootViewController: UITabBarController {

    private func setupTabBar() {
        delegate = self
        viewControllers = AppTab.allCases.map {
            let rootViewController = $0.makeRootViewController()

            let navigationViewController = UINavigationController(rootViewController: rootViewController)

            navigationViewController.tabBarItem.title = $0.title
            navigationViewController.tabBarItem.image = $0.image

            return navigationViewController
        }
    }

    private var subscriptions = Set<AnyCancellable>()

    private func setupListeners() {
        NotificationCenter.default.publisher(for: .userDidSelectLocation)
            .sink { [weak self] _ in
                self?.selectedIndex = 0
            }
            .store(in: &subscriptions)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupListeners()
    }
}

extension RootViewController: UITabBarControllerDelegate {
    func tabBarController(
        _ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        UIView.transition(from: fromVC.view, to: toVC.view, duration: 0.4, options: [.transitionCrossDissolve], completion: nil)
        return nil
    }
}
