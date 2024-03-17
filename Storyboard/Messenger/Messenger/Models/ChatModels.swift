//
//  ChatModels.swift
//  Messenger
//
//  Created by Ajin on 17/03/24.
//

import Foundation
import CoreLocation
import MessageKit
import UIKit

struct Message: MessageType{
    public var sender: MessageKit.SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKit.MessageKind
}

struct Media: MediaItem{
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
}

struct Location: LocationItem{
    var location: CLLocation
    var size: CGSize
    
}
