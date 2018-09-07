//
//  FighterJetViewController.swift
//  FighterJet
//
//  Created by Paul Yang on 5/4/15.
//  Copyright (c) 2015 Paul Yang. All rights reserved.
//

// this is the main file
// this files contains the animations of various objects, and draws the jet, barriers, and ufo
// 

import UIKit
import AVFoundation
import StoreKit

class FighterJetViewController: UIViewController, UIDynamicAnimatorDelegate, UICollisionBehaviorDelegate, StartScreenDelegate {

    // MARK: - game view, dynamic behavior
    @IBOutlet weak var gameView: BezierPathsView!
    
    // lazily initialize the dynamic animator
    lazy var animator: UIDynamicAnimator = {
        let lazilyCreatedDynamicAnimator = UIDynamicAnimator(referenceView: self.gameView)
        lazilyCreatedDynamicAnimator.delegate = self
        return lazilyCreatedDynamicAnimator
    }()
    
    // instantiate the jet behavior model, containing the gravity behavior and the collision behavior
    let jetBehavior = JetBehavior()
    
    // MARK: - variables and Constants
    // size the jet for various iphone sizes
    var jetSize: CGSize {
        
        var h = gameView.bounds.size.width / CGFloat(5)
        var w = h * CGFloat(2)
        
        if (DeviceVersion.DeviceType.IS_IPHONE_4_OR_LESS) {
            h = Constants.Sizes.jetHeight[0]
            w = Constants.Sizes.jetWidth[0]
        }
        else if (DeviceVersion.DeviceType.IS_IPHONE_5) {
            h = Constants.Sizes.jetHeight[1]
            w = Constants.Sizes.jetWidth[1]
        }
        else if (DeviceVersion.DeviceType.IS_IPHONE_6) {
            h = Constants.Sizes.jetHeight[2]
            w = Constants.Sizes.jetWidth[2]
        }
        else if (DeviceVersion.DeviceType.IS_IPHONE_6P) {
            h = Constants.Sizes.jetHeight[3]
            w = Constants.Sizes.jetWidth[3]
        }
        
        return CGSize(width: w, height: h)
    }
    
    // quick calculation for the width of a small object relative to the screen size
    var smallObjectWidth: CGFloat {
        return gameView.bounds.size.width / CGFloat(10)
    }
    
    
    
    // MARK: arrays, constants for bullets
    // array to keep track of bullet items.
    var bulletViewArray: [String:UIView] = [String:UIView]()  // (UIView,Int) = (bulletView, numCollisions)
    
    // array keeping track of collisions for bullets
    var bulletCollisionsArray: [String:Int] = [String:Int]()
    var bulletCount = 0
    var bulletLimit = 10
    var bulletSize: CGSize {
        let size = gameView.bounds.size.width / CGFloat(50)
        return CGSize(width: size, height: size/2)
    }
    // boolean to determine whether bullet is a line or a circle
    let bulletIsCircle = false
    
    // MARK: constants for barrier
    var barrierOriginStart: CGFloat!
    var barrierOriginX: CGFloat = 0
    var barrierIndex: Int = 0
    var barrierWidth: CGFloat!
    var topBarrierView: UIImageView!
    var bottomBarrierView: UIImageView!
    var timerForMovingBarriers: NSTimer!
    
    var squareOriginStartX: CGFloat!
    var squareOriginX: CGFloat!
    var squareOriginStartY: CGFloat!
    var squareOriginY: CGFloat!
    var squareMovingUp = false
    var squareTimer: NSTimer!
    var squareWidth: CGFloat!
    
    // MARK: - image views for jet, ufo, floor, background, clouds
    var jetView: UIImageView?
    var ufoView: UIImageView! = nil
    var gravityItemView: UIImageView! = nil
    
    var floorView: UIImageView! = nil
    var floorView2: UIImageView! = nil
    var floorHeight: CGFloat {
        return gameView.bounds.height / 20
    }

    var backgroundView: UIImageView! = nil
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var cloudView: UIImageView!
    var cloud2View: UIImageView!
    var treeView: UIImageView!
    
    // MARK: - timers
    var cloudTimer: NSTimer!
    var cloudTimer2: NSTimer!
    var floorTimer: NSTimer!
    
    // MARK: - debug mode flags
    var debugToggleButton: UIButton!
    var debugMode = false
    
    var alertViewPresent = false
    var gameEndingCollision = false
    
    // MARK: - data structures for barriers
    var bPair: barrierPair!
    struct barrierPair {
        var topBarrier: UIImageView!
        var bottomBarrier: UIImageView!
        var xPosition: CGFloat!
        var xPositionStart: CGFloat!
        var yPositionTop: CGFloat!
        var yPositionBottom: CGFloat!
        
        init(xStart: CGFloat) {
            xPositionStart = xStart
        }
    }

    struct PathNames {
        static let Walls = "Walls"
        static let MovingBarrierTop = "MovingBarrierTop"
        static let MovingBarrierBottom = "MovingBarrierBottom"
        static let Square = "Square"
        static let BackWall = "BackWall"
    }
    
    struct ConstantsMain {
        static let topBarrierLengthOnScreen:[CGFloat] = [0.25, 0.45, 0.15, 0.5, 0.05]
        static let barrierGapAsPercentageOfGameviewHeight:CGFloat = 0.25
        static let barrierGapAsPercentageOfGameviewHeightWhenOpen: CGFloat = 0.55  // needs to end in same decimal value as 0.25
    }
    
    var barrierGapAsPercentageOfGameviewHeightCurrent = ConstantsMain.barrierGapAsPercentageOfGameviewHeight
    var barrierState:String = "closed"
    
    // MARK: - score label
    var scoreLabel: UILabel!
    var score:Int = 0
    var scoreUpdatedForLevel = false
    var highScore: Int = 0
    var highScoreLabel: UILabel!
    var continueLabel: UILabel!
    var numCoins: Int!
    var firstGame:Int = 1
    
    // MARK: - av audio players for sounds
    var jetSound = AVAudioPlayer()
    var ufoSound = AVAudioPlayer()
    var sizzleSound = AVAudioPlayer()
    var collisionSound = AVAudioPlayer()
    var hitUfoSound = AVAudioPlayer()
    var musicSound = AVAudioPlayer()
    
    // MARK: ns user defaults
    let defaults = NSUserDefaults.standardUserDefaults()
    
    // Product ID. This one will be same as in your itunesconnect in app purchase
    var product_id: NSString?
    
    
    // MARK: - view life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let numContinues = defaults.objectForKey("numContinues") as? Int
        if (numContinues == nil) {
            defaults.setObject(5, forKey: "numContinues")
        }
        
        animator.addBehavior(jetBehavior)
        jetBehavior.collider.collisionDelegate = self
        
        barrierWidth = gameView.bounds.width * 0.2
        squareWidth = barrierWidth * 0.5
        
        firstGame = 1
        
        
        // ** important:  order matters here.  need to draw background and floor before stating animation ***
        
        drawBackground()
        drawFloor()
        
        
        drawMovingBarrier()
        startBackgroundAndFloor()
        
        
        // disable the debug button 
        // drawDebugToggleButton()
        
        
        drawScoreLabel()
        
        loadHighScoreAndCoins()
        drawHighScoreLabel()
        drawContinueLabel()
        
        prepareSounds()
        
        musicSound.play()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // draw boundaries
        
        let extraSpace:CGFloat = 50 // add extra space to walls so they are outside of frame
        let origin = CGPointMake(0, -extraSpace)
        let bottomLeft = CGPointMake(0, gameView.bounds.height - floorHeight*2)
        let topRight = CGPointMake(gameView.bounds.width+extraSpace, -extraSpace)
        let bottomRight = CGPointMake(gameView.bounds.width+extraSpace, gameView.bounds.height - floorHeight*2)
        
        let path = UIBezierPath()
        path.moveToPoint(bottomLeft)
        path.addLineToPoint(origin)
        path.addLineToPoint(topRight)
        path.addLineToPoint(bottomRight)
        
        // boundaries for view objects
        jetBehavior.addBarrier(path, named: PathNames.Walls)
        gameView.setPath(path, named: PathNames.Walls, fillcolor: UIColor.redColor(), strokecolor: UIColor.whiteColor())
        
        drawDynamicObjects()
    }
    
    func prepareSounds() {
        // var urlDir = NSURL(fileURLWithPath: "Sounds", isDirectory: true)
        let jetUrl = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("laserJetShortWav", ofType:"wav")!)
        jetSound = try! AVAudioPlayer(contentsOfURL: jetUrl, fileTypeHint: nil)
        jetSound.prepareToPlay()

        let ufoUrl = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("ufo2_short", ofType:"wav")!)
        ufoSound = try! AVAudioPlayer(contentsOfURL: ufoUrl, fileTypeHint: nil)
        ufoSound.prepareToPlay()

        let sizzleUrl = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("sizzleShort", ofType:"wav")!)
        sizzleSound = try! AVAudioPlayer(contentsOfURL: sizzleUrl, fileTypeHint: nil)
        sizzleSound.prepareToPlay()
        
        // var collisionUrl = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("gunShort", ofType:"wav")!)
        let collisionUrl = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("explosionShort", ofType:"wav")!)
        collisionSound = try! AVAudioPlayer(contentsOfURL: collisionUrl, fileTypeHint: nil)
        collisionSound.prepareToPlay()
        
        //let hitUfoUrl = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("explosionShort", ofType:"wav")!)
        let hitUfoUrl = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("ufoDisappear", ofType:"wav")!)
        hitUfoSound = try! AVAudioPlayer(contentsOfURL: hitUfoUrl, fileTypeHint: nil)
        hitUfoSound.prepareToPlay()
        
        //let musicUrl = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Schala", ofType:"mp3")!)
        let musicUrl = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("NightVisionShort2", ofType:"mp3")!)
        musicSound = try! AVAudioPlayer(contentsOfURL: musicUrl, fileTypeHint: nil)
        musicSound.prepareToPlay()
        musicSound.numberOfLoops = -1
    }
    
    func playSound(identifier: String) {
        var sound: AVAudioPlayer!
        switch identifier {
        case "jet":
            sound = jetSound
        case "collision":
            sound = collisionSound
        case "ufo":
            sound = ufoSound
        case "hitUfo":
            sound = hitUfoSound
        case "music":
            sound = musicSound
        case "sizzle":
            sound = sizzleSound
        default:
            sound = jetSound
        }
        sound.stop()
        sound.currentTime = 0
        sound.play()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateContinueLabel()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func drawDynamicObjects() {
        
        if firstGame == 1 {
            drawJet()
        }
        
        drawBackWall()
        
    }
    
    // MARK: - labels, button
    func loadHighScoreAndCoins() {
        let defaults = NSUserDefaults.standardUserDefaults()
        highScore = defaults.objectForKey("highScore") as! Int!
        numCoins = defaults.objectForKey("numCoins") as! Int!
        if numCoins == nil {
            numCoins = 0
        }
    }
  
    func drawHighScoreLabel() {
        let deviceTypeIndex:Int = DeviceVersion.getDeviceIndex()
        let rect = CGRectMake(Constants.Positions.highScoreLabelX[deviceTypeIndex], Constants.Positions.highScoreLabelY[deviceTypeIndex], Constants.Sizes.highScoreLabelWidth[deviceTypeIndex], Constants.Sizes.highScoreLabelHeight[deviceTypeIndex])
        highScoreLabel = UILabel(frame: rect)
        highScoreLabel.text = "\(highScore)"
        highScoreLabel.textColor = UIColor.blueColor()
        highScoreLabel.font = UIFont(name: "Courier-Bold", size: 30)
        highScoreLabel.backgroundColor = UIColor.clearColor()
        highScoreLabel.textAlignment = NSTextAlignment.Right
        gameView.addSubview(highScoreLabel)
    }
    
    
    
    func drawScoreLabel() {
        // put in upper left corner, or lower right corner
        let deviceTypeIndex:Int = DeviceVersion.getDeviceIndex()
        let rect = CGRectMake(Constants.Positions.scoreLabelX[deviceTypeIndex], Constants.Positions.scoreLabelY[deviceTypeIndex], Constants.Sizes.scoreLabelWidth[deviceTypeIndex], Constants.Sizes.scoreLabelHeight[deviceTypeIndex])
        scoreLabel = UILabel(frame: rect)
        scoreLabel.text = "\(score)"
        scoreLabel.textColor = UIColor.blackColor()
        scoreLabel.font = UIFont(name: "Courier-Bold", size: 60)
        scoreLabel.backgroundColor = UIColor.clearColor()
        scoreLabel.textAlignment = NSTextAlignment.Right
        gameView.addSubview(scoreLabel)
    }
    
    func drawContinueLabel() {
        let deviceTypeIndex:Int = DeviceVersion.getDeviceIndex()
        let rect = CGRectMake(Constants.Positions.continueLabelX[deviceTypeIndex], Constants.Positions.continueLabelY[deviceTypeIndex], Constants.Sizes.continueLabelWidth[deviceTypeIndex], Constants.Sizes.continueLabelHeight[deviceTypeIndex])
        continueLabel = UILabel(frame: rect)
        updateContinueLabel()
        gameView.addSubview(continueLabel)
    }
    
    func updateContinueLabel() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let numContinues = defaults.objectForKey("numContinues") as? Int
        continueLabel.text = "continues: \(numContinues!)"
    }
    
    func drawDebugToggleButton() {
        let frame = CGRectMake(smallObjectWidth/4, gameView.bounds.height - smallObjectWidth/5, smallObjectWidth , smallObjectWidth/2)
        debugToggleButton = UIButton(frame: frame)
        debugToggleButton.backgroundColor = UIColor.greenColor()
        debugToggleButton.setTitle("toggle", forState: UIControlState.Normal)
        debugToggleButton.addTarget(self, action: "toggleButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        gameView.addSubview(debugToggleButton)
        gameView.bringSubviewToFront(debugToggleButton)
    }
    
    func toggleButtonPressed() {
        debugMode = !debugMode
        //print("debugMode on: \(debugMode)")
        if debugMode {
            scoreLabel.textColor = UIColor.grayColor()
        }
        else {
            scoreLabel.textColor = UIColor.blackColor()
        }
        // don't call resetScoreAndDisplay() here
        score = 0
        scoreLabel.text = "\(score)"
        
        switch barrierState {
        case "closed":
            barrierState = "opening"
        case "open":
            barrierState = "closing"
        default:
            print("barrier is \(barrierState)")
        }
        
    }
    
    // MARK: - drawing objects 
    
    
    // MARK: draw and animate barriers
    func drawMovingBarrier() {
        // draw the moving barrier
        barrierOriginStart = gameView.bounds.width - barrierWidth
        barrierOriginX = barrierOriginStart

        startMovingBarriers()
    }
    
    func startMovingBarriers() {
        // 0.05  original
        timerForMovingBarriers = NSTimer.scheduledTimerWithTimeInterval(0.065, target: self, selector: Selector("drawBarrier"), userInfo: nil, repeats: true)
    }
    
    func stopMovingBarriers() {
        // this acts as a pause.  use startMovingBarriers() to start it again
        if timerForMovingBarriers != nil {
            timerForMovingBarriers.invalidate()
            timerForMovingBarriers = nil
        }
    }
    
    func animateImageBarrier() {
        
    }
    
    func drawImageBarrier() {
        if bPair == nil {
            bPair = barrierPair(xStart: gameView.bounds.width)
            bPair.xPosition = gameView.bounds.width
            bPair.yPositionBottom = gameView.bounds.height - 4 * smallObjectWidth
            bPair.bottomBarrier = UIImageView(frame: CGRectMake(bPair.xPosition, bPair.yPositionBottom, 3 * smallObjectWidth, 6 * smallObjectWidth))
            bPair.bottomBarrier.image = UIImage(named: "wood.png")
            gameView.addSubview(bPair.bottomBarrier)
            gameView.sendSubviewToBack(bPair.bottomBarrier)
        }
    }
    
    // MARK: draw the jet item
    func drawJet() {
        if jetView != nil {
            // //print("jet exists already")
            return
        }
        
        //print("gravity magnitude when drawing jet: \(jetBehavior.gravity.magnitude)")
        
        var jetFrame = CGRect(origin: CGPointZero, size: jetSize)
        jetFrame.origin.x = gameView.bounds.size.width/4
        jetFrame.origin.y = gameView.bounds.size.height/3
        
        jetView = UIImageView(frame: jetFrame)
        jetView!.image = UIImage(named: "jetMain_black.png")
        jetView!.backgroundColor = UIColor.clearColor()
        jetBehavior.addJet(jetView!)
    }
    
    
    func removeJetView() {
        jetBehavior.removeJet(jetView!)
        jetView = nil
    }
    
    // MARK: draw the bullet item
    func drawBullet() {

        
        
        var bulletView:UIView!
        var magnitude:CGFloat = 0
        
        if bulletIsCircle {
            // circle bullet
            let bulletRadius = bulletSize.width
            let currentJetFrame = jetView!.frame
            let bulletOrigin = CGPointMake(currentJetFrame.origin.x + currentJetFrame.width + 1,
                currentJetFrame.origin.y + currentJetFrame.height/2)
            let bulletFrame = CGRect(origin: bulletOrigin, size: CGSizeMake(bulletRadius*2, bulletRadius*2))
            bulletView = UIView(frame: bulletFrame)
            bulletView.backgroundColor = UIColor.blackColor()
            magnitude = 0.17
            
            bulletView.layer.cornerRadius = bulletRadius
            bulletView.clipsToBounds = true
            bulletView.layer.borderColor = UIColor.grayColor().CGColor
            bulletView.layer.borderWidth = 1.0
        }
        else {
            // line bullet
            let bulletRadius = bulletSize.width
            let currentJetFrame = jetView!.frame
            let bulletOrigin = CGPointMake(currentJetFrame.origin.x + currentJetFrame.width + 1,
                currentJetFrame.origin.y + currentJetFrame.height/5)
            let bulletFrame = CGRect(origin: bulletOrigin, size: CGSizeMake(bulletRadius, bulletRadius/3))
            bulletView = UIView(frame: bulletFrame)
            bulletView.backgroundColor = UIColor.redColor()
            
            // give a magnitude to the push behavior to determine how fast the bullet will go
            // have different magnitudes depending on device type
            
            if (DeviceVersion.DeviceType.IS_IPHONE_4_OR_LESS) {
                magnitude = 0.012
            }
            else if (DeviceVersion.DeviceType.IS_IPHONE_5) {
                magnitude = 0.012
            }
            else if (DeviceVersion.DeviceType.IS_IPHONE_6) {
                magnitude = 0.018
            }
            else if (DeviceVersion.DeviceType.IS_IPHONE_6P) {
                magnitude = 0.025
            }
            
        }
        let bulletStr = "bullet_\(bulletCount)"
        bulletViewArray[bulletStr] = bulletView
        bulletCollisionsArray[bulletStr] = 0
        bulletCount += 1
        
        jetBehavior.addBullet(bulletView, id: bulletStr, mag: magnitude)
    }
    
    // remove the bullet once collision has occured
    func removeBullet(bulletViewInArray: UIView, bulletStr: String) {
        jetBehavior.removeBullet(bulletViewInArray)
        bulletViewArray.removeValueForKey(bulletStr)
        bulletCollisionsArray.removeValueForKey(bulletStr)
    }
    
    
    // MARK: draw the barriers that the jet needs to fly through
    func drawBarrier() {
        let x = barrierOriginX
        // //print("calling draw barrier at origin.x: \(x)")
        
        // //print("barrier.x: \(x)")
        
        updateScore()
        
        let barrierGapCurrent = updateBarrierGap()
        
        let topExtraLength:CGFloat = smallObjectWidth*2
        let bottomExtraLength = topExtraLength
        
        let playableHeight = gameView.bounds.height - floorHeight
        
        let barrierGap:CGFloat = playableHeight * barrierGapCurrent // barrierGapAsPercentageOfGameviewHeightCurrent
        let topBarrierLengthOnScreen = (playableHeight * ConstantsMain.topBarrierLengthOnScreen[barrierIndex])
        let topBarrierLengthTotal = topBarrierLengthOnScreen + topExtraLength  //0.5
        let bottomBarrierLengthOnScreen = playableHeight - topBarrierLengthOnScreen - barrierGap
        let bottomBarrierLengthTotal = bottomBarrierLengthOnScreen + bottomExtraLength
        
        var topRect = CGRectMake(0, 0, barrierWidth, topBarrierLengthTotal)
        topRect.origin = CGPointMake(x, -topExtraLength)
        let topPath = UIBezierPath(roundedRect: topRect, cornerRadius: smallObjectWidth/2)
                
        var bottomRect = CGRectMake(0, 0, barrierWidth, bottomBarrierLengthTotal)
        bottomRect.origin = CGPointMake(x, playableHeight - bottomBarrierLengthOnScreen)
        let bottomPath = UIBezierPath(roundedRect: bottomRect, cornerRadius: smallObjectWidth/2)
        
        let barrierColor = UIColor.getColor(barrierIndex)
        jetBehavior.addBarrier(topPath, named: PathNames.MovingBarrierTop)
        gameView.setPath(topPath, named: PathNames.MovingBarrierTop, fillcolor: barrierColor, strokecolor: UIColor.blackColor())
        
        jetBehavior.addBarrier(bottomPath, named: PathNames.MovingBarrierBottom)
        gameView.setPath(bottomPath, named: PathNames.MovingBarrierBottom, fillcolor: barrierColor, strokecolor: UIColor.blackColor())
        
        // update value for barrierOriginX
        let barrierSpeed:CGFloat = 10.0
        barrierOriginX = barrierOriginX - barrierSpeed
        
        // if the barrier goes off the left side of gameView, then end of level is reached (not implemented)
        if barrierOriginX + barrierWidth <= 0 {
            endOfLevelReset()
            // numCoins += 1
            drawGravityItem()
        }
        
    }
    
    func updateBarrierGap() -> CGFloat {
        // //print("barrier state is: \(barrierState)")
        switch barrierState {
        case "opening":
            barrierGapAsPercentageOfGameviewHeightCurrent += 0.05
            if barrierGapAsPercentageOfGameviewHeightCurrent >= ConstantsMain.barrierGapAsPercentageOfGameviewHeightWhenOpen {
                //print("barriers opened all the way")
                barrierState = "open"
            }
        case "closing":
            barrierGapAsPercentageOfGameviewHeightCurrent -= 0.05
            if barrierGapAsPercentageOfGameviewHeightCurrent <= ConstantsMain.barrierGapAsPercentageOfGameviewHeight {
                //print("barriers closed all the way")
                barrierState = "closed"
            }
        case "open":
            barrierGapAsPercentageOfGameviewHeightCurrent = ConstantsMain.barrierGapAsPercentageOfGameviewHeightWhenOpen
        case "closed":
            barrierGapAsPercentageOfGameviewHeightCurrent = ConstantsMain.barrierGapAsPercentageOfGameviewHeight
        default:
            // default case is "open" or "closed"
            print("barrier is \(barrierState)")

        }
        
        
        return barrierGapAsPercentageOfGameviewHeightCurrent
    }
    
    func endOfLevelReset() {
        
            barrierOriginX = barrierOriginStart
        
            let randomBarrier:Double = Double(randomBetweenNumbers(0.0, secondNum: 5.0))
        
            barrierIndex = Int(round(randomBarrier))
            barrierIndex %= ConstantsMain.topBarrierLengthOnScreen.count
            
            scoreUpdatedForLevel = false
            
            // check if square needs to be drawn again
            if squareTimer == nil {
                squareOriginX = squareOriginStartX
                squareOriginY = squareOriginStartY
            }
        
    }
    
    func drawSquare() {
        let startX:CGFloat = squareOriginX //gameView.bounds.width * 0.75
        
        // //print("square.x: \(startX)")
        
        let width = squareWidth
        let height = width
        var rect = CGRectMake(startX, squareOriginY, width, height)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 3)

        jetBehavior.addBarrier(path, named: PathNames.Square)
        gameView.setPath(path, named: PathNames.Square, fillcolor: UIColor.clearColor(), strokecolor: UIColor.blueColor())
        
        // todo: don't redraw the view every time
        if ufoView == nil {
            // if nil, then draw the ufo
            rect.origin = CGPointMake(startX, squareOriginY)
            ufoView = UIImageView(frame: rect)
            ufoView.image = UIImage(named: "ufoClearBackground.png")
            ufoView.backgroundColor = UIColor.clearColor()
            gameView.addSubview(ufoView)
        }
        else {
            // just set the x, y coordinates
            ufoView.frame.origin = CGPointMake(startX, squareOriginY)
        }
        
        squareOriginX = squareOriginX - CGFloat(5)
        
        if squareMovingUp {
            squareOriginY = squareOriginY - CGFloat(10)
        }
        else {
            squareOriginY = squareOriginY + CGFloat(10)
        }
        
        if squareOriginX + width <= 0 {
            // squareOriginX = squareOriginStartX
            removeSquare()
        }
        
        if squareOriginY >= gameView.bounds.height - 20 {
            //squareOriginY = squareOriginStartY
            squareMovingUp = true
        }
        
        if squareOriginY <= 20 {
            squareMovingUp = false
        }
    }
    
    func removeSquare() {
        jetBehavior.removeBarrier(named: PathNames.Square)
        gameView.removePath(named: PathNames.Square)
        squareTimer.invalidate()
        squareTimer = nil
        
        ufoView.removeFromSuperview()
        ufoView = nil
    }
    
    func drawGravityItem() {
        
        let generatePopupNum:CGFloat = randomBetweenNumbers(0, secondNum: 1)
        
        //print("popupNum: \(generatePopupNum)")
        
        if gravityItemView != nil || generatePopupNum > 0.5 {
            // //print("jet exists already")
            return
        }
        
        let upOrDown:CGFloat = randomBetweenNumbers(0, secondNum: 1)
        var poppingUp:Int = 0 // 0
        if (upOrDown > 0.5) {
            poppingUp = 1 // 1
        }
        
        let deviceTypeIndex:Int = DeviceVersion.getDeviceIndex()

        var w:CGFloat!
        var h:CGFloat!
        if (poppingUp == 1) {
            w = Constants.Sizes.bombWidth[deviceTypeIndex]
            h = Constants.Sizes.bombHeight[deviceTypeIndex]
        }
        else {
            w = Constants.Sizes.ufoWidth[deviceTypeIndex]
            h = Constants.Sizes.ufoHeight[deviceTypeIndex]
        }
        
        let itemSize = CGSizeMake(w,h)
        //var itemSize = CGSizeMake(smallObjectWidth*1.5, smallObjectWidth*2.25)
        var itemFrame = CGRect(origin: CGPointZero, size: itemSize)
        
        var magnitude:CGFloat = randomBetweenNumbers(Constants.Magnitudes.bombUpMagitudeMin[deviceTypeIndex], secondNum: Constants.Magnitudes.bombUpMagitudeMax[deviceTypeIndex])
        //print("magnitude: \(magnitude)")
        
        itemFrame.origin.x = gameView.bounds.size.width*0.6 //-50
        
        var popUpOrigin = gameView.bounds.size.height
        var popDownOrigin = gameView.bounds.size.height
        
        popUpOrigin *= Constants.Positions.bombFromTopYOriginScalar[deviceTypeIndex]
        popDownOrigin *= Constants.Positions.bombFromBottomYOriginScalar[deviceTypeIndex]
        
        if (poppingUp == 1) {
            itemFrame.origin.y = popUpOrigin // -50
        }
        else {
            itemFrame.origin.y = popDownOrigin
            magnitude = 0.2
        }
        
        gravityItemView = UIImageView(frame: itemFrame)

        if (poppingUp == 1) {
            gravityItemView.image = UIImage(named: "CartoonBomb.png")
        }
        else {
            gravityItemView.image = UIImage(named: "ufoClearBackground.png")
        }
        
        jetBehavior.addGravityItem(gravityItemView!, magnitude: magnitude, poppingUp: poppingUp)
        
        if (poppingUp == 1) {
            playSound("sizzle")
        }
        else {
            playSound("ufo")
        }
    }
    
    func randomBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat{
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
    
    func removeGravityItem() {
        if gravityItemView != nil {
            //print("removing gravity item")
            jetBehavior.removeGravityItem(gravityItemView!)
            gravityItemView = nil
        }
    }

    
    func updateScore() {
        if jetView != nil {
            if !scoreUpdatedForLevel && barrierOriginX + barrierWidth <= jetView!.frame.origin.x {
                //print("updating score")
                incrementScoreAndDisplay()
                scoreUpdatedForLevel = true
            }
        }
    }
    
    func incrementScoreAndDisplay() {
        score += 1
        scoreLabel.text = "\(score)"
        
        if !debugMode && score > highScore {
            highScore = score
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(highScore, forKey: "highScore")
            highScoreLabel.text = "\(highScore)"
        }
    }
    
    func gameEnded() {
        // invalidate all the timers
        stopMovingBarriers()
        stopBackgroundAndFloor()
        
        firstGame = 0
        
        // ask to restart alert
        askToRestartAlert()
    }
    
    // MARK: - game starting and ending
    
    func restartGame() {
        resetScoreAndDisplay()
        
        barrierOriginX = barrierOriginStart
        drawBarrier()
        barrierIndex = 0
        
        gameEndingCollision = false

        self.startBackgroundAndFloor()
        
        //jetBehavior.gravity.magnitude = 1.0
        
        //print("gravity magnitude: \(jetBehavior.gravity.magnitude)")
        
        jetBehavior.addChildBehavior(jetBehavior.gravity)
        
        drawJet()
        
        self.startMovingBarriers()
        
        
        
        musicSound.play()
    }
    
    func continueGame() {
        
        // same as restart game, just don't reset the score
        barrierOriginX = barrierOriginStart
        drawBarrier()
        gameEndingCollision = false
        
        drawJet()
        self.startMovingBarriers()
        self.startBackgroundAndFloor()
        
        scoreLabel.text = "\(score)"
        musicSound.play()
    }
    
    func endGameScoreLabel() {
        
        // present modal controller for starting screen, etc
        let startScreenController = StartScreenViewController(nibName: "StartScreenViewController", bundle: nil)
        startScreenController.delegate = self
        
        // don't present the start screen controller
        presentViewController(startScreenController, animated: true, completion: nil)
    }
    
    func resetScoreAndDisplay() {
        //print("reset score to 0")
        score = 0
        scoreLabel.text = "\(score)"
    }
    
    // MARK: delegate function from start game screen
    func startGame() {
        dismissViewControllerAnimated(true, completion: nil)
        getReadyAlert()
        // restartGame()
    }
    
    func continueGameFromDelegate() {
        dismissViewControllerAnimated(true, completion: nil)
        getContinueAlert()
    }
    
    // MARK: various alerts for starting, continuing, and restarting the game
    func getReadyAlert() {
        let alert = UIAlertController(title: "Ready?", message: "Tap the screen to fly", preferredStyle: UIAlertControllerStyle.Alert)
        if (score >= 7) {
            alert.addAction(UIAlertAction(title: "Rate", style: .Default)
                { (action: UIAlertAction!) -> Void in
                    self.rateApp()
                    self.restartGame()
                })
        }
        alert.addAction(UIAlertAction(title: "Yes", style: .Default)
            { (action: UIAlertAction!) -> Void in
                self.restartGame()
            })
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func getContinueAlert() {
        let alert = UIAlertController(title: "Continue", message: "Tap the screen to fly", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .Default)
            { (action: UIAlertAction!) -> Void in
                self.continueGame()
            })
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func askToRestartAlert() {
        // popping up an alert will cause drawDynamicObjects() to be called once it's dismissed, causing the jet to be redrawn.
        // try directly bringing up the startScreen instead of drawing the restart alert (didn't work)
        endGameScoreLabel()

    }
    
    func displayBuyCoinsAlert() {
        if alertViewPresent {
            // return
        }
        
        let alert = UIAlertController(title: "Continue?", message: "Purchase coins to continue (50 coins per continue)", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel)
            { (action: UIAlertAction!) -> Void in
                ////print("cancel pressed")
                //self.startGame()
                // ask to restart alert
                self.askToRestartAlert()
            })
        alert.addAction(UIAlertAction(title: "Buy 100 coins for $0.99", style: .Default)
            { (action: UIAlertAction!) -> Void in
                // open link to app store
                ////print("purchase button 1 pressed")
                self.continueGame()
                
            })
        alert.addAction(UIAlertAction(title: "Buy 500 coins for $2.99", style: .Default)
            { (action: UIAlertAction!) -> Void in
                // open link to app store
                ////print("purchase button 2 pressed")
                self.continueGame()
            })
        alert.addAction(UIAlertAction(title: "Buy 5,000 coins for $19.99", style: .Default)
            { (action: UIAlertAction!) -> Void in
                // open link to app store
                ////print("purchase button 3 pressed")
                self.continueGame()
            })
        alertViewPresent = true
        presentViewController(alert, animated: true, completion: nil)
        ////print("setting alertViewPresent to false")
        alertViewPresent = false
    }
    
    // http://stackoverflow.com/questions/27755069/how-can-i-add-a-link-for-a-rate-button-with-swift
    
    // MARK: - go to app store link
    func rateApp(){
        UIApplication.sharedApplication().openURL(NSURL(string: "itms://itunes.apple.com/us/app/flighty-jet/id1067196690?ls=1&mt=8")!)
    }
    
    // MARK: - draw and animate various parts of the game
    // draw stuff into background
    func drawBackground() {
        
        // draw cloud
        var cloudFrame = CGRect(origin: CGPointZero, size: CGSizeMake(barrierWidth * 0.75, gameView.bounds.height * 0.1))
        cloudFrame.origin.x = gameView.bounds.size.width * 0.8
        cloudFrame.origin.y = gameView.bounds.size.height * 0.1
        
        cloudView = UIImageView(frame: cloudFrame)
        cloudView.image = UIImage(named: "cloud_clearBack.png")
        
        cloudView.backgroundColor = UIColor.clearColor()  // different behaviors based on color?
        gameView.addSubview(cloudView)
        gameView.sendSubviewToBack(cloudView)
        
        
        // draw the second cloud
        var cloud2Frame = CGRect(origin: CGPointZero, size: CGSizeMake(barrierWidth * 0.75, gameView.bounds.height * 0.1))
        cloud2Frame.origin.x = gameView.bounds.size.width * 0.8
        cloud2Frame.origin.y = gameView.bounds.size.height * 0.2
        
        cloud2View = UIImageView(frame: cloud2Frame)
        cloud2View.image = UIImage(named: "cloud2.png")
        
        cloud2View.backgroundColor = UIColor.clearColor()  // different behaviors based on color?
        gameView.addSubview(cloud2View)
    }
    
    // loop the animation of the clouds, and the floor
    func startBackgroundAndFloor() {
        animateCloud()
        cloudTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: Selector("animateCloud"), userInfo: nil, repeats: true)
        animateCloud2()
        cloudTimer2 = NSTimer.scheduledTimerWithTimeInterval(7.0, target: self, selector: Selector("animateCloud2"), userInfo: nil, repeats: true)
        animateFloor()
        floorTimer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("animateFloor"), userInfo: nil, repeats: true)
    }

    // stop animations of the clouds and floor
    func stopBackgroundAndFloor() {
        cloudTimer.invalidate()
        cloudTimer2.invalidate()
        floorTimer.invalidate()
        
        cloudTimer = nil
        cloudTimer2 = nil
        floorTimer = nil
        
        musicSound.stop()
    }

    // draw the floor
    func drawFloor() {
        let rect = CGRectMake(0, self.view.bounds.height-70, 500, 100)
        floorView = UIImageView(frame: rect)
        floorView.image = UIImage(named: "floor500x100.png")
        gameView.addSubview(floorView)
        
        let rect2 = CGRectMake(500, self.view.bounds.height-70, 500, 100)
        floorView2 = UIImageView(frame: rect2)
        floorView2.image = UIImage(named: "floor500x100.png")
        gameView.addSubview(floorView2)
        
    }

    // animate the floor (needs to be called in a loop)
    func animateFloor() {
        floorView.frame.origin.x = 0  // -10
        floorView2.frame.origin.x = 500
        
        UIView.animateWithDuration(2.0,  // 1.0
            delay: 0,
            options: UIViewAnimationOptions.CurveLinear,
            animations: {
                self.floorView.frame.origin.x = -500
                self.floorView2.frame.origin.x = 0
            },
            completion: { if $0 { } } )
        
    }
    
    
    func animateCloud() {
        self.cloudView.frame.origin.x = gameView.bounds.size.width * 0.8
        UIView.animateWithDuration(10.0,
            delay: 0,
            options: UIViewAnimationOptions.CurveLinear,
            animations: {self.cloudView.frame.origin.x = -self.gameView.frame.width-50},
            completion: { if $0 { } } )
    }
    
    func animateCloud2() {
        self.cloud2View.frame.origin.x = gameView.bounds.size.width * 0.8
        UIView.animateWithDuration(7.0,
            delay: 0,
            options: UIViewAnimationOptions.CurveLinear,
            animations: {self.cloud2View.frame.origin.x = -self.gameView.frame.width-50},
            completion: { if $0 { } } )
    }
    
    // this is an invisible wall to keep the plane from drifting backwards
    func drawBackWall() {
        let x = gameView.bounds.size.width/4 - 1
        let topR = CGPointMake(x, 0)
        let botR = CGPointMake(x, gameView.bounds.size.height)
        let topL = CGPointMake(x-10, 0)
        let botL = CGPointMake(x-10, gameView.bounds.size.height)
        let path = UIBezierPath()
        path.moveToPoint(topR)
        path.addLineToPoint(botR)
        path.addLineToPoint(botL)
        path.addLineToPoint(topL)
  
        jetBehavior.addBarrier(path, named: PathNames.BackWall)
        gameView.setPath(path, named: PathNames.BackWall, fillcolor: UIColor.clearColor(), strokecolor: UIColor.clearColor())
    }

    // MARK: - gestures
    
    // tapping the screen pushes the jet up, and also shoots bullets
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        if jetView == nil {
            return
        }
        
        print("tap received")
        
        // check on state of tap gesture recognizer
        switch sender.state {
        case .Ended: fallthrough
        case .Changed:
            
            playSound("jet")
            
            jetBehavior.pushJetUp(jetView!)
            drawBullet()
            
        default:
            break
        }

    }
    
    // MARK: - delegated collision behavior
    
    // MARK: collion between item and a boundary
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, atPoint p: CGPoint) {
        
        // check if identifier is nil
        let identOpt : NSCopying? = identifier
        if let ident = identOpt {
        }
        else {
            return
        }
        
        var boundryStr: String
        boundryStr = identifier as! String
        
        // remove bullet
        for bulletIndex in 0..<bulletCount {
            let bulletStr = "bullet_\(bulletIndex)"
            if let bulletViewInArray = bulletViewArray[bulletStr] {
                if item as? UIView == bulletViewInArray {
                    // //print("remove bullet: \(bulletStr)")
                    
                    let newNumCollisions:Int = bulletCollisionsArray[bulletStr]! + 1
                    bulletCollisionsArray[bulletStr] = newNumCollisions
                    
                    // remove bullet on first collision
                    if newNumCollisions >= 1 {
                        removeBullet(bulletViewInArray, bulletStr: bulletStr)
                    }
                    
                    // remove boundary square when bullet hits it
                    if boundryStr == PathNames.Square {
                        removeSquare()
                        incrementScoreAndDisplay()
                    }
                    
                    break
                }
            }
        }
        
        if gameEndingCollision {
            return
        }
        
        // remove items only if debug mode is off
        if (!debugMode) {
            if item as? UIImageView == gravityItemView && boundryStr == PathNames.Walls {
                removeGravityItem()
            }
            
            if item as? UIView == jetView {
                // jet crashes into barrier or walls
                if (boundryStr == PathNames.Walls || boundryStr == PathNames.MovingBarrierBottom || boundryStr == PathNames.MovingBarrierTop) {
                    
                    gameEnded()
                    removeJetView()
                    
                    gameEndingCollision = true
                    playSound("collision")
                    
                }
            }
        }
    }

    
    // MARK: collision between two different items
    func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item1: UIDynamicItem, withItem item2: UIDynamicItem, atPoint p: CGPoint) {
        
        if gameEndingCollision {
            return
        }
        
        // get the strings for the items being collided
        let item1str = stringForCollisionItem(item1)
        let item2str = stringForCollisionItem(item2)
        
        // 3 possibilities: jet colliding with bullet, ufo colliding with bullet, jet colliding with ufo
        var bulletFound = false
        var bulletItemView: UIView!
        if item1str == "bullet" || item2str == "bullet" {
            bulletFound = true
            item1str == "bullet" ? (bulletItemView = item1 as? UIView) : (bulletItemView = item2 as? UIView)
        }
        
        var jetFound = false
        if item1str == "jet" || item2str == "jet" {
            jetFound = true
        }
        
        var gravityItemFound = false
        if item1str == "gravityItem" || item2str == "gravityItem" {
            gravityItemFound = true
        }
        
        // if a bullet was found, remove either the jet or the gravityItem
        if bulletFound {
            for bulletIndex in 0..<bulletCount {
                let bulletStr = "bullet_\(bulletIndex)"
                if let bulletViewInArray = bulletViewArray[bulletStr] {
                    if bulletItemView == bulletViewInArray {
                        //print("remove bullet: \(bulletStr)")
                        
                        // remove bullet
                        removeBullet(bulletViewInArray, bulletStr: bulletStr)
                        
                        if jetFound {
                            //print("jet collision with bullet")
                            
                            playSound("collision")
                            
                            gameEnded()
                            removeJetView()
                            
                            gameEndingCollision = true
                        }
                        
                        if gravityItemFound {
                            removeGravityItem()
                            playSound("hitUfo")
                            
                            incrementScoreAndDisplay()
                        }
                    }
                }
            }
        }
        
        // if both jet and gravityItem are found, remove both
        // gravity item is the ufo
        if jetFound && gravityItemFound {
            
            // end the game
            gameEnded()
            
            // remove the jet view
            removeJetView()
            
            // remove the ufo view
            removeGravityItem()
            
            // set flag to true
            gameEndingCollision = true
            
            playSound("collision")
            
        }
    }

    // return the string for the item that collided
    func stringForCollisionItem(item: UIDynamicItem) -> String {
        if item as? UIView == jetView {
            return "jet"
        }
        else if item as? UIView == gravityItemView {
            return "gravityItem"
        }
        else {
            return "bullet"
        }
    }
}

// MARK: - Extensions

private extension CGFloat {
    static func random(max: Int) -> CGFloat {
        return CGFloat(arc4random() % UInt32(max))
    }
}

private extension UIColor {
    class var random: UIColor {
        switch arc4random()%5 {
        case 0: return UIColor.greenColor()
        case 1: return UIColor.blueColor()
        case 2: return UIColor.orangeColor()
        case 3: return UIColor.redColor()
        case 4: return UIColor.purpleColor()
        default: return UIColor.blackColor()
        }
    }
    
    class func getColor(index: Int) -> UIColor {
        switch index {
        case 0: return UIColor.greenColor()
        case 1: return UIColor.blueColor()
        case 2: return UIColor.orangeColor()
        case 3: return UIColor.redColor()
        case 4: return UIColor.purpleColor()
        default: return UIColor.blackColor()
        }
        
    }
}