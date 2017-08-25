//
//  GameScene.swift
//  PachinkoGame
//
//  Created by Steve Kerney on 8/21/17.
//  Copyright © 2017 Steve Kerney. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate
{
    //Gameplay
    var scoreLabel: SKLabelNode!;
    var score: Int = 0
    {
        didSet
        {
            scoreLabel.text = "Score: \(score)";
        }
    }
    
    var isEditing: Bool = false
    {
        didSet
        {
            editLabel.text = isEditing ? "Done" : "Edit"
        }
    }
    var editLabel: SKLabelNode!;
    
    
    
    override func didMove(to view: SKView)
    {
        initScene();
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if let touch = touches.first
        {
            let location = touch.location(in: self);
            
            let objects = nodes(at: location);
            
            if objects.contains(editLabel)
            {
                isEditing = !isEditing;
            }
            else
            {
                if !isEditing
                {
                    createBall(location: location);
                }
                else
                {
                    createRandomBox(location: location);
                }
            }
        }
    }
    
    func createBall(location: CGPoint)
    {
        let ball = SKSpriteNode(imageNamed: "ballRed");
        ball.name = "ball";
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0);
        ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask;
        ball.physicsBody!.restitution = 0.4;
        ball.position = CGPoint(x: location.x, y: 768 - (ball.size.height / 2));
        addChild(ball);
    }
    
    func createRandomBox(location: CGPoint)
    {
        let size = CGSize(width: GKRandomDistribution(lowestValue: 64, highestValue: 128).nextInt(), height: 16);
        let box = SKSpriteNode(color: RandomColor(), size: size);
        box.zRotation = RandomCGFloat(min: 0, max: 3);
        box.position = location;
        box.physicsBody = SKPhysicsBody(rectangleOf: box.size);
        box.physicsBody!.isDynamic = false;
        
        addChild(box);
    }
}

//MARK: Collision Functions
extension GameScene
{
    func didBegin(_ contact: SKPhysicsContact)
    {
        //Ball to any collision
        if contact.bodyA.node?.name == "ball"
        {
            guard let vNodeA = contact.bodyA.node else { return ;}
            guard let vNodeB = contact.bodyB.node else { return ;}
            
            collisionBetween(ball: vNodeA, other: vNodeB);
        }
        else if contact.bodyB.node?.name == "ball"
        {
            guard let vNodeB = contact.bodyB.node else { return ;}
            guard let vNodeA = contact.bodyA.node else { return ;}
            
            collisionBetween(ball: vNodeB, other: vNodeA);
        }
    }
    
    func collisionBetween(ball: SKNode, other: SKNode)
    {
        guard let vNodeName = other.name else { return; }
        
        switch vNodeName
        {
        case "good":
            score += 1;
            destroyBall(ball: ball);
        case "bad":
            score -= 1;
            destroyBall(ball: ball);
        default:
            break;
        }
    }
}

//MARK: Helper Functions
extension GameScene
{

    func initScene()
    {
        //Background
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384);
        background.blendMode = .replace;
        background.zPosition = -1;
        addChild(background);
        
        //Scene
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame);
        physicsWorld.contactDelegate = self;
        
        //Nodes
        createSlots();
        createBouncers();
        
        //UI
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster");
        scoreLabel.text = "Score: 0";
        scoreLabel.horizontalAlignmentMode = .right;
        scoreLabel.position = CGPoint(x: 980, y: 700);
        addChild(scoreLabel);
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster");
        editLabel.text = "Edit";
        editLabel.horizontalAlignmentMode = .right;
        editLabel.position = CGPoint(x: 120, y: 700);
        addChild(editLabel);
    }
    
    
    func createBouncers()
    {
        for index in 0..<5
        {
            let xPos = 256 * index;
            createBouncer(at:  CGPoint(x: xPos, y: 0))
        }
    }
    
    func createBouncer(at position: CGPoint)
    {
        let bouncer = SKSpriteNode(imageNamed: "bouncer");
        bouncer.position = position;
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0);
        bouncer.physicsBody!.contactTestBitMask = bouncer.physicsBody!.collisionBitMask;
        bouncer.physicsBody!.isDynamic = false;
        addChild(bouncer);
    }
    
    func createSlots()
    {
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true);
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false);
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true);
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false);
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool)
    {
        var slotBase: SKSpriteNode;
        let slotImage: String = isGood ? "slotBaseGood" : "slotBaseBad";
        slotBase = SKSpriteNode(imageNamed: slotImage);
        slotBase.name = isGood ? "good" : "bad";
        slotBase.position = position;
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size);
        slotBase.physicsBody!.isDynamic = false;
        addChild(slotBase);
        
        var slotGlow: SKSpriteNode;
        let slotGlowImage: String = isGood ? "slotGlowGood" : "slotGlowBad";
        slotGlow = SKSpriteNode(imageNamed: slotGlowImage);
        slotGlow.position = position;
        addChild(slotGlow);
        
        //Glow Rotation
        let spinAction = SKAction.rotate(byAngle: CGFloat.pi, duration: 10);
        let loopedAction = SKAction.repeatForever(spinAction);
        slotGlow.run(loopedAction);
        
        
    }
    
    func destroyBall(ball: SKNode)
    {
        ball.removeFromParent();
        
        guard let fireParticles = SKEmitterNode(fileNamed: "FireParticles") else { return; }
        
        fireParticles.position = ball.position;
        let addAction = SKAction.run { self.addChild(fireParticles); }
        let waitAction = SKAction.wait(forDuration: 2);
        let removeAction = SKAction.run { fireParticles.removeFromParent(); }
        run(SKAction.sequence([addAction, waitAction, removeAction]));
    }
}
