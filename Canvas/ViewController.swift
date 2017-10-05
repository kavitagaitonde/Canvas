//
//  ViewController.swift
//  Canvas
//
//  Created by Kavita Gaitonde on 10/4/17.
//  Copyright © 2017 Kavita Gaitonde. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var trayView: UIView!
    
    @IBOutlet weak var upDownImageView: UIImageView!
    
    @IBOutlet weak var deadImageView: UIImageView!
    var trayOriginalCenter: CGPoint!
    var trayUp: CGPoint!
    var trayDown: CGPoint!
    var isTrayDown: Bool = false
    var newlyCreatedFace: UIImageView!
    var imageOriginalCenter: CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        trayUp = trayView.center
        trayDown = CGPoint(x: trayView.center.x, y: trayView.center.y + 250)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func handleTap(_ sender: AnyObject) {
        if isTrayDown {
            isTrayDown = false
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.1, options: [], animations: {
                UIView.animate(withDuration: 0.3, animations: {
                    self.trayView.center = self.trayUp
                })
                }, completion: { _ in
                    
            })
        } else {
            isTrayDown = true
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.1, options: [], animations: {
                UIView.animate(withDuration: 0.3, animations: {
                    self.trayView.center = self.trayDown
                })
                }, completion: { _ in
                    
            })
            
        }
    }
    
    @IBAction func handleImagePan(_ sender: UIPanGestureRecognizer) {
        let point = sender.location(in: view)
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        
        
        if sender.state == .began {
            print("Image began at: \(point)")
        
            
            let imageView = sender.view as! UIImageView
            self.imageOriginalCenter = imageView.center
            
            // Create a new image view that has the same image as the one currently panning
            newlyCreatedFace = UIImageView(image: imageView.image)
            newlyCreatedFace.isUserInteractionEnabled = true
            newlyCreatedFace.tag = imageView.tag
            
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPanNewImage(_:)))
            panGestureRecognizer.delegate = self
            newlyCreatedFace.addGestureRecognizer(panGestureRecognizer)
            
            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(didPinchNewImage(_:)))
            pinchGestureRecognizer.delegate = self
            newlyCreatedFace.addGestureRecognizer(pinchGestureRecognizer)
            
            let rotateGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(didRotateNewImage(_:)))
            rotateGestureRecognizer.delegate = self
            newlyCreatedFace.addGestureRecognizer(rotateGestureRecognizer)
            
            let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapNewImage(_:)))
            doubleTapGestureRecognizer.delegate = self
            doubleTapGestureRecognizer.numberOfTapsRequired = 2
            newlyCreatedFace.addGestureRecognizer(doubleTapGestureRecognizer)
            
            // Add the new face to the tray's parent view.
            view.addSubview(newlyCreatedFace)
            
            // Initialize the position of the new face.
            newlyCreatedFace.center = imageView.center
            
            // Since the original face is in the tray, but the new face is in the
            // main view, you have to offset the coordinates
            print("TRAYVIEW YY: \(trayView.frame.origin.y)")
            print("IMAGE YY: \(newlyCreatedFace.center.y)")
            newlyCreatedFace.center.y += trayView.frame.origin.y
            print("UPDATED IMAGE YY: \(newlyCreatedFace.center.y)")
        } else if sender.state == .changed {
            print("Image changed at: \(point)")
            newlyCreatedFace.center = CGPoint(x: self.newlyCreatedFace.center.x, y: self.newlyCreatedFace.center.y + translation.y)
        } else if sender.state == .ended {
            print("Image ended at: \(point)")
            if velocity.y > 0 { //down
                
             } else { //up
                /*UIView.animate(withDuration: 0.3, animations: {
                    self.newlyCreatedFace.center = CGPoint(x: self.newlyCreatedFace.center.x, y: self.newlyCreatedFace.center.y + translation.y)
                })*/
            }

        }
    }
    
    func didPanNewImage(_ sender: UIPanGestureRecognizer) {
        let point = sender.location(in: view)
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        
        let imageView = sender.view as! UIImageView
        if sender.state == .began {
            if velocity.y > 0 { //down
            } else {
            print("didPanNewImage began at: \(point)")
            imageView.transform = CGAffineTransform(scaleX: 2, y: 2)
            }
        } else if sender.state == .changed {
            print("didPanNewImage changed at: \(point)")
            imageView.center = CGPoint(x: imageView.center.x + translation.x, y: imageView.center.y + translation.y)
        } else if sender.state == .ended {
            print("didPanNewImage ended at: \(point)")
            if velocity.y > 0 { //down
                //if in the bound of the trayview
                if imageView.frame.origin.y >= trayView.frame.origin.y {
                    switch imageView.tag {
                    case 1:
                        UIView.animate(withDuration: 0.3, animations: {
                            imageView.center = CGPoint(x: self.deadImageView.center.x+self.trayView.frame.origin.x, y: self.deadImageView.center.y + self.trayView.frame.origin.y)
                        })
                        break
                    default:
                        break
                    }
                }
            }
            imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
            
        }
    }
    
    func didPinchNewImage(_ sender: UIPinchGestureRecognizer) {
        let scale = sender.scale
        let imageView = sender.view as! UIImageView
        imageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        sender.scale = 1
    }
    
    func didRotateNewImage(_ sender: UIRotationGestureRecognizer) {
        let rotation = sender.rotation
        let imageView = sender.view as! UIImageView
        imageView.transform =  CGAffineTransform(rotationAngle: rotation)
        sender.rotation = 0
    }
    
    func didDoubleTapNewImage(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }

    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        let point = sender.location(in: view)
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        
        
        if sender.state == .began {
            print("Gesture began at: \(point)")
            self.trayOriginalCenter = self.trayView.center
        } else if sender.state == .changed {
            print("Gesture changed at: \(point)")
            trayView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translation.y)
        } else if sender.state == .ended {
            print("Gesture ended at: \(point)")
            if velocity.y > 0 { //down
                UIView.animate(withDuration: 0.3, animations: {
                    self.trayView.center = self.trayDown
                    self.upDownImageView.transform = CGAffineTransform(rotationAngle: CGFloat(180 * M_PI / 180))
                })
            } else { //up
                UIView.animate(withDuration: 0.3, animations: {
                    self.trayView.center = self.trayUp
                    self.upDownImageView.transform = CGAffineTransform(rotationAngle: CGFloat(0 * M_PI / 180))
                })
            }
        }
    }
}

