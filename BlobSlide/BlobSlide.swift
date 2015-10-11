//
//  BlobSlide.swift
//  BlobSlide
//
//  Created by Jakub Knejzlik on 11/10/15.
//  Copyright © 2015 Jakub Knejzlik. All rights reserved.
//

import UIKit

protocol ObservingViewDelegate {
    func observinViewDidUpdateCenter(observingView: ObservingView)
}
class ObservingView : UIView {
    private var delegate: ObservingViewDelegate?
    override var center: CGPoint {
        didSet {
            delegate?.observinViewDidUpdateCenter(self)
        }
    }
}

class BlobSlide: UIControl, ObservingViewDelegate {

    var animator: UIDynamicAnimator?
    var dragAttachment: UIAttachmentBehavior
    
    var trackingTouch: UITouch?
    var startingOffest: CGPoint = CGPointZero
    
    private let handle: ObservingView = {
        let view = ObservingView.init(frame: CGRectMake(0, 0, 60, 40))
        view.backgroundColor = UIColor.clearColor()
        return view
    }()
    
    required init?(coder aDecoder: NSCoder) {
        dragAttachment = UIAttachmentBehavior.init(item: handle, attachedToAnchor: CGPointZero)
        dragAttachment.length = 0
        
        super.init(coder: aDecoder)

        let height = CGRectGetHeight(bounds)
        let width = CGRectGetWidth(bounds)
        
        handle.center = CGPointMake(CGRectGetWidth(handle.bounds)/2, height/2)
        handle.delegate = self
        addSubview(handle)

        let _animator = UIDynamicAnimator.init(referenceView: self)
        animator = _animator

        let attachment = UIAttachmentBehavior.init(item: handle, attachedToAnchor: CGPointMake(handle.center.x, 0))
        attachment.damping = 0.6
        attachment.frequency = 2
        _animator.addBehavior(attachment)

        let attachment2 = UIAttachmentBehavior.init(item: handle, attachedToAnchor: CGPointMake(handle.center.x, height))
        attachment2.damping = 0.6
        attachment2.frequency = 2
        _animator.addBehavior(attachment2)

        let attachment3 = UIAttachmentBehavior.init(item: handle, attachedToAnchor: handle.center.moveBy(width, y: 0))
        attachment3.damping = 0.1
        attachment3.frequency = 3
        _animator.addBehavior(attachment3)
        let attachment4 = UIAttachmentBehavior.init(item: handle, attachedToAnchor: handle.center.moveBy(-width, y: 0))
        attachment4.damping = 0.1
        attachment4.frequency = 3
        _animator.addBehavior(attachment4)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var frame = handle.frame
        frame.size.height = CGRectGetHeight(bounds)
        handle.frame = frame
    }
    
    override func drawRect(rect: CGRect) {

        UIColor.redColor().setFill()
        UIColor.redColor().setStroke()
        let path = UIBezierPath()
        
        let height = CGRectGetHeight(bounds)
        let leftTop = CGPointZero
        let leftBottom = CGPointMake(0, height)
        
        path.moveToPoint(leftTop)
        path.addLineToPoint(leftTop.moveBy(10, y: 0))
        path.addCurveToPoint(handle.center, controlPoint1: leftTop.moveBy(10, y: 0).moveBy(-10, y: height/2), controlPoint2: handle.center.moveBy(0, y: -height/3.3))
        path.addCurveToPoint(leftBottom.moveBy(10, y: 0), controlPoint1: handle.center.moveBy(0, y: height/3.3), controlPoint2: leftBottom.moveBy(10, y: 0).moveBy(-10, y: -height/2))
        path.addLineToPoint(leftBottom)
        path.closePath()
        
        path.stroke()
        path.fill()
        
    }
    
    func observinViewDidUpdateCenter(observingView: ObservingView) {
        self.setNeedsDisplay()
    }
    func updateDragLocation() {
        if let trackingTouch = trackingTouch {
            var location = trackingTouch.locationInView(self).moveBy(-startingOffest.x, y: 0)
            location.y = CGRectGetHeight(bounds) / 2
            location.x = min(max(location.x, 0),CGRectGetWidth(bounds))
            dragAttachment.anchorPoint = location
        }
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches where CGRectContainsPoint(handle.frame, touch.locationInView(self)) {
            trackingTouch = touch
            animator?.addBehavior(dragAttachment)
            startingOffest = touch.locationInView(handle).moveBy(-CGRectGetWidth(handle.bounds)/2, y: -CGRectGetHeight(handle.bounds)/2)
            break
        }
        updateDragLocation()
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        updateDragLocation()
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = trackingTouch, let animator = animator where touches.contains(touch) {
            trackingTouch = nil
            startingOffest = CGPointZero
            animator.removeBehavior(dragAttachment)
        }
    }
}
