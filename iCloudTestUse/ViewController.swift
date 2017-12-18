//
//  ViewController.swift
//  iCloudTestUse
//
//  Created by CIA on 18/12/2017.
//  Copyright © 2017 CIA. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    //键值存储中心
    let keyStore = NSUbiquitousKeyValueStore.default
    var a = 0
    var filePathURL:URL? = nil
    
    //文件查询
    var  fileQuery:NSMetadataQuery = {
       let query = NSMetadataQuery()
        query.searchScopes = [NSMetadataQueryUbiquitousDocumentsScope]
        return query
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(ubiquitousKeyValueStoreDidChange), name: NSUbiquitousKeyValueStore.didChangeExternallyNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(metadataQueryFinish), name: NSNotification.Name.NSMetadataQueryDidFinishGathering, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(metadataQueryDidUpdate), name: NSNotification.Name.NSMetadataQueryDidUpdate, object: nil)
    }

    //MARK: Key Value存储
    @IBAction func redKeyValueButtonPressed(_ sender: Any) {
        let valueString = keyStore.string(forKey: "saveValueKey") ?? ""
        print("The Value is:" + valueString)
    }
    
    @IBAction func setKeyValueButtonPressed(_ sender: Any) {
        a += 1
        keyStore.set("\(a)", forKey: "saveValueKey")
        keyStore.synchronize()
        
        //写入系统会在适当的时候更新到云端去
    }
    
    //MARK: icloud文件读写
    @IBAction func readICloudFileList(_ sender: Any) {
        //查询iCloud中的文件列表
        self.fileQuery.start()
    }
    @IBAction func addFileToICloud(_ sender: Any) {
        let fileName = "file\(arc4random())"
        if let fileUrl = getiCloudFileUrlWithFileName(fileName) {
            //上传
            let document = AADocument(fileURL: fileUrl)
            document.contentString = "我是图"
            document.save(to: fileUrl, for: .forCreating, completionHandler: { (sucess) in
                if sucess{
                    print("保存成功")
                } else {
                    print("保存失败")
                }
            })
        }
    }
    
    @IBAction func changeFileContetnInIcloud(_ sender: Any) {
        if let url = filePathURL{
            let document = AADocument.init(fileURL: url)
            document.contentString = "我不是图"
            document.save(to: url, for: .forOverwriting, completionHandler: { (sucess) in
                if sucess{
                    print("修改成功")
                } else {
                    print("修改失败")
                }
            })
        }
    }
    
    @IBAction func getIcloudFileContent(_ sender: Any) {
        if let url = filePathURL{
            let document = AADocument.init(fileURL: url)
            document.open(completionHandler: { (success) in
                if success{
                    print("打开成功：%@",document.contentString)
                } else {
                    print("打开失败")
                }
            })
        }
    }
    
    @IBAction func deleteFileInIcloud(_ sender: Any) {
        if let url = filePathURL{
           try? FileManager.default.removeItem(at: url)
        }
    }
    
    //MARK: 通知
    @objc func ubiquitousKeyValueStoreDidChange(notification:NSNotification) {
        print("KeyValue信息修改：%@",keyStore.string(forKey: "saveValueKey") ?? "")
    }
    
    @objc func metadataQueryFinish(notification:NSNotification) {
        print("查询返回结果：")
        let items = self.fileQuery.results as! [NSMetadataItem]
        for item in items {
            print("文件名：\(item.value(forKey:NSMetadataItemFSNameKey)),文件大小：\(item.value(forKey:NSMetadataItemFSSizeKey)),文件类型：\(item.value(forKey:NSMetadataItemContentTypeKey))")
        }
        filePathURL = items.first?.value(forAttribute: NSMetadataItemURLKey) as? URL
    }
    
    @objc func metadataQueryDidUpdate(notification:NSNotification) {
        print("查询信息更新：")
        let items = self.fileQuery.results as! [NSMetadataItem]
        for item in items {
            print("文件名：\(item.value(forKey:NSMetadataItemFSNameKey)),文件大小：\(item.value(forKey:NSMetadataItemFSSizeKey)),文件类型：\(item.value(forKey:NSMetadataItemContentTypeKey))")
        }
    }
    
    //MARK: 帮助方法
    func getiCloudFileUrlWithFileName(_ fileName:String) -> URL? {
        if var iCloudPath = FileManager.default.url(forUbiquityContainerIdentifier: nil){
           iCloudPath =  iCloudPath.appendingPathComponent("Documents")
           iCloudPath = iCloudPath.appendingPathComponent(fileName)
            return iCloudPath
        }
        return nil
    }
    func getiCloudDocumentPath() ->  URL?{
        if var iCloudPath = FileManager.default.url(forUbiquityContainerIdentifier: nil){
            iCloudPath =  iCloudPath.appendingPathComponent("Documents")
            return iCloudPath
        }
        return nil
    }
}

