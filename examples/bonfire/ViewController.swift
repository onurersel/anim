//
//  ViewController.swift
//  example-bonfire
//
//  Created by Onur Ersel on 2017-02-21.
//  Copyright © 2017 Onur Ersel. All rights reserved.
//

import UIKit
import anim

class ViewController: UIViewController {

    var mainContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        anim.defaultSettings.delay = 0

        /*
        #if os(tvOS)
            self.view.transform = CGAffineTransform.init(scaleX: 3, y: 3)
        #endif
         */
        
        // background
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black
        self.view.addSubview(backgroundView)
        backgroundView.snapEdges(to: self.view)
        
        let backgroundPatternView = UIView()
        backgroundPatternView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background_pattern"))
        backgroundView.addSubview(backgroundPatternView)
        backgroundPatternView.snapEdges(to: backgroundView)
        
        // container
        mainContainer = UIView()
        self.view.addSubview(mainContainer)
        mainContainer.center(to: self.view, verticalAdjustment: 20.platform)
        
        // wood
        let woodView = UIImageView(image: #imageLiteral(resourceName: "wood"))
        mainContainer.addSubview(woodView)
        woodView.center(to: mainContainer, verticalAdjustment: 80.platform)
        
        // emitters
        createEdgeFireEmitters(x: -16)
        createEdgeFireEmitters(x: 16)
        createParticleEmitter(image: #imageLiteral(resourceName: "particle_red"), ascend: 80, frequency: DoubleRange(min: 0.1, max:0.2), y: 40)
        createBaseFireEmitter(image: #imageLiteral(resourceName: "rect_red"), scale: 0.9, ascent: 60, frequency: 0.9, duration: 4, wobble: 5, emitSize: 20)
        createBaseFireEmitter(image: #imageLiteral(resourceName: "rect_red"), scale: 0.7, ascent: 140, frequency: 1.7, duration: 8, wobble: 10, emitSize: 38)
        createBaseFireEmitter(image: #imageLiteral(resourceName: "rect_orange"), scale: 0.6, ascent: 50, frequency: 0.1, duration: 2.6, wobble: 13, emitSize: 20, y: -18)
        createBaseFireEmitter(image: #imageLiteral(resourceName: "rect_yellow"), scale: 0.2, ascent: 20, frequency: 0.3, duration: 1.3, wobble: 10, emitSize: 10, y: -12)
        createParticleEmitter(image: #imageLiteral(resourceName: "particle_yellow"), ascend: 120, frequency: DoubleRange(min: 0.2, max:0.4), y: 20)
    }
    
    // MARK: - Create emitter helpers
    
    private func createEdgeFireEmitters(x: CGFloat) {
        createEmitter(x: x, y:-15, withSettings: Emitter.Settings(image: #imageLiteral(resourceName: "circle_red"),
                                                                  emitSize: CGSize(width:10, height:5),
                                                                  pullToCenter: true,
                                                                  frequency: DoubleRange(min: 0.3, max:0.4),
                                                                  ascend: DoubleRange(min:20, max:38),
                                                                  wobble: DoubleRange(min:0, max:5),
                                                                  rotate: false,
                                                                  scale: 1,
                                                                  duration: 3,
                                                                  initialAlpha: 0.1))
    }
    
    private func createBaseFireEmitter(image: UIImage, scale: CGFloat, ascent: Double, frequency: Double, duration: TimeInterval, wobble: Double, emitSize: CGFloat, y: CGFloat = 0) {
        createEmitter(y: y, withSettings: Emitter.Settings(image: image,
                                                           emitSize: CGSize(width:emitSize, height:10),
                                                           pullToCenter: true,
                                                           frequency: DoubleRange(min: frequency, max:frequency+0.8),
                                                           ascend: DoubleRange(min:ascent, max:ascent+50),
                                                           wobble: DoubleRange(min:0, max:wobble),
                                                           rotate: false,
                                                           scale: scale,
                                                           duration: duration,
                                                           initialAlpha: 0.2))
    }
    
    private func createParticleEmitter(image: UIImage, ascend: Double, frequency: DoubleRange, y: CGFloat) {
        createEmitter(y: y, withSettings: Emitter.Settings(image: image,
                                                           emitSize: CGSize(width:120, height:20),
                                                           pullToCenter: false,
                                                           frequency: frequency,
                                                           ascend: DoubleRange(min:ascend, max:ascend+80),
                                                           wobble: DoubleRange(min:5, max:40),
                                                           rotate:true,
                                                           scale: 1,
                                                           duration:2,
                                                           initialAlpha: 0.1))
    }
    
    private func createEmitter(x: CGFloat = 0, y: CGFloat = 0, withSettings settings: Emitter.Settings) {
        let emitter = Emitter()
        mainContainer.addSubview(emitter)
        emitter.center(to: mainContainer, horizontalAdjustment: x.platform, verticalAdjustment: y.platform)
        let settings = settings
        emitter.start(settings)
    }

}

