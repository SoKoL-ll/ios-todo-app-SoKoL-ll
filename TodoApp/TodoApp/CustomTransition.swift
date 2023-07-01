//
//  CustomTransition.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 01.07.2023.
//

import Foundation
import UIKit

class CustomTransition: NSObject, UIViewControllerAnimatedTransitioning {
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.5
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard let toView = transitionContext.view(forKey: .to) else { return }
    
    let containerView = transitionContext.containerView
    containerView.addSubview(toView)
    
    toView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
    
    UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
      toView.transform = CGAffineTransform.identity
    }) { _ in
      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }
  }
  
}

