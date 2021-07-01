//
//  GalleryUIWindow.swift
//  MyGallery
//
//  Created by Christos Petimezas on 1/7/21.
//

import UIKit

class ZagUIWindow: UIWindow {
    
    private var pressDetected: Bool = false
    
    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        guard UIApplication.editAlbumAsCurrentVC() == true else { return }
        event.allTouches?.forEach { touch in
            /// #When press event is occured, exclude touches until the phase of touch is ended.
            if touch.phase == .began && !pressDetected {
                UIApplication.deleteLoafView()
            } else if touch.phase == .ended {
                pressDetected = false
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        pressDetected = true
    }
    
}
