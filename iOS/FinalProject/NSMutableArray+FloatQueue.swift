//
//  NSMutableArray+Queue.m
//  GMaxplorer
//
//  Created by Hadziq Fabroyir on 3/30/13.
//  Copyright (c) 2013 NRLab. All rights reserved.
//
import Foundation

let ARRAYSIZE = 10

extension NSMutableArray {
    
    func enqueue(item: Float)
    {
        if (self.count == ARRAYSIZE) {  // Array is full
            self.dequeue()
        }
        self.addObject(item)
    }
    
    func dequeue() ->Float
    {
        var item :Float=0                 // assigned just to avoid warning
        if (self.count != 0) {
            item = self[0].value
            self.removeObjectAtIndex(0)
        }
        return item
    }
    
    func head() ->Float
    {
        var item :Float = 0                 // assigned just to avoid warning
        if (self.count != 0) {
            item = self[0].value
        }
        return item
    }
    
    
    func tail() ->Float
    {
        var item :Float = 0                 // assigned just to avoid warning
        if (self.count != 0) {
            item = self[self.count-1].value
        }
        return item
    }
    
    
    func clear()
    {
        self.removeAllObjects()
    }
    
    func print()
    {
        var i=0
        println("Queue \(CUnsignedLong(self.count)): ")
        for ( i=0; i<self.count; i++) {
            println("\(i) \(self[i])")
        }
    }
    
    func isIncremental()->Bool
    {
        var i:Int
        var incremental = true
        for (i=1; i<self.count; i++) {
            if (self.objectAtIndex(i).floatValue < self.objectAtIndex(i-1).floatValue) {
                incremental = false
                break
            }
        }
        return incremental
    }
    
    func isDecremental()->Bool
    {
        var i:Int
        var decremental = true
        for (i=1; i<self.count; i++) {
            if (self.objectAtIndex(i).floatValue > self.objectAtIndex(i-1).floatValue) {
                decremental = false
                break
            }
            
        }
        return decremental
    }
    
    func getElementsAverage(queueName: UnsafePointer<NSString>) ->Float
    {
        var sum :Float=0
        var i:Int
        for (i=0; i<self.count; i++) {
            sum += self.objectAtIndex(i).floatValue
        }
        println("Average of \(queueName) = \(sum/Float(self.count))")
        return sum/Float(self.count)
    }
    
}
