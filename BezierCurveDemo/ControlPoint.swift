//
//  ControlPoint.swift
//  BezierCurveDemo
//
//  Created by Felipe Hernandez on 5/22/17.
//  Copyright © 2017 Felipe Hernandez. All rights reserved.
//

import UIKit
//Creates a view that will represent a control point.
class ControlPoint: UIView {

    init() {
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: 8.0, height: 8.0))
        self.layer.cornerRadius = 4.0
        self.backgroundColor = .red
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func controlPointCenter(_ shouldUsePresentationLayer: Bool) -> CGPoint {
        if shouldUsePresentationLayer, let presentationLayer = layer.presentation() {
            return presentationLayer.position
        }
        return center
    }

}
