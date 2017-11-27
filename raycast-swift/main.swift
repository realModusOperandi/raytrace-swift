//
//  main.swift
//  raycast-swift
//
//  Created by Liam Westby on 11/25/17.
//  Copyright © 2017 Computers. All rights reserved.
//

import Foundation

func printUsage() {
    
}

func getObjects() -> [Object] {
    var objects: [Object] = []
    // Red Sphere
    objects.append(Sphere(center: Vector(x: -0.3, y: 0.2, z: -0.6),
                          radius: 0.2,
                          reflectivity: 0.5,
                          color: Pixel(r: 255, g: 0, b: 0)))
    
    // Orange Sphere
    objects.append(Sphere(center: Vector(x: 0.15, y: -0.2, z: -0.6),
                          radius: 0.15,
                          reflectivity: 0.5,
                          color: Pixel(r: 255, g: 165, b: 0)))
    
    // Yellow Sphere
    objects.append(Sphere(center: Vector(x: 0.1, y: 0.175, z: -0.15),
                          radius: 0.05,
                          reflectivity: 0.5,
                          color: Pixel(r: 255, g: 255, b: 0)))
    
    // Green Sphere
    objects.append(Sphere(center: Vector(x: 0.0, y: 0.13, z: -0.3),
                          radius: 0.025,
                          reflectivity: 0.5,
                          color: Pixel(r: 0, g: 255, b: 0)))
    
    // Blue Sphere
    objects.append(Sphere(center: Vector(x: 0.3, y: -0.2, z: -0.2),
                          radius: 0.125,
                          reflectivity: 0.5,
                          color: Pixel(r: 0, g: 0, b: 255)))
    
    // Magenta Sphere
    objects.append(Sphere(center: Vector(x: -0.2, y: 0.0, z: -0.4),
                          radius: 0.06,
                          reflectivity: 0.0,
                          color: Pixel(r: 255, g: 0, b: 255)))
    
    // Grey Plane
    objects.append(Plane(point: Vector(x: 0.0, y: -0.2, z: 0.0),
                         normal: Vector(x: 0.0, y: 1.0, z: 0.0),
                         reflectivity: 0.5,
                         color: Pixel(r: 127, g: 127, b: 127)))
    
    return objects
}

func getLights() -> [PointLight] {
    var lights: [PointLight] = []
    
    lights.append(PointLight(position: Vector(x: 0.0, y: 10.0, z: 0.0), color: Pixel(r: 255, g: 255, b: 255)))
    lights.append(PointLight(position: Vector(x: -5.0, y: 7.0, z: 3.0), color: Pixel(r: 255, g: 255, b: 255)))
    
    return lights
}

let startTime = Date().timeIntervalSince1970

if CommandLine.arguments.count < 4 {
    printUsage()
    exit(0)
}

var parallel: Bool

if CommandLine.arguments[1] == "l" {
    parallel = true
} else if CommandLine.arguments[1] == "v" {
    parallel = false
} else {
    printUsage()
    exit(0)
}

let width = Int(CommandLine.arguments[2]) ?? 0

if width < 1 {
    print("Expected positive integer for image width, got \(CommandLine.arguments[2])")
    printUsage()
    exit(0)
}

let outputPath = CommandLine.arguments[3]

print("Creating image...")
let image = PPMImage(width: width, height: Int(Float(width) * (5.0 / 8.0)), maxValue: 255)

print("Setting up the scene...")
let objects = getObjects()
let lights = getLights()

print("Rendering scene to image...")
if parallel {
    let direction = Vector(x: 0.0, y: 0.0, z: -1.0)
    parallel(in: World(width: 0.5, height: 0.3125), towards: direction, with: objects, lit: lights, to: image)
} else {
    let origin = Vector(x: 0.0, y: 0.0, z: 0.8)
    perspective(in: World(width: 0.5, height: 0.3125), from: origin, with: objects, lit: lights, to: image)
}

print("Writing image to file...")
image.write(to: CommandLine.arguments[3])
print("Completed. Time: \(Int((Date().timeIntervalSince1970 - startTime) * 1000))ms")







