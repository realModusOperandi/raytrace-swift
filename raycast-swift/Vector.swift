//
//  Vector.swift
//  raycast-swift
//
//  Created by Liam Westby on 11/25/17.
//  Copyright © 2017 Computers. All rights reserved.
//

import Foundation

struct Vector {
    var x: Float
    var y: Float
    var z: Float

    init(x: Float = 0, y: Float = 0, z: Float = 0) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    func magnitude() -> Float {
        return sqrtf(x * x + y * y + z * z)
    }
    
    func unit() -> Vector {
        let mag = self.magnitude()
        return Vector(x: x / mag, y: y / mag, z: z / mag)
    }
    
    func scaled(by f: Float) -> Vector {
        return Vector(x: x * f, y: y * f, z: z * f)
    }

    func added(to v: Vector) -> Vector {
        return Vector(x: x + v.x, y: y + v.y, z: z + v.z)
    }

    func subtracted(by v: Vector) -> Vector {
        return Vector(x: x - v.x, y: y - v.y, z: z - v.z)
    }
    
    func dotted(with v: Vector) -> Float {
        return (x * v.x) + (y * v.y) + (z * v.z)
    }
    
    func crossed(with v: Vector) -> Vector {
        return Vector(x: y * v.z - z * v.y,
                      y: z * v.x - x * v.z,
                      z: x * v.y - y * v.x)
    }
}

extension Vector {
    static func + (left: Vector, right: Vector) -> Vector {
        return Vector(x: left.x + right.x, y: left.y + right.y, z: left.z + right.z)
    }
    
    static func - (left: Vector, right: Vector) -> Vector {
        return Vector(x: left.x - right.x, y: left.y - right.y, z: left.z - right.z)
    }
    
    static func * (left: Vector, right: Float) -> Vector {
        return Vector(x: left.x * right, y: left.y * right, z: left.z * right)
    }
    
    static func * (left: Float, right: Vector) -> Vector {
        return right * left
    }
    
    static func == (left: Vector, right: Vector) -> Bool {
        return left.x == right.x && left.y == right.y && left.z == right.z
    }
}
