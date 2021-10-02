//
//  Extensions.swift
//  IssoWade
//
//  Created by Kaveen Suraweera on 2021-10-02.
//

import Foundation
import UIKit

extension UIView {
    public var width: CGFloat {
        return self.frame.size.width
    }
}

extension UIView {
    public var height: CGFloat {
        return self.frame.size.height
    }
}

extension UIView {
    public var top: CGFloat {
        return self.frame.origin.y
    }
}

extension UIView {
    public var bottom: CGFloat {
        return self.frame.size.height + self.frame.origin.y
    }
}

extension UIView {
    public var left: CGFloat {
        return self.frame.origin.x
    }
}

extension UIView {
    public var right: CGFloat {
        return self.frame.size.width + self.frame.origin.x
    }
}
