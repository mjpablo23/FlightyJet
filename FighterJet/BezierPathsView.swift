//
//  BezierPathsView.swift
//  FighterJet
//
//  Created by Paul Yang on 5/4/15.
//  Copyright (c) 2015 Paul Yang. All rights reserved.
//

import UIKit

class BezierPathsView: UIView {

    private var bezierPaths = [String:UIBezierPath]()
    private var pathFillColor = [String:UIColor]()
    private var pathStrokeColor = [String:UIColor]()
    
    func setPath(path: UIBezierPath?, named name: String, fillcolor: UIColor, strokecolor: UIColor) {
        bezierPaths[name] = path
        pathFillColor[name] = fillcolor
        pathStrokeColor[name] = strokecolor
        setNeedsDisplay()
    }
    
    func removePath(named name: String) {
        bezierPaths.removeValueForKey(name)
        setNeedsDisplay()
    }
    
    var fillColor: UIColor = UIColor.blueColor()
    var strokeColor: UIColor = UIColor.redColor()
    
    func setTheFillColor(color: UIColor) {
        fillColor = color
    }
    
    func setTheStrokeColor(color: UIColor) {
        strokeColor = color
    }
    
    override func drawRect(rect: CGRect) {
        // drawing code
        for (name, path) in bezierPaths {
            
            //UIColor.greenColor().setFill()
            pathFillColor[name]?.setFill()
            // fillColor.setFill()
            
            //UIColor.redColor().setStroke()
            pathStrokeColor[name]?.setStroke()
            // strokeColor.setStroke()
            
            path.lineWidth = 0.5
            path.stroke()
            
            if name != "Walls" {
//                path.fill()
//              good: kCGBlendModeMultiply
                // path.fillWithBlendMode(kCGBlendModeDarken, alpha: 0.75)
                path.fillWithBlendMode(CGBlendMode.Darken, alpha: 0.75)
            }
        }
        
        self.backgroundColor = UIColor.clearColor()
    }


}
