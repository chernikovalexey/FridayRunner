//
//  GameScene.swift
//  FridayRunner
//
//  Created by Oleksii Chernikov on 4/18/15.
//  Copyright (c) 2015 Oleksii Chernikov. All rights reserved.
//

import SpriteKit

class Spawner {
    var x, y: CGFloat!
    
    init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }
    
    init(properties: NSDictionary) {
        self.x = properties.objectForKey("x") as! CGFloat
        self.y = properties.objectForKey("y") as! CGFloat
    }
}

class Waypoint {
    var next: Waypoint!
    var x, y: CGFloat!
    
    var description: String {
        return "Waypoint[\(x), \(y)]"
    }
    
    var point: CGPoint {
        get {
            return CGPoint(x: x, y: y)
        }
    }
 
    init() {
    }
    
    init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate, HUMAStarPathfinderDelegate {
    var world: JSTileMap!
    var objects: SKNode!
    var player: Player!
    var spawners: [String: Array<Spawner>!] = ["player": Array<Spawner>(), "enemies": Array<Spawner>()]
    var waypoints: Array<Waypoint> = Array<Waypoint>()
    var pathfinder: HUMAStarPathfinder!
    var startFingerPoint, currentFingerPoint: CGPoint!
    
    static let O_OBSTACLE: UInt32 = 0x1 << 0
    static let O_CHARACTER: UInt32 = 0x1 << 1
    static let O_ANOTHERCH: UInt32 = 0x1 << 2
    static let O_BULLET: UInt32 = 0x1 << 3
    
    static let PATHFINDER_TILEWIDTH: CGFloat = 64
    static let PATHFINDER_TILEHEIGHT: CGFloat = 64
    
    let SKIP_TICKS: Int = 6
    var skippedTicks: Int = 0
    
    override func didMoveToView(view: SKView) {
        self.world = JSTileMap(named: "map21.tmx")
        self.addChild(world)
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        
        world.layerNamed("BB").hidden = true
        world.layerNamed("walls").hidden = true

        self.objects = SKNode()
        for object in world.layerNamed("walls").children[0].children {
            object.removeFromParent()
            objects.addChild(object as! SKNode)
        }
        
        world.addChild(objects)
        
        self.player = Player(gameScene: self, position: CGPoint(x: 0, y: 0))
        objects.addChild(player)
        
        for object in world.layerNamed("BB").children[0].children {
            var tile: SKSpriteNode! = object as! SKSpriteNode
            
            tile.name = "obstacle"
            tile.position.y -= 20
            tile.physicsBody = SKPhysicsBody(texture: tile.texture!, size: CGSize(width: 96, height: 48))
            
            tile.physicsBody!.dynamic = false
            tile.physicsBody!.categoryBitMask = GameScene.O_OBSTACLE
        }
        
        var mapSpawners: NSMutableArray = world.groupNamed("spawners").objects
        var mapWaypoints: NSMutableArray = world.groupNamed("routes").objects
        
        for spawner in mapSpawners {
            var isPlayer: Int32 = (spawner.objectForKey("isPlayer") as! NSString).intValue
            if(isPlayer == 1) {
                spawners["player"]!.append(Spawner(properties: spawner as! NSDictionary))
            } else {
                spawners["enemies"]!.append(Spawner(properties: spawner as! NSDictionary))
            }
        }
        
        var prev: Waypoint!
        for waypoint in mapWaypoints {
            var w = createWayRecursivelyFor(waypoint as! NSDictionary, mapWaypoints: mapWaypoints)
            
            if(getLengthOfWay(w) > 1) {
                waypoints.append(w)
            
                if(prev == nil) {
                    var revWaypoints: Array<Waypoint> = getWaypointsOfWayAsArray(w).reverse()
                    for i in 0...revWaypoints.count - 1 {
                        var rw = linkArrayOfWaypoints(Array<Waypoint>(revWaypoints[i...revWaypoints.count - 1]))
                        
                        if(getLengthOfWay(rw) > 1) {
                            waypoints.append(rw)
                        }
                    }
                }
                
                if(w.next != nil) {
                    prev = w
                } else {
                    prev = nil
                }
            }
        }
        for waypoint in waypoints {
            //printList(waypoint)
        }
        
        self.pathfinder = HUMAStarPathfinder(tileMapSize: CGSize(width: world.mapSize.width * world.tileSize.width / GameScene.PATHFINDER_TILEWIDTH, height: world.mapSize.height * world.tileSize.height / GameScene.PATHFINDER_TILEHEIGHT), tileSize: CGSize(width: GameScene.PATHFINDER_TILEWIDTH, height: GameScene.PATHFINDER_TILEHEIGHT), delegate: self)
        
        spawnPlayer(player)
        placeCameraAboveObject(player)
        
        addEnemy()
        
        var light = SKLightNode()
        light.position = player.position
        light.enabled = false
        light.categoryBitMask = 0x1 << 0
        light.falloff = 2
        world.addChild(light)
    }
    
    func spawnPlayer(player: Player) {
        var index: Int = Int(arc4random_uniform(UInt32(spawners["player"]!.count)))
        var spawner: Spawner = spawners["player"]![index]
        player.position.x = spawner.x - player.texture!.size().width / 2
        player.position.y = spawner.y - player.texture!.size().height / 2
    }
    
    func spawnEnemy(enemy: Character) {
        var index: Int = Int(arc4random_uniform(UInt32(spawners["enemies"]!.count)))
        //println(index)
        var spawner: Spawner = spawners["enemies"]![index]
        enemy.position.x = spawner.x - enemy.texture!.size().width / 2
        enemy.position.y = spawner.y - enemy.texture!.size().height / 2
    }
    
    func addEnemy() {
        var enemy: RegularEnemy = RegularEnemy(gameScene: self, position: CGPoint(x: 0.0, y: 0.0))
        objects.addChild(enemy)
        spawnEnemy(enemy)
        enemy.findWay()
        
        /*var s: SKShapeNode = SKShapeNode(rectOfSize: CGSize(width: 2, height: 2))
        s.position = enemy.aimWaypoint.point
        s.fillColor = SKColor.yellowColor()
        world.addChild(s)*/
    }
    
    func getLengthOfWay(waypoint: Waypoint) -> Int {
        var length: Int = 0
        var w: Waypoint! = waypoint
        while(w != nil) {
            ++length
            w = w.next
        }
        return length
    }
    
    func printList(waypoint: Waypoint, padding: String = "") {
        println(padding + "[\(waypoint.x), \(waypoint.y)]")
        if(waypoint.next != nil) {
            printList(waypoint.next, padding: "  ")
        }
    }
    
    func createWayRecursivelyFor(object: NSDictionary, mapWaypoints: NSMutableArray) -> Waypoint {
        var x = object.objectForKey("x") as! CGFloat
        var y = object.objectForKey("y") as! CGFloat
        var nextId: AnyObject? = object.objectForKey("next")
        var waypoint: Waypoint! = Waypoint(x: x, y: y)
        
        if(nextId != nil) {
            var next = getObjectById(mapWaypoints, id: CGFloat((nextId as! NSString).floatValue))
            
            if(next != nil) {
                waypoint.next = createWayRecursivelyFor(next!, mapWaypoints: mapWaypoints)
            }
        }
        
        return waypoint
    }
    
    // unlinked
    func getWaypointsOfWayAsArray(waypoint: Waypoint) -> Array<Waypoint> {
        var wps: Array<Waypoint> = Array<Waypoint>()
        var w: Waypoint! = waypoint
        
        while(w != nil) {
            wps.append(Waypoint(x: w.x, y: w.y))
            w = w.next
        }
        
        return wps
    }
    
    func linkArrayOfWaypoints(waypoints: Array<Waypoint>) -> Waypoint {
        if(waypoints.count > 1) {
            for i in 0...waypoints.count - 2 {
                waypoints[i].next = waypoints[i + 1]
            }
            waypoints[waypoints.count - 1].next = nil
        }
    
        return waypoints[0]
    }
    
    func getObjectById(objects: NSMutableArray, id: CGFloat) -> NSDictionary? {
        for object in objects {
            var currentId: CGFloat = CGFloat((object.objectForKey("id") as! NSString).floatValue)
            if(currentId == id) {
                return object as? NSDictionary;
            }
        }
        return nil;
    }
    
    func getNearestWaypoint(position: CGPoint) -> Waypoint {
        var closest: Waypoint!
        var dist = CGFloat.max
        for waypoint in waypoints {
            var wdist = sqrt(pow(position.x - waypoint.x, 2) + pow(position.y - waypoint.y, 2))
            if(wdist < dist) {
                dist = wdist
                closest = waypoint
            }
        }
        return closest
    }
    
    func pathfinder(pathfinder: HUMAStarPathfinder!, canWalkToNodeAtTileLocation tileLocation: CGPoint) -> Bool {
        var location: CGPoint = pathfinder.positionForTileLocation(tileLocation)
        
        var s: SKShapeNode = SKShapeNode(rectOfSize: CGSize(width: pathfinder.tileSize.width, height: pathfinder.tileSize.height))
        s.position = CGPoint(x: location.x - pathfinder.tileSize.width / 2, y: location.y - pathfinder.tileSize.height / 2)
        s.strokeColor = SKColor.whiteColor()
        //world.addChild(s)
        
        var node: SKNode = world.nodeAtPoint(CGPoint(x: location.x, y: location.y))
        var body: SKPhysicsBody! = self.physicsWorld.bodyInRect(CGRect(x: location.x - pathfinder.tileSize.width / 2, y: location.y + pathfinder.tileSize.height / 2, width: pathfinder.tileSize.width, height: pathfinder.tileSize.height))
        //println(body == nil)
        return body == nil || (body != nil && body.node!.name == "enemy")
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var collider, victim: SKNode!
        
        if(contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask) {
            collider = contact.bodyA.node
            victim = contact.bodyB.node
        } else {
            collider = contact.bodyB.node
            victim = contact.bodyA.node
        }
        
        if(collider is GameObject) {
            (collider as! GameObject).collidedWith(victim)
        }
        
        if(victim is GameObject) {
            (victim as! GameObject).hitBy(collider)
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        
    }
    
    func placeCameraAboveObject(entity: SKSpriteNode) {
         world.position = CGPointMake(-(entity.position.x - self.size.width / 2), -(entity.position.y - self.size.height / 2))
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touch: UITouch = touches.first as! UITouch
    
        self.startFingerPoint = touch.locationInNode(self)
        
        var s: SKShapeNode = SKShapeNode(rectOfSize: CGSize(width: 4, height: 4))
        s.position = startFingerPoint
        s.fillColor = SKColor.redColor()
        world.addChild(s)
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touch: UITouch = touches.first as! UITouch
        self.currentFingerPoint = touch.locationInNode(self)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.startFingerPoint = nil
        self.currentFingerPoint = nil
    }
    
    func sortObjectsByDepth() {
        let sortedObjects = objects.children.sorted() {
            let s1: SKSpriteNode! = $0 as! SKSpriteNode
            let s2: SKSpriteNode! = $1 as! SKSpriteNode
            let p1 = s1.position
            let p2 = s2.position
            
            if (p2.y > p1.y) {
                return false
            } else {
                return true
            }
        }
        
        for i in 0..<sortedObjects.count {
            let object: SKNode = (sortedObjects[i] as! SKNode)
            object.zPosition = CGFloat(i)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        player.update(currentTime)
        world.enumerateChildNodesWithName("enemy") {
            node, stop in
            (node as! Character).update(currentTime)
        }
        world.enumerateChildNodesWithName("bullet") {
            node, stop in
            (node as! Bullet).update(currentTime)
        }
        
        ++skippedTicks
        if(skippedTicks >= SKIP_TICKS) {
            skippedTicks = 0
            sortObjectsByDepth()
        }
    }
}
