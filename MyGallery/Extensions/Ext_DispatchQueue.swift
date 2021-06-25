//
//  Ext_DispatchQueue.swift
//  MyGallery
//
//  Created by Christos Petimezas on 25/6/21.
//

import Foundation

extension DispatchQueue {
    
    static var workItems = [AnyHashable : DispatchWorkItem]()
    
    static var weakTargets = NSPointerArray.weakObjects()
    
    static func dedupeIdentifierFor(_ object: AnyObject) -> String {
        return "\(Unmanaged.passUnretained(object).toOpaque())." + String(describing: object)
    }
    
    /**
     - parameters:
     - target: Object used as the sentinel for de-duplication.
     - delay: The time window for de-duplication to occur
     - work: The work item to be invoked on the queue.
     Performs work only once for the given target, given the time window. The last added work closure
     is the work that will finally execute.
     Note: This is currently only safe to call from the main thread.
     Example usage:
     ```
     DispatchQueue.main.asyncDeduped(target: self, after: 1.0) { [weak self] in
     self?.doTheWork()
     }
     ```
     credits: https://gist.github.com/staminajim/b5e89c6611eef81910502db2a01f1a83
     */
    public func asyncDeduped(target: AnyObject, after delay: TimeInterval, execute work: @escaping @convention(block) () -> Void) {
        let dedupeIdentifier = DispatchQueue.dedupeIdentifierFor(target)
        if let existingWorkItem = DispatchQueue.workItems.removeValue(forKey: dedupeIdentifier) {
            existingWorkItem.cancel()
        }
        let workItem = DispatchWorkItem {
            DispatchQueue.workItems.removeValue(forKey: dedupeIdentifier)
            
            for ptr in DispatchQueue.weakTargets.allObjects {
                if dedupeIdentifier == DispatchQueue.dedupeIdentifierFor(ptr as AnyObject) {
                    work()
                    break
                }
            }
        }
        
        DispatchQueue.workItems[dedupeIdentifier] = workItem
        DispatchQueue.weakTargets.addPointer(Unmanaged.passUnretained(target).toOpaque())
        
        asyncAfter(deadline: .now() + delay, execute: workItem)
    }
    
}
