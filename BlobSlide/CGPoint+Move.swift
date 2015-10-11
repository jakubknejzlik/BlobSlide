//
//  CGPoint+Move.swift
//  BlobSlide
//
//  Created by Jakub Knejzlik on 11/10/15.
//  Copyright © 2015 Jakub Knejzlik. All rights reserved.
//

import CoreGraphics

extension CGPoint {
    func moveBy(x: CGFloat, y: CGFloat) -> CGPoint {
        return CGPointMake(self.x + x, self.y + y)
    }
}