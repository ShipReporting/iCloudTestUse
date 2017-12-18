
//
//  AADocument.swift
//  iCloudTestUse
//
//  Created by CIA on 18/12/2017.
//  Copyright © 2017 CIA. All rights reserved.
//

import UIKit

class AADocument: UIDocument {
    var contentString = ""
    
    //加载内容
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let content = contents as? Data{
            contentString = String(data: content, encoding: String.Encoding.utf8) ?? ""
        }
    }
    
    //保存内容
    override func contents(forType typeName: String) throws -> Any {
        return contentString.data(using: .utf8) ?? Data()
    }
}
