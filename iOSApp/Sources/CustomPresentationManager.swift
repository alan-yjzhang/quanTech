//
//  CustomPresentationManager.swift
//  eduDemo
//
//  Created by Alan Zhang on 4/13/17.
//  Copyright © 2017 Alan Zhang. All rights reserved.
//

import Foundation
import UIKit
enum PresentationDirection {
    case left
    case top
    case right
    case bottom
}

final class SlideInPresentationManager: NSObject {
    
    // MARK: - Properties
    var direction = PresentationDirection.left
    var disableCompactHeight = false
    var presentedViewEdgeInset = UIEdgeInsets.zero
}

// MARK: - UIViewControllerTransitioningDelegate
extension SlideInPresentationManager: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = SlideInPresentationController(presentedViewController: presented, presenting: presenting, direction: direction)
        presentationController.delegate = self
        presentationController.viewEdgeInset = presentedViewEdgeInset
        return presentationController
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideInPresentationAnimator(direction: direction, isPresentation: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideInPresentationAnimator(direction: direction, isPresentation: false)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension SlideInPresentationManager: UIAdaptivePresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        if traitCollection.verticalSizeClass == .compact && disableCompactHeight {
            return .overFullScreen
        } else {
            return .none
        }
    }
    
    func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        guard case(.overFullScreen) = style else { return nil }
        
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RotateViewController")
    }
}


