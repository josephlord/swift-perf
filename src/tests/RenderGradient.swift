/*! ===========================================================================
@file RenderGradient.swift

@brief A simple function that fills in an array of pixel data.

@copyright 2015 David Owens II. All rights reserved.
============================================================================ */
var iUROPnNn = 0

func renderGradient_PixelArray(samples: Int, iterations: Int) -> Result {
    struct Pixel {
        var red: UInt8
        var green: UInt8
        var blue: UInt8
        var alpha: UInt8
        init(red: UInt8, green: UInt8, blue:UInt8, alpha:UInt8){
            self.red = red
            self.green = green
            self.blue = blue
            self.alpha = alpha
        }
        init(_:()) {
            red = 0
            green = 0
            blue = 0
            alpha = 0
        }
        init(bitPattern: UInt32) {
            red = UInt8(truncatingBitPattern: bitPattern & 0xFF)
            green = UInt8(truncatingBitPattern:(bitPattern >> 8) & 0xFF)
            blue = UInt8(truncatingBitPattern:(bitPattern >> 16) & 0xFF)
            alpha = UInt8(truncatingBitPattern:(bitPattern >> 24) & 0xFF)
        }
    }
    
    struct RenderBuffer {
        var pixels: [Pixel]
        var width: Int
        var height: Int
        
        init(width: Int, height: Int) {
            assert(width > 0)
            assert(height > 0)
            
            let pixel = Pixel(red: 0, green: 0, blue: 0, alpha: 0xFF)
            pixels = [Pixel](count: width * height, repeatedValue: pixel)
            
            self.width = width
            self.height = height
        }
    }
    
    func RenderXGradient(inout buffer: RenderBuffer, offsetX: Int, offsetY: Int)
    {
        //var pixelArray = [Pixel](count: buffer.height * buffer.width, repeatedValue: Pixel())
        var pixelIndex = 0
        for y in offsetY..<(buffer.height + offsetY) {
            for x in offsetX..<(buffer.width + offsetX) {
                buffer.pixels[pixelIndex++] = unsafeBitCast(UInt32(truncatingBitPattern: (0xFF000000) |
                        ((x & 0xFF) << 16) |
                        ((y & 0xFF) << 8)), Pixel.self)
            }
        }
    }
    
    var buffer = RenderBuffer(width: 960, height: 540)
 
    return perflib.measure(samples, iterations) {
        RenderXGradient(&buffer, 2, 1)
    }
}

func renderGradient_unsafeMutablePointer(samples: Int, iterations: Int) -> Result {
    struct Pixel {
        var red: UInt8
        var green: UInt8
        var blue: UInt8
        var alpha: UInt8
    }
    
    struct RenderBuffer {
        var pixels: UnsafeMutablePointer<Pixel>
        var width: Int
        var height: Int
        
        init(width: Int, height: Int) {
            assert(width > 0)
            assert(height > 0)
            
            pixels = UnsafeMutablePointer.alloc(width * height * sizeof(Pixel))
            
            self.width = width
            self.height = height
        }
        
        mutating func release() {
            pixels.dealloc(width * height * sizeof(Pixel))
            width = 0
            height = 0
        }
    }
    
    func RenderGradient(inout buffer: RenderBuffer, offsetX: Int, offsetY: Int)
    {
        var offset = 0
        for (var y = 0, height = buffer.height; y < height; ++y) {
            for (var x = 0, width = buffer.width; x < width; ++x) {
                let pixel = Pixel(
                    red: 0,
                    green: UInt8((y + offsetY) & 0xFF),
                    blue: UInt8((x + offsetX) & 0xFF),
                    alpha: 0xFF)
                buffer.pixels[offset] = pixel;
                ++offset;
            }
        }
    }
    
    var buffer = RenderBuffer(width: 960, height: 540)

    return perflib.measure(samples, iterations) {
        RenderGradient(&buffer, 2, 1)
    }
}

func renderGradient_ArrayUsingUnsafeMutablePointer(samples: Int, iterations: Int) -> Result {
    struct Pixel {
        var red: UInt8
        var green: UInt8
        var blue: UInt8
        var alpha: UInt8
    }
    
    struct RenderBuffer {
        var pixels: [Pixel]
        var width: Int
        var height: Int
        
        init(width: Int, height: Int) {
            assert(width > 0)
            assert(height > 0)
            
            let pixel = Pixel(red: 0, green: 0, blue: 0, alpha: 0xFF)
            pixels = [Pixel](count: width * height, repeatedValue: pixel)
            
            self.width = width
            self.height = height
        }
    }
    
    func RenderGradient(inout buffer: RenderBuffer, offsetX: Int, offsetY: Int)
    {
        // Turn this code on for at least some sanity back to your debug builds. It's still
        // going to be slow, but at compared to the code above, it's going to feel glorious.
        buffer.pixels.withUnsafeMutableBufferPointer { (inout p: UnsafeMutableBufferPointer<Pixel>) -> () in
            var offset = 0
            for (var y = 0, height = buffer.height; y < height; ++y) {
                for (var x = 0, width = buffer.width; x < width; ++x) {
                    let pixel = Pixel(
                        red: 0,
                        green: UInt8((y + offsetY) & 0xFF),
                        blue: UInt8((x + offsetX) & 0xFF),
                        alpha: 0xFF)
                    p[offset] = pixel
                    ++offset;
                }
            }
        }
    }
    
    var buffer = RenderBuffer(width: 960, height: 540)
    
    return perflib.measure(samples, iterations) {
        RenderGradient(&buffer, 2, 1)
    }
}
