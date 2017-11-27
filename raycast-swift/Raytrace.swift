//
//  Raytrace.swift
//  raycast-swift
//
//  Created by Liam Westby on 11/25/17.
//  Copyright © 2017 Computers. All rights reserved.
//

import Foundation

let maxRecursion = 7
let diffuseCoefficient: Float = 0.7
let specularCoefficient: Float = 0.3
let ambientCoefficient: Float = 0.15
let specularSpread: Float = 15.0

struct World {
    let width, height: Float
}

func perspective(in world: World, from origin: Vector, with objects: [Object], lit lights: [PointLight], to image: PPMImage) {
    let pixHeight = world.height / Float(image.height)
    let pixWidth = world.width / Float(image.width)
    
    var pixelVector = Vector()
    var unitVector = Vector()
    var position = Vector()
    
    var nextPercent = 0
    
    for i in 0..<image.height {
        pixelVector.y = 0 + world.height / 2 - pixHeight * (Float(i) + 0.5)
        
        for j in 0..<image.width {
            
            pixelVector.x = 0 - world.width / 2 + pixWidth * (Float(j) + 0.5)
            pixelVector.z = -0.4;
            
            unitVector = pixelVector.unit()
            
            let (objectHit, distance) = shoot(from: origin, towards: unitVector, checking: objects)
            position = unitVector.scaled(by: distance).added(to: origin)
            image.data[i][j] = shade(objectHit, lit: lights, at: position, towards: unitVector)
        }
        
        let progress = Int((Double(i) / Double(image.height) * 100))
        if progress == nextPercent {
            print("\(progress)...", separator: "")
            if image.width <= 1000 {
                nextPercent += 20
            } else if image.width <= 3000 {
                nextPercent += 10
            } else {
                nextPercent += 1
            }
        }
    }
    print("Done.")
}

func parallel(in world: World, towards direction: Vector, with objects: [Object], lit lights: [PointLight], to image: PPMImage) {
    let pixHeight = world.height / Float(image.height)
    let pixWidth = world.width / Float(image.width)
    
    var origin = Vector()
    let unitVector = direction
    var position = Vector()
    
    var nextPercent = 0
    
    for i in 0..<image.height {
        origin.y = 0 + world.height / 2 - pixHeight * (Float(i) + 0.5)
        
        for j in 0..<image.width {
            origin.x = 0 - world.width / 2 + pixWidth * (Float(j) + 0.5)
            origin.z = -0.4;
            
            let (objectHit, distance) = shoot(from: origin, towards: unitVector, checking: objects)
            position = unitVector.scaled(by: distance).added(to: origin)
            image.data[i][j] = shade(objectHit, lit: lights, at: position, towards: unitVector)
        }
        
        let progress = Int((Double(i) / Double(image.height) * 100))
        if progress == nextPercent {
            print("\(progress)...", separator: "")
            if image.width <= 1000 {
                nextPercent += 20
            } else if image.width <= 3000 {
                nextPercent += 10
            } else {
                nextPercent += 1
            }
        }
    }
    print("Done.")
}

func shoot(from origin: Vector, towards direction: Vector, checking objects: [Object]) -> (hit: Object?, distance: Float) {
    var distance: Float = .infinity
    var objectHit: Object? = nil
    var temp: Float
    
    for object in objects {
        temp = object.intersects(from: origin, to: direction)
        if temp < distance {
            distance = temp
            objectHit = object
        }
    }
    
    // To ensure the ray is not slightly inside the shape
    distance -= 0.00001
    
    return (objectHit, distance)
}

func shade(_ object: Object?, lit lights: [PointLight], at position: Vector, towards direction: Vector, level: Int = 0) -> Pixel {
    var color = Pixel()
    guard level <= maxRecursion, object != nil else {
        return color
    }
    let obj = object!
    let reflection = obj.reflection(of: direction, at: position)
    let (objectHit, distance) = shoot(from: position, towards: reflection, checking: objects)
    if distance == .infinity {
        color.r = 0
        color.g = 0
        color.b = 0
    } else {
        let reflectedPosition = reflection.scaled(by: distance).added(to: position)
        
        // Calculate the color of light reflected to this position from elsewhere
        var ambientColor = shade(objectHit, lit: lights, at: reflectedPosition, towards: reflection, level: level + 1)
        ambientColor.r = UInt8(Float(ambientColor.r) * obj.reflectivity)
        ambientColor.g = UInt8(Float(ambientColor.g) * obj.reflectivity)
        ambientColor.b = UInt8(Float(ambientColor.b) * obj.reflectivity)
        
        let fromReflected = reflection.scaled(by: -1.0)
        
        color = directShade(object: obj, at: position, towards: direction, lit: fromReflected, color: ambientColor)
    }
    
    var lightDirection = Vector()
    var lightPixel = Pixel()
    
    for light in lights {
        lightDirection = position.subtracted(by: light.position)
        let lightDistance = lightDirection.magnitude()
        lightDirection = lightDirection.unit()
        
        let (objectHit, shootDistance) = shoot(from: light.position, towards: lightDirection, checking: objects)
        var equals = false
        if objectHit != nil {
            if objectHit!.shape == .sphere && obj.shape == .sphere {
                equals = (objectHit! as! Sphere) == (obj as! Sphere)
            } else if objectHit!.shape == .plane && obj.shape == .plane {
                equals = (objectHit! as! Plane) == (obj as! Plane)
            }
        }
        
        if equals && fabs(shootDistance - lightDistance) < 0.1 {
            lightPixel = directShade(object: obj, at: position, towards: direction, lit: lightDirection, color: light.color)
            
            let red = UInt8(min(255, max(0, Int(color.r) + Int(lightPixel.r))))
            let green = UInt8(min(255, max(0, Int(color.g) + Int(lightPixel.g))))
            let blue = UInt8(min(255, max(0, Int(color.b) + Int(lightPixel.b))))
            
            color = Pixel(r: red, g: green, b: blue)
        }
    }
    
    color.r = UInt8(min(255, max(0, Int(color.r) + Int(Float(color.r) * ambientCoefficient))))
    color.g = UInt8(min(255, max(0, Int(color.g) + Int(Float(color.g) * ambientCoefficient))))
    color.b = UInt8(min(255, max(0, Int(color.b) + Int(Float(color.b) * ambientCoefficient))))
    
    return color
}

func directShade(object: Object, at position: Vector, towards direction: Vector, lit from: Vector, color: Pixel) -> Pixel {
    var illumination = Vector()
    var diffuse = Vector()
    var specular = Vector()
    
    let normal = object.normal(at: position)
    let reflected = object.reflection(of: from, at: position)
    let view = direction.scaled(by: -1.0)
    
    let decimalColor = Vector(x: Float(object.color.r) / 255.0, y: Float(object.color.g) / 255.0, z: Float(object.color.b) / 255.0)
    let decimalLightColor = Vector(x: Float(color.r) / 255.0, y: Float(color.g) / 255.0, z: Float(color.b) / 255.0)
    
    diffuse.x = decimalLightColor.x * decimalColor.x * -(from.dotted(with: normal))
    diffuse.y = decimalLightColor.y * decimalColor.y * -(from.dotted(with: normal))
    diffuse.z = decimalLightColor.z * decimalColor.z * -(from.dotted(with: normal))
    
    specular.x = decimalLightColor.x * powf(reflected.dotted(with: view), specularSpread)
    specular.y = decimalLightColor.y * powf(reflected.dotted(with: view), specularSpread)
    specular.z = decimalLightColor.z * powf(reflected.dotted(with: view), specularSpread)
    
    diffuse = diffuse.scaled(by: diffuseCoefficient)
    specular = specular.scaled(by: specularCoefficient)
    illumination = diffuse.added(to: specular)
    
    var resultRed = Int(illumination.x * 255)
    if resultRed > 255 {
        resultRed = 255
    } else if resultRed < 0 {
        resultRed = 0
    }
    
    var resultGreen = Int(illumination.y * 255)
    if resultGreen > 255 {
        resultGreen = 255
    } else if resultGreen < 0 {
        resultGreen = 0
    }
    
    var resultBlue = Int(illumination.z * 255)
    if resultBlue > 255 {
        resultBlue = 255
    } else if resultBlue < 0 {
        resultBlue = 0
    }
    
    return Pixel(r: UInt8(resultRed), g: UInt8(resultGreen), b: UInt8(resultBlue))
}
