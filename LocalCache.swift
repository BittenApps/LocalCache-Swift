//
//  LocalCache.swift
//
//  Copyright (c) 2015, Bitten Apps
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, 
//  with or without modification, are permitted provided 
//  that the following conditions are met:
//
//  1. Redistributions of source code must retain the above 
//  copyright notice, this list of conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above 
//  copyright notice, this list of conditions and the following 
//  disclaimer in the documentation and/or other materials provided with the distribution.
//
//  3. Neither the name of the copyright holder nor the names of its 
//  contributors may be used to endorse or promote products derived 
//  from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
//  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
//  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
//  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
//  COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
//  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
//  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
//  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
//  POSSIBILITY OF SUCH DAMAGE.
//

import UIKit

class CachedObject<Type> {
    var timestamp : NSTimeInterval
    var identifier : String
    var object : Type
    
    convenience init(identifier: String, object: Type) {
        self.init(timestamp: NSDate().timeIntervalSinceReferenceDate, identifier: identifier, object: object)
    }
    
    init(timestamp: NSTimeInterval, identifier: String, object: Type) {
        self.timestamp = timestamp
        self.identifier = identifier
        self.object = object
    }
}

enum LocalCacheError : ErrorType {
    case IdentifierAlreadyExists
    case ObjectNotFound
}

class LocalCache<Type> {
    private var cache : [CachedObject<Type>]
    
    var expiry : Int
    
    init(secondsToExpiration: Int) {
        cache = [CachedObject<Type>]()
        expiry = secondsToExpiration
    }
    
    func getObject(id: String) -> Type? {
        for obj in cache {
            if obj.identifier == id {
                if isUseable(obj) {
                    return obj.object
                } else {
                    try! removeObject(obj)
                    
                    return nil
                }
            }
        }
        
        return nil
    }
    
    func addObject(object: CachedObject<Type>) throws {
        if hasObject(withIdentifier: object.identifier) {
            if isUseable(object) {
                throw LocalCacheError.IdentifierAlreadyExists
            } else {
                try removeObject(object)
            }
        }
        
        cache.append(object)
    }
    
    func removeObject(object: CachedObject<Type>) throws {
        for (idx, item) in cache.enumerate() {
            if item.identifier == object.identifier {
                cache.removeAtIndex(idx)
                
                return
            }
        }
        
        throw LocalCacheError.ObjectNotFound
    }
    
    func purgeExpiredObjects() {
        for o in cache {
            if !isUseable(o) {
                try! removeObject(o)
            }
        }
    }
    
    func hasObject(withIdentifier id: String) -> Bool {
        for obj in cache {
            if obj.identifier == id && isUseable(obj) {
                return true
            }
        }
        
        return false
    }
    
    func isUseable(object: CachedObject<Type>) -> Bool {
        if Int(object.timestamp) + expiry > Int(NSDate().timeIntervalSinceReferenceDate) {
            return true
        } else {
            return false
        }
    }
}

