//
//  ViewController.swift
//  BezierCurveDemo
//
//  Created by Felipe Hernandez on 5/22/17.
//  Copyright © 2017 Felipe Hernandez. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    //isAnimating: indicates if the curve is being animated.
    fileprivate var isAnimating = false {
        didSet {
            view.isUserInteractionEnabled = !isAnimating
            displayLink.isPaused = !isAnimating
        }
    }
    
    //minHeight: defines the minimum height of the view above the curve
    fileprivate let minHeight: CGFloat = 200.0
    //maxCurveHeight: defines the max height for the curve. If the value is too big we can get undessired results.
    fileprivate let maxCurveHeight: CGFloat = 150.0
    //shapeLayer:The layer where the curve will be placed in
    fileprivate var shapeLayer: CAShapeLayer!
    //displayLink: timer object that allows your application to synchronize its drawing to the refresh rate of the display
    fileprivate var displayLink: CADisplayLink!
    //ControlPoints: the control points that handle the curve
    fileprivate let leftControlPoint1 = ControlPoint()
    fileprivate let leftControlPoint2 = ControlPoint()
    fileprivate let leftControlPoint3 = ControlPoint()
    fileprivate let centerControlPoint = ControlPoint()
    fileprivate let rightControlPoint1 = ControlPoint()
    fileprivate let rightControlPoint2 = ControlPoint()
    fileprivate let rightControlPoint3 = ControlPoint()
    
    
    override func loadView() {
        super.loadView()
        initializeViews()
        updateShapeLayer()
        displayLink = CADisplayLink(target: self, selector: #selector(ViewController.updateShapeLayer))
        displayLink.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        displayLink.isPaused = true
    }
    
    //Initilize all the necessary views to draw the curve.
    func initializeViews() {
        shapeLayer = CAShapeLayer(layer: CGRect(x: 0.0, y: 0.0, width: view.bounds.width, height: minHeight))
        shapeLayer.fillColor = UIColor.gray.cgColor
        //To avoid animation delay, we should disable implicit animations for the keys: position, bounds & path.
        shapeLayer.actions = ["position" : NSNull(), "bounds" : NSNull(), "path" : NSNull()]
        view.layer.addSublayer(shapeLayer)
        //Add a gesture that recognize when user drags the curve.
        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(ViewController.panDidMove(_:))))
        view.addSubview(leftControlPoint3)
        view.addSubview(leftControlPoint2)
        view.addSubview(leftControlPoint1)
        view.addSubview(centerControlPoint)
        view.addSubview(rightControlPoint1)
        view.addSubview(rightControlPoint2)
        view.addSubview(rightControlPoint3)
        //Renderize all of the control points previously added in the view.
        renderControlPoints(baseHeight: minHeight, curveHeight: 0.0, locationX: view.bounds.width / 2.0)
    }

    //Fired when the user drags the pan.
    func panDidMove(_ gesture: UIPanGestureRecognizer) {
        //If the gesture is ended, failed or cancelled, then animate the curve to its initial position.
        if gesture.state == .ended || gesture.state == .failed || gesture.state == .cancelled {
            isAnimating = true
            UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 1, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
                self.leftControlPoint3.center.y = self.minHeight
                self.leftControlPoint2.center.y = self.minHeight
                self.leftControlPoint1.center.y = self.minHeight
                self.centerControlPoint.center.y = self.minHeight
                self.rightControlPoint1.center.y = self.minHeight
                self.rightControlPoint2.center.y = self.minHeight
                self.rightControlPoint3.center.y = self.minHeight
            }, completion: { _ in
                self.isAnimating = false
            })
        } else {
            let additionalHeight = max(gesture.translation(in: view).y, 0)
            let waveHeight = min(additionalHeight * 0.6, maxCurveHeight)
            let baseHeight = minHeight + additionalHeight - waveHeight
            //locationX: the position of the user's finger in the screen.
            let locationX = gesture.location(in: gesture.view).x
            //Renderize all of the control points considering the updated locationX
            renderControlPoints(baseHeight: baseHeight, curveHeight: waveHeight, locationX: locationX)
            updateShapeLayer()
        }
    }
    
    //Renderize all of the control points based in a height a height for the curve and a location.
    fileprivate func renderControlPoints(baseHeight: CGFloat, curveHeight: CGFloat, locationX: CGFloat) {
        let width = view.bounds.width
        let minLeftX = min((locationX - width / 2.0) * 0.28, 0.0)
        let maxRightX = max(width + (locationX - width / 2.0) * 0.28, width)
        let leftPartWidth = locationX - minLeftX
        let rightPartWidth = maxRightX - locationX
        
        leftControlPoint3.center = CGPoint(x: minLeftX, y: baseHeight)
        leftControlPoint2.center = CGPoint(x: minLeftX + leftPartWidth * 0.44, y: baseHeight)
        leftControlPoint1.center = CGPoint(x: minLeftX + leftPartWidth * 0.71, y: baseHeight + curveHeight * 0.64)
        centerControlPoint.center = CGPoint(x: locationX , y: baseHeight + curveHeight * 1.36)
        rightControlPoint1.center = CGPoint(x: maxRightX - rightPartWidth * 0.71, y: baseHeight + curveHeight * 0.64)
        rightControlPoint2.center = CGPoint(x: maxRightX - (rightPartWidth * 0.44), y: baseHeight)
        rightControlPoint3.center = CGPoint(x: maxRightX, y: baseHeight)
    }
    
    //Updates the curve's path.
    func updateShapeLayer() {
        shapeLayer.path = currentPath()
    }
    
    //The current path will be updated as much as the user moves the finger across the pan.
    fileprivate func currentPath() -> CGPath {
        let width = view.bounds.width
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 0.0, y: 0.0))
        bezierPath.addLine(to: CGPoint(x: 0.0, y: leftControlPoint3.controlPointCenter(isAnimating).y))
        bezierPath.addCurve(to: leftControlPoint1.controlPointCenter(isAnimating), controlPoint1: leftControlPoint3.controlPointCenter(isAnimating), controlPoint2: leftControlPoint2.controlPointCenter(isAnimating))
        bezierPath.addCurve(to: rightControlPoint1.controlPointCenter(isAnimating), controlPoint1: centerControlPoint.controlPointCenter(isAnimating), controlPoint2: rightControlPoint1.controlPointCenter(isAnimating))
        bezierPath.addCurve(to: rightControlPoint3.controlPointCenter(isAnimating), controlPoint1: rightControlPoint1.controlPointCenter(isAnimating), controlPoint2: rightControlPoint2.controlPointCenter(isAnimating))
        bezierPath.addLine(to: CGPoint(x: width, y: 0.0))
        bezierPath.close()
        
        return bezierPath.cgPath
    }
    
}
