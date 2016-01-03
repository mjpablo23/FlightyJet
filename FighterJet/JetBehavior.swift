//
//  JetBehavior.swift
//  FighterJet
//
//  Created by Paul Yang on 5/4/15.
//  Copyright (c) 2015 Paul Yang. All rights reserved.
//

import UIKit

class JetBehavior: UIDynamicBehavior {
    
    // MARK: - dynamic behaviors
    let gravity = UIGravityBehavior()
    
    var push: UIPushBehavior?
    var pushItem: UIPushBehavior?
    
    lazy var collider: UICollisionBehavior = {
        let lazilyCreatedCollider = UICollisionBehavior()
        lazilyCreatedCollider.translatesReferenceBoundsIntoBoundary = false
        lazilyCreatedCollider.collisionMode = UICollisionBehaviorMode.Everything
        return lazilyCreatedCollider
        }()
    
    lazy var bounceBehavior: UIDynamicItemBehavior = {
        let lazilyCreatedpaddleBehavior = UIDynamicItemBehavior()
        lazilyCreatedpaddleBehavior.allowsRotation = false
        lazilyCreatedpaddleBehavior.elasticity = 0.05
        return lazilyCreatedpaddleBehavior
        }()
    
    
    
    override init() {
        super.init()
        
        var magnitude:CGFloat = 1.1  // iphone 5
        
        if (DeviceVersion.DeviceType.IS_IPHONE_4_OR_LESS) {
            magnitude = Constants.Magnitudes.gravityMagnitudes[0]
        }
        else if (DeviceVersion.DeviceType.IS_IPHONE_5) {
            magnitude = Constants.Magnitudes.gravityMagnitudes[1]
        }
        else if (DeviceVersion.DeviceType.IS_IPHONE_6) {
            magnitude = Constants.Magnitudes.gravityMagnitudes[2]
        }
        else if (DeviceVersion.DeviceType.IS_IPHONE_6P) {
            magnitude = Constants.Magnitudes.gravityMagnitudes[3]
        }
        
        gravity.magnitude = magnitude // 0.9 // 0.10
        //        collider.action = { ()->Void in
        // println("collider action")
        //        }
        addChildBehavior(gravity)
        addChildBehavior(collider)
        addChildBehavior(bounceBehavior)
        // addChildBehavior(push)
    }
    
    // MARK: - jet behavior

    func addJet(jet: UIImageView) {
        dynamicAnimator?.referenceView?.addSubview(jet)
        collider.addItem(jet)
        bounceBehavior.addItem(jet)
        
        push = UIPushBehavior(items: [jet], mode: UIPushBehaviorMode.Instantaneous)
        addChildBehavior(push!)
        
        push!.addItem(jet)
        
        //print("current magnitude: \(gravity.magnitude)")
        
        gravity.addItem(jet)
    }
    
    var piVal: CGFloat = 3.145926
    
    func pushJetUp(jet: UIView) {
        var deg: CGFloat = 95 // 89.85
        pushJetAtAngle(jet, angle: piVal*(-deg/180))
    }
    
    func pushJetAtAngle(jet: UIView, angle: CGFloat) {
        push!.removeItem(jet)
        
        // try removing and adding the jet to stop it from moving (doesn't work)
//        removeJet(jet as UIImageView)
//        addJet(jet as UIImageView)
//         UIDynamicItemBehavior.linearVelocityForItem(jet.)
        var currentVelocity:CGPoint = bounceBehavior.linearVelocityForItem(jet)
        var negVelocity: CGPoint = CGPointMake(-currentVelocity.x, -currentVelocity.y)
        bounceBehavior.addLinearVelocity(negVelocity, forItem: jet)
        
        push = UIPushBehavior(items: [jet], mode: UIPushBehaviorMode.Instantaneous)
        addChildBehavior(push!)
        
        var magnitude:CGFloat = 1.0
        
        // push up magnitude
        if (DeviceVersion.DeviceType.IS_IPHONE_4_OR_LESS) {
            magnitude = Constants.Magnitudes.pushUpMagnitudes[0]
        }
        else if (DeviceVersion.DeviceType.IS_IPHONE_5) {
            magnitude = Constants.Magnitudes.pushUpMagnitudes[1]
        }
        else if (DeviceVersion.DeviceType.IS_IPHONE_6) {
            magnitude = Constants.Magnitudes.pushUpMagnitudes[2]
        }
        else if (DeviceVersion.DeviceType.IS_IPHONE_6P) {
            magnitude = Constants.Magnitudes.pushUpMagnitudes[3]
        }
        
        push!.setAngle(angle, magnitude: magnitude)
        
    }
    
    // need to call this when ball goes off screen
    func removeJet(jet: UIImageView) {
        collider.removeItem(jet)
        bounceBehavior.removeItem(jet)
        push!.removeItem(jet)
        gravity.removeItem(jet)
        jet.removeFromSuperview()
    }
    
    func addGravityItem(g: UIImageView, magnitude: CGFloat, poppingUp: Int) {
        dynamicAnimator?.referenceView?.addSubview(g)
        collider.addItem(g)
        bounceBehavior.addItem(g)
        
        pushItem = UIPushBehavior(items: [g], mode: UIPushBehaviorMode.Instantaneous)
        addChildBehavior(pushItem!)
        
        // let magnitude:CGFloat = 5.0
        if (poppingUp == 1) {
            pushItem!.setAngle(piVal * (-93/180), magnitude: magnitude)
        }
        else {
            pushItem!.setAngle(piVal * (93/180), magnitude: magnitude)
        }
        
        pushItem!.addItem(g)
        gravity.addItem(g)
    }


    func removeGravityItem(g: UIImageView) {
        collider.removeItem(g)
        bounceBehavior.removeItem(g)
        pushItem!.removeItem(g)
        gravity.removeItem(g)
        g.removeFromSuperview()
    }
    
//    func addFloor(f: UIImageView) {
//        dynamicAnimator?.referenceView?.addSubview(f)
//        collider.addItem(f)
//        bounceBehavior.addItem(f)
//    }
    
    // MARK: - bullet behavior    
    func addBullet(bullet: UIView, id: String, mag: CGFloat) {
        dynamicAnimator?.referenceView?.addSubview(bullet)
        
        collider.addItem(bullet)
        bounceBehavior.addItem(bullet)
        
        push = UIPushBehavior(items: [bullet], mode: UIPushBehaviorMode.Instantaneous)
        addChildBehavior(push!)
        
        var degrees:CGFloat = 0
        push!.setAngle(piVal * (degrees/180), magnitude: mag) // 0.15 for ball, smaller for line
        
        push!.addItem(bullet)
        
        // gravity.addItem(bullet)
    }
    
    func removeBullet(bullet: UIView) {
        collider.removeItem(bullet)
        bounceBehavior.removeItem(bullet)
        push!.removeItem(bullet)
        gravity.removeItem(bullet)
        
        bullet.removeFromSuperview()
    }
    
    func addUfo(ufo: UIView, id: String) {
        dynamicAnimator?.referenceView?.addSubview(ufo)
        // collider.addItem(ufo)
        bounceBehavior.addItem(ufo)
    }
    
    func removeUfo(ufo: UIView) {
        collider.removeItem(ufo)
        bounceBehavior.removeItem(ufo)
        ufo.removeFromSuperview()
    }

    
    // MARK: - barrier behavior
    func addBarrier(path: UIBezierPath, named name: String) {
        collider.removeBoundaryWithIdentifier(name)
        collider.addBoundaryWithIdentifier(name, forPath: path)
    }
    
    func removeBarrier(named name: String) {
        collider.removeBoundaryWithIdentifier(name)
    }
    
}
