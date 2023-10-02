//
//  UIView+Extension.swift
//  ConcurrentAPICaller
//
//  Created by Bitmorpher 4 on 8/30/23.
//

import UIKit


extension UIView {
    func pushTransition(_ duration: CFTimeInterval) {
        let animation:CATransition = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
                                                            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.push
        animation.subtype = CATransitionSubtype.fromTop
        animation.duration = duration
        
        self.layer.add(animation, forKey: "transition")
    }
}
