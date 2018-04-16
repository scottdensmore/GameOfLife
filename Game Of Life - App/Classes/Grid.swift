/*******************************************************************************
 * The MIT License (MIT)
 * 
 * Copyright (c) 2018 Jean-David Gadina - www.xs-labs.com
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

import Foundation

class Grid: NSObject
{
    @objc dynamic public private( set ) var turns:      UInt64 = 0
    @objc dynamic public private( set ) var population: UInt64 = 0
    
    public private( set ) var colors: Bool   = true
    public private( set ) var width:  size_t
    public private( set ) var height: size_t
    public private( set ) var cells:  ContiguousArray< Cell >
    
    enum Kind
    {
        case Blank
        case Random
    }
    
    public init( width: size_t, height: size_t, kind: Kind = .Random )
    {
        self.width  = width
        self.height = height
        self.cells  = ContiguousArray< Cell >()
        
        self.cells.grow( width * height ) { Cell() }
        
        super.init()
        
        switch( kind )
        {
            case .Blank:  self._setupBlankGrid()
            case .Random: self._setupRandomGrid()
        }
    }
    
    public func resize( width: size_t, height: size_t )
    {
        var cells = ContiguousArray< Cell >()
        
        cells.reserveCapacity( width * height )
        
        for y in 0 ..< height
        {
            for x in 0 ..< width
            {
                cells.append( self.cellAt( x: x, y: y ) ?? Cell() )
            }
        }
        
        self.cells  = cells
        self.height = height
        self.width  = width
    }
    
    public func next()
    {
        var cells = ContiguousArray< Cell >()
        
        cells.reserveCapacity( self.cells.count )
        
        for cell in self.cells
        {
            cells.append( cell.copy() as! Cell )
        }
        
        if( self.turns < UInt64.max )
        {
            self.turns += 1
        }
        
        var n: UInt64 = 0
        
        for y in 0 ..< self.height
        {
            for x in 0 ..< self.width
            {
                let cell          = cells[ x + ( y * self.width ) ]
                let alive: Bool   = cell.isAlive
                var count: size_t = 0
                
                var c1: Cell? = nil
                var c2: Cell? = nil
                var c3: Cell? = nil
                var c4: Cell? = nil
                var c5: Cell? = nil
                var c6: Cell? = nil
                var c7: Cell? = nil
                var c8: Cell? = nil
                
                if( y > 0 )
                {
                    c1 = ( x > 0 ) ? self.cells[ ( x - 1 ) + ( ( y - 1 ) * self.width ) ] : nil
                    c2 = self.cells[ x + ( ( y - 1 ) * self.width ) ]
                    c3 = ( x < self.width - 1 ) ? self.cells[ ( x + 1 ) + ( ( y - 1 ) * self.width ) ] : nil
                }
                
                c4 = ( x > 0 ) ? self.cells[ ( x - 1 ) + ( y * self.width ) ] : nil
                c5 = ( x < self.width - 1 ) ? self.cells[ ( x + 1 ) + ( y * self.width ) ] : nil
                
                if( y < self.height - 1 )
                {
                    c6 = ( x > 0 ) ? self.cells[ ( x - 1 ) + ( ( y + 1 ) * self.width ) ] : nil
                    c7 = self.cells[ x + ( ( y + 1 ) * self.width ) ]
                    c8 = ( x < self.width - 1 ) ? self.cells[ ( x + 1 ) + ( ( y + 1 ) * self.width ) ] : nil
                }
                
                if( c1?.isAlive ?? false ) { count += 1 }
                if( c2?.isAlive ?? false ) { count += 1 }
                if( c3?.isAlive ?? false ) { count += 1 }
                if( c4?.isAlive ?? false ) { count += 1 }
                if( c5?.isAlive ?? false ) { count += 1 }
                if( c6?.isAlive ?? false ) { count += 1 }
                if( c7?.isAlive ?? false ) { count += 1 }
                if( c8?.isAlive ?? false ) { count += 1 }
                
                if( alive && count < 2 )
                {
                    cell.isAlive = false
                }
                else if( alive && count > 3 )
                {
                    cell.isAlive = false
                }
                else if( alive == false && count == 3 )
                {
                    cell.isAlive = true
                }
                
                if( alive && cell.isAlive && cell.age < UInt64.max )
                {
                    cell.age = cell.age + 1
                }
                
                n += ( cell.isAlive ) ? 1 : 0
            }
        }
        
        self.population = n
        self.cells      = cells
    }
    
    public func cellAt( x: size_t, y: size_t ) -> Cell?
    {
        if( x < self.width && y < self.height )
        {
            return self.cells[ x + ( y * self.width ) ];
        }
        
        return nil
    }
    
    private func _setupBlankGrid()
    {}
    
    private func _setupRandomGrid()
    {
        var n: UInt64 = 0
        
        for cell in self.cells
        {
            cell.isAlive = arc4random() % 3 == 1
            n           += ( cell.isAlive ) ? 1 : 0
        }
        
        self.population = n
    }
    
    public func data() -> Data
    {
        var data = Data()
        
        data.append( contentsOf: [ 71, 79, 76, 49 ] )
        data.append( UInt64( self.width ) )
        data.append( UInt64( self.height ) )
        
        for cell in self.cells
        {
            data.append( UInt8( ( cell.isAlive ) ? 1 : 0 ) )
        }
        
        return data
    }
}

