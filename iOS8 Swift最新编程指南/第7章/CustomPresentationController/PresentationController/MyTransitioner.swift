//
//  MyTransitioner.swift
//  PresentationController
//
//  Created by yanghongyan on 14/10/30.
//  Copyright (c) 2014年 yanghongyan. All rights reserved.
//

import UIKit

class MyTransitioner: NSObject,UIViewControllerAnimatedTransitioning {
    var isPresentation : Bool = false
    func transitionDuration(
        transitionContext: UIViewControllerContextTransitioning)
        -> NSTimeInterval {
        return 0.5
    }
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
            let fromViewController = transitionContext.viewControllerForKey(
            UITransitionContextFromViewControllerKey)
            let fromView = fromViewController!.view
            let toViewController =
            transitionContext.viewControllerForKey( UITransitionContextToViewControllerKey)
            let toView = toViewController!.view
            
            var containerView: UIView = transitionContext.containerView()
            if isPresentation {
        containerView.addSubview(toView)
            }
            
            // 1
            var animatingViewController = isPresentation ? toViewController : fromViewController
            var animatingView = animatingViewController!.view
            // 2
            var appearedFrame =
            transitionContext.finalFrameForViewController( animatingViewController!)
            var dismissedFrame = appearedFrame
            dismissedFrame.origin.y += dismissedFrame.size.height
            // 3
            let initialFrame = isPresentation ? dismissedFrame :
            appearedFrame
            let finalFrame = isPresentation ? appearedFrame : dismissedFrame
            animatingView.frame = initialFrame
            
            UIView.animateWithDuration( transitionDuration(transitionContext), delay:0.0, usingSpringWithDamping:300.0,
                initialSpringVelocity:5.0, options:UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState, animations:{
                animatingView.frame = finalFrame }, completion:{ (value: Bool) in
                if !self.isPresentation {
                fromView.removeFromSuperview()
                }
                transitionContext.completeTransition(true) })
    }
}
class MyTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController( presented: UIViewController!,
        presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController!)
        -> UIPresentationController! {
            let presentationController = MyPresentationController(
                presentedViewController:presented, presentingViewController:presenting)
            return presentationController
    }
    func animationControllerForPresentedController( presented: UIViewController!,
        presentingController presenting: UIViewController!, sourceController source: UIViewController!)
        -> UIViewControllerAnimatedTransitioning! {
        var animationController = MyTransitioner()
        animationController.isPresentation = true
        return animationController
    }
    func animationControllerForDismissedController( dismissed: UIViewController!)
            -> UIViewControllerAnimatedTransitioning! {
            var animationController = MyTransitioner()
            animationController.isPresentation = false
            return animationController
    }
}





