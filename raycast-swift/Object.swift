//
//  Object.swift
//  raycast-swift
//
//  Created by Liam Westby on 11/25/17.
//  Copyright © 2017 Computers. All rights reserved.
//

import Foundation

enum Shape {
    case sphere
    case plane
}

protocol Object {
    var shape: Shape { get }
    
    var reflectivity: Float { get set }
    var color: Pixel { get set }
    
    func intersects(from origin: Vector, to direction: Vector) -> Float
    func normal(at point: Vector) -> Vector
    func reflection(of direction: Vector, at position: Vector) -> Vector
}

class Sphere: Object {
    var shape: Shape = .sphere
    
    var reflectivity: Float
    var color: Pixel
    
    let center: Vector
    let radius: Float
    
    init(center cr: Vector, radius ra: Float, reflectivity r: Float, color c: Pixel) {
        center = cr
        radius = ra
        reflectivity = r
        color = c
    }
    
    func intersects(from origin: Vector, to direction: Vector) -> Float {
        let toOrigin = origin.subtracted(by: center)
        
        let a = direction.dotted(with: direction)
        let b = toOrigin.scaled(by: 2.0).dotted(with: direction)
        let c = toOrigin.dotted(with: toOrigin) - (radius * radius)
        
        let discriminant = (b * b) - (4 * a * c)
        if discriminant < 0 {
            return .infinity
        }
        
        let t1 = (-b + sqrtf(discriminant)) / 2*a
        let t2 = (-b - sqrtf(discriminant)) / 2*a
        
        if (t1 > 0 && t2 > 0) {
            return min(t1, t2)
        }
        if (t1 > 0) {
            return t1
        }
        
        if (t2 > 0) {
            return t2
        }
        
        return .infinity
        
    }
    
    func normal(at point: Vector) -> Vector {
        return point.subtracted(by: center).unit()
    }
    
    func reflection(of direction: Vector, at position: Vector) -> Vector {
        let normal = self.normal(at: position)
        return normal.scaled(by: -2 * direction.dotted(with: normal)).added(to: direction).unit()
    }
}

class Plane: Object {
    var shape: Shape = .plane
    
    var reflectivity: Float
    var color: Pixel
    
    let point: Vector
    let normal: Vector
    
    init(point p: Vector, normal n: Vector, reflectivity r: Float, color c: Pixel) {
        point = p
        normal = n
        reflectivity = r
        color = c
    }
    
    func intersects(from origin: Vector, to direction: Vector) -> Float {
        let vD = normal.dotted(with: direction)
        if vD == 0 {
            return .infinity
        }
        
        var distance = Float(0.0)
        distance -= point.x * normal.x
        distance -= point.y * normal.y
        distance -= point.z * normal.z
        
        let v0 = -(normal.dotted(with: origin) + distance)
        let t = v0 / vD
        
        if t < 0 {
            return .infinity
        }
        
        return t
    }
    
    func normal(at point: Vector) -> Vector {
        return normal
    }
    
    func reflection(of direction: Vector, at position: Vector) -> Vector {
        let normal = self.normal(at: position)
        return normal.scaled(by: -2 * direction.dotted(with: normal)).added(to: direction).unit()
    }
}

extension Sphere {
    static func == (left: Sphere, right: Sphere) -> Bool {
        return left.color == right.color &&
            left.reflectivity == right.reflectivity &&
            left.center == right.center &&
            left.radius == right.radius
    }
    
    static func == (left: Sphere, right: Plane) -> Bool {
        return false
    }
    
    static func == (left: Plane, right: Sphere) -> Bool {
        return false
    }
}

extension Plane {
    static func == (left: Plane, right: Plane) -> Bool {
        return left.color == right.color &&
            left.reflectivity == right.reflectivity &&
            left.point == right.point &&
            left.normal == right.normal
    }
}
