//
//  GetFilefromFolder.swift
//  SwiftUploadFile
//
//  Created by Kapil Singh on 2/18/22.
//

import Foundation
extension URL {
    static func createFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        // Get document directory for device, this should succeed
        if let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            // Construct a URL with desired folder name
            let folderURL = documentDirectory.appendingPathComponent(folderName)
            // If folder URL does not exist, create it
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    // Attempt to create folder
                    try fileManager.createDirectory(atPath: folderURL.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    // Creation failed. Print error & return nil
                    print(error.localizedDescription)
                    print(folderURL.path)
                    return nil
                }
            }
            // Folder either exists, or was created. Return URL
            return folderURL
        }
        // Will only be called if document directory not found
        return nil
    }
    static func createFile(folderURL:URL, fileName:String)->URL
    {
        let fileManager = FileManager.default
        let fileURL = folderURL.appendingPathComponent(fileName)
        fileManager.createFile(atPath: fileURL.path, contents: "This is scan Data".data(using: .utf8), attributes: [:])
        
        return fileURL
    }
}

//Here's how I call it:

        // Setup a unique save folder for the captured data using the current date and time
//        saveFolder = URL.createFolder(folderName: dateTimeString())

//createFolder() calls dataTimeString() which creates a unique string based on the //date and time. It looks like this:

    func dateTimeString() -> String {
        var result: String = ""
        let currentDateTime = Date()
        let userCalendar = Calendar.current
        let requestedComponents: Set<Calendar.Component> = [
            .year,
            .month,
            .day,
            .hour,
            .minute,
            .second
        ]
        let dateTimeComponents = userCalendar.dateComponents(requestedComponents, from: currentDateTime)

        result = "\(dateTimeComponents.year!)_\(dateTimeComponents.month!)_\(dateTimeComponents.day!)_\(dateTimeComponents.hour!)_\(dateTimeComponents.minute!)_\(dateTimeComponents.second!)"
        
        return "TestDir"
    }

