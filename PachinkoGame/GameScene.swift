//
//  GameScene.swift
//  PachinkoGame
//
//  Created by Steve Kerney on 8/21/17.
//  Copyright © 2017 Steve Kerney. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate
{
    override func didMove(to view: SKView)
    {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384);
        background.blendMode = .replace;
        background.zPosition = -1;
        addChild(background);
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame);
        physicsWorld.contactDelegate = self;
        
        createSlots();
        createBouncers();
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if let touch = touches.first
        {
            let location = touch.location(in: self);
            let ball = SKSpriteNode(imageNamed: "ballRed");
            ball.name = "ball";
            ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0);
            ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask;
            ball.physicsBody!.restitution = 0.4;
            ball.position = location;
            addChild(ball);
        }
    }
    
    override func update(_ currentTime: TimeInterval)
    {
        // Called before each frame is rendered
    }
}

//MARK: Collision Functions
extension GameScene
{
    func didBegin(_ contact: SKPhysicsContact)
    {
        //Ball collision
        if contact.bodyA.node?.name == "ball"
        {
            collisionBetween(ball: contact.bodyA.node!, other: contact.bodyB.node!);
        }
        else if contact.bodyB.node?.name == "ball"
        {
            collisionBetween(ball: contact.bodyB.node!, other: contact.bodyA.node!);
        }
    }
    
    func collisionBetween(ball: SKNode, other: SKNode)
    {
        if let objectName = other.name
        {
            switch objectName
            {
            case "good":
                destroy(object: ball);
            case "bad":
                destroy(object: ball);
            default:
                break;
            }
        }
    }
}

//MARK: Helper Functions
extension GameScene
{

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
    
    func destroy(object: SKNode)
    {
        object.removeFromParent();
    }
}
