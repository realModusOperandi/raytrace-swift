//
//  PPMImage.swift
//  raycast-swift
//
//  Created by Liam Westby on 11/25/17.
//  Copyright © 2017 Computers. All rights reserved.
//

import Foundation

struct Pixel {
    var r, g, b: UInt8
    
    init(r: UInt8 = 0, g: UInt8 = 0, b: UInt8 = 0) {
        self.r = r
        self.g = g
        self.b = b
    }
}

class PPMImage {
    let width: Int
    let height: Int
    let maxValue: Int
    var data: [[Pixel]]
    
    init(width w: Int, height h: Int, maxValue m: Int) {
        width = w
        height = h
        maxValue = m
        
        data = Array(repeating: Array(repeating: Pixel(r: 0, g: 0, b: 0), count: width), count: height)
    }
    
    func write(to path: String) {
        let header: String = "P6\n\(width)\n\(height)\n\(maxValue)\n"
        var byteData = header.data(using: .utf8)!
        for i in 0..<height {
            for j in 0..<width {
                byteData.append(data[i][j].r)
                byteData.append(data[i][j].g)
                byteData.append(data[i][j].b)
            }
        }
        
        do {
            try byteData.write(to: URL(fileURLWithPath: path))
        } catch {
            print(error)
        }
        
    }
}

extension Pixel {
    static func == (left: Pixel, right: Pixel) -> Bool {
        return left.r == right.r && left.g == right.g && left.b == right.b
    }
}
