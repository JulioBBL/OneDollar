//
//  GameViewController.swift
//  OneDollar
//
//  Created by Bruno Omella Mainieri on 06/09/17.
//  Based on example by Daniele Margutti (02/10/15)
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    private var loadedTemplates:[SwiftUnistrokeTemplate] = []
    private var templateViews:[StrokeView] = []
//    var drawView:StrokeView!
//    var templatesScrollView	:UIScrollView!
//    var labelTemplates:UILabel!
    
    @IBOutlet weak var drawView: StrokeView!
    @IBOutlet weak var templatesScollView: UIScrollView!
    @IBOutlet weak var labelTemplates: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let view = self.view as! SKView? {
//            // Load the SKScene from 'GameScene.sks'
//            if let scene = SKScene(fileNamed: "GameScene") {
//                // Set the scale mode to scale to fit the window
//                scene.scaleMode = .aspectFill
//                
//                // Present the scene
//                view.presentScene(scene)
//            }
//            
//            view.ignoresSiblingOrder = true
//            
//            view.showsFPS = true
//            view.showsNodeCount = true
//        }
        
        
        loadTemplatesDirectory()
        
        drawView.backgroundColor = UIColor.cyan
        drawView.onDidFinishDrawing = { drawnPoints in
            if drawnPoints == nil {
                return
            }
            
            if drawnPoints!.count < 5 {
                return
            }
            
            let strokeRecognizer = OneDollar(points: drawnPoints!)
            do {
                let (template,distance) = try strokeRecognizer.recognizeIn(templates: self.loadedTemplates, useProtractor: false, minThreshold: 0.80)
                
                self.labelTemplates.text = "Recognized: \(template!.name.uppercased())"
                
                
            } catch (let error as NSError) {
                print("FAILED WITH ERROR: \(error.localizedDescription)")
                self.labelTemplates.text = "No gesture recognized"
            }
            
        }
        
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    private func loadTemplatesDirectory() {
        do {
            // Load template files
            let templatesFolder = Bundle.main.resourcePath!.appending("/Templates")
            
            let list = try FileManager.default.contentsOfDirectory(atPath: templatesFolder)
            
            var x:CGFloat = 0.0
            let size = templatesScollView.frame.height
            for file in list {
                let templateData = NSData(contentsOfFile: templatesFolder.appendingFormat("/%@", file))
                let templateDict = try JSONSerialization.jsonObject(with: templateData! as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                let templateName = templateDict["name"]! as! String
                let templateImage = templateDict["image"]! as! String
                let templateRawPoints: [AnyObject] = templateDict["points"]! as! [AnyObject]
                var templatePoints: [StrokePoint] = []
                for rawPoint in templateRawPoints {
                    let x = (rawPoint as! [AnyObject]).first! as! Double
                    let y = (rawPoint as! [AnyObject]).last! as! Double
                    templatePoints.append(StrokePoint(x: x, y: y))
                }
                
                let templateObj = SwiftUnistrokeTemplate(name: templateName, points: templatePoints)
                loadedTemplates.append(templateObj)
                print("  - Loaded template '\(templateName)' with \(templateObj.points.count) points inside")
                
                // For each template get its preview and show them inside the bottom screen scroll view
                let templateView = UIImageView(frame: CGRect(x:x,y:0,width:size,height:size))
                templateView.image = UIImage(named: templateImage)
                templateView.contentMode = UIView.ContentMode.scaleAspectFit
                templateView.layer.borderColor = UIColor.lightGray.cgColor
                templateView.layer.borderWidth = 2
                templatesScollView.addSubview(templateView)
                x = templateView.frame.maxX+2
            }
            
            print("- \(loadedTemplates.count) templates are now loaded!")
            
            // setup scroll view size
            templatesScollView.contentSize = CGSize(width:x+CGFloat(2*loadedTemplates.count), height:size)
            templatesScollView.backgroundColor = UIColor.white
            labelTemplates.text = "\(loadedTemplates.count) TEMPLATES LOADED:"
        } catch (let error as NSError) {
            print("Something went wrong while loading templates: \(error.localizedDescription)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
