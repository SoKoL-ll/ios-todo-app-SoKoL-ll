//
//  CustomTransitionDelegate.swift
//  TodoApp
//
//  Created by Alexandr Sokolov on 01.07.2023.
//

import Foundation
import UIKit

class CustomTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return CustomTransition()
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return CustomTransition()
  }
  
}
