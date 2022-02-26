//
//  ContentView.swift
//  SwiftUploadFile
//
//  Created by Kapil Singh on 2/13/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            
            Button("Upload Files") {
                
                print("Application directory: \(NSHomeDirectory())")
                        
                
                // Start an async task
                Task {
                    
                    do {
                        guard let saveFolderURL = URL.createFolder(folderName: dateTimeString()) else {return}
                        _ = URL.createFile(folderURL: saveFolderURL, fileName: "scanData.txt")
                        _ = URL.createFile(folderURL: saveFolderURL, fileName: "scanData2.txt")
                        print ("saveFolder = ", saveFolderURL)
                        let FileFetcher = FilesUploader()
                        try await FileFetcher.uploadFileWithAsyncURLSession(folderURL:saveFolderURL)
                        
                        
                    } catch {
                        print("Request failed with error: \(error)")
                    }
                    
  /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Action@*/ /*@END_MENU_TOKEN@*/
            }

        }
        }
    }
       
        
        
}
 
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

