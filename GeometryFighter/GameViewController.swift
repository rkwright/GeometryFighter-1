//
//  GameViewController.swift
//  GeometryFighter
//
//  Created by rkwright on 12/30/20.
//

import UIKit
import SceneKit

class GameViewController: UIViewController {
    var scnView     : SCNView!
    var scnScene    : SCNScene!
    var cameraNode  : SCNNode!
    var spawnTime   : TimeInterval = 0
    var game        = GameHelper.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupScene()
        setupCamera()
        setupHUD()
        
       // createTrail(color: <#T##UIColor#>, geometry: <#T##SCNGeometry#>)
        
        emitParticles()
    }
    
    //
    // Set up the view configuration
    //
    func setupView() {
        scnView = self.view as? SCNView
        
        scnView.showsStatistics = true
        
        scnView.allowsCameraControl = true
        
        scnView.autoenablesDefaultLighting = true
        
        scnView.delegate = self
        
        scnView.isPlaying = true
        
        scnView.allowsCameraControl = false
        
    }
    
    //
    // Just set up our scene and add the background png to it
    //
    func setupScene() {
        scnScene = SCNScene()
        scnView.scene = scnScene
        
        scnScene.background.contents = "GeometryFighter.scnassets/Textures/Background_Diffuse.png"
    }
    
    //
    // Set up a simple perspective camera
    //
    func setupCamera() {
        cameraNode = SCNNode()
        
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 10)
        
        scnScene.rootNode.addChildNode(cameraNode)
    }
    
    //
    // Configure the HUD
    //
    func setupHUD() {
        game.hudNode.position = SCNVector3(x: 0.0, y: 10.0, z: 0.0)
        scnScene.rootNode.addChildNode(game.hudNode)
    }
    
    //
    // Generate a random shape and add it to the scene.  We'll clean up later.
    //
    func spawnShape() {
        
        var shapeNode : SCNNode
        var geomNode  : SCNGeometry
       
        switch ShapeType.random() {
            
            case ShapeType.sphere:
                geomNode = SCNSphere(radius: 1.0)
 
            case ShapeType.pyramid:
                geomNode = SCNPyramid(width: 1.0, height:1.0, length:1.0)
           
            case ShapeType.torus:
                geomNode = SCNTorus(ringRadius: 1.0, pipeRadius:1.0)
                
            case ShapeType.capsule:
                geomNode = SCNCapsule(capRadius: 1.0, height:1.0)
                
            case ShapeType.cylinder:
                geomNode = SCNCylinder(radius: 1.0, height:1.0)
                
            case ShapeType.cone:
                geomNode = SCNCone(topRadius: 0.0, bottomRadius:1.0, height:1.0)
                
            case ShapeType.tube:
                geomNode = SCNTube(innerRadius: 0.5, outerRadius:1.0, height:1.0)
                
            default:           // default is a ShapeType.box
                geomNode = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        }
                 
        shapeNode = SCNNode(geometry: geomNode)
        let color = UIColor.random()
        geomNode.materials.first?.diffuse.contents = color
        
        if color == UIColor.black {
            shapeNode.name = "BAD"
            } else {
            shapeNode.name = "GOOD"
        }
        
        shapeNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        
        let randomX = Float.random(min: -2, max: 2)
        let randomY = Float.random(min: 10, max: 18)
        let force = SCNVector3(x: randomX, y: randomY , z: 0)
        
        let position = SCNVector3(x: 0.05, y: 0.05, z: 0.05)
        
        shapeNode.physicsBody?.applyForce(force, at: position, asImpulse: true)
        
        scnScene.rootNode.addChildNode(shapeNode)
    }
    
    //
    // As each node falls off the "screen" simply delete it.
    //
    func cleanScene() {
        for node in scnScene.rootNode.childNodes {
            if node.presentation.position.y < -2 {
                node.removeFromParentNode()
            }
        }
    }
    
    //
    // Create a particle system only with code.
    //
    func emitParticles() {
        scnView = self.view as? SCNView
        
        let particleSystem = SCNParticleSystem()
        particleSystem.birthRate = 5000
        particleSystem.particleLifeSpan = 1
        particleSystem.warmupDuration = 1
        particleSystem.emissionDuration = 100.0
        particleSystem.loops = false
        particleSystem.particleColor = .yellow
        particleSystem.birthDirection = .random
        particleSystem.speedFactor = 7
        particleSystem.emittingDirection = SCNVector3(0,1,1)
        particleSystem.emitterShape = .some(SCNSphere(radius: 15.0))
        particleSystem.spreadingAngle = 90
        particleSystem.particleImage = "star"
        
        let particlesNode = SCNNode()
        particlesNode.scale = SCNVector3(1,1,1)
        particlesNode.addParticleSystem(particleSystem)
                
        scnView.scene!.rootNode.addChildNode(particlesNode)
    }
    
    //
    // Create the trail by loading the dummy "scn" file.
    //
    func createTrail(color: UIColor, geometry: SCNGeometry) -> SCNParticleSystem {
        let scene = SCNScene(named: "GeometryFighter.scnassets/Scenes/Trail.scn")
        let node:SCNNode = (scene?.rootNode.childNode(withName: "Trail", recursively: true)!)!

        let particleSystem:SCNParticleSystem = (node.particleSystems?.first)!
        
        particleSystem.particleColor = color
        particleSystem.emitterShape = geometry
        
        return particleSystem
    }

    //
    // Our logic for the touch handler
    //
    func handleTouchFor(node: SCNNode) {
        if node.name == "GOOD" {
            game.score += 1
            node.removeFromParentNode()
        } else if node.name == "BAD" {
            game.lives -= 1
            node.removeFromParentNode()
        }
    }
    
    //
    // Our handler for touches on the screen
    //
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Get the first touch (could be multiple if more than one finger used)
        let touch = touches.first!
        // transform into the coordinate space of our view
        let location = touch.location(in: scnView)
        // shoot a ray from the camera (?) location to where the user touched
        let hitResults = scnView.hitTest(location, options: nil)
        // if there are any results, call out to the touch handler
        if let result = hitResults.first {
            handleTouchFor(node: result.node)
        }
    }
    
    //
    // Simple overrides
    //
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}  // end of class

//
// Extension protocol so we can handle the render loop calls
//
extension GameViewController: SCNSceneRendererDelegate {

func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {

if time > spawnTime {
    
    cleanScene()
    spawnShape()
    
    spawnTime = time + TimeInterval(Float.random(min: 0.2, max: 1.5))
    
    game.updateHUD()
}

}
}

