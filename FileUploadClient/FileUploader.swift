//
// 
//  SwiftUploadFile
//
//  Created by Kapil Singh on 2/13/22.
//


//
//  FilesUploader.swift
//  FilesUploader

//

import Foundation


struct RestEntity {
    private var values: [String: String] = [:]
    
    mutating func add(value: String, forKey key: String) {
        values[key] = value
    }
    
    func value(forKey key: String) -> String? {
        return values[key]
    }
    
    func allValues() -> [String: String] {
        return values
    }
    
    func totalItems() -> Int {
        return values.count
    }
}


class FilesUploader {
    
    enum FilesUploaderError: Error {
        case invalidURL
        case missingData
    }
    struct FileInfo {
        var fileContents: Data?
        var mimetype: String?
        var filename: String?
        var name: String?
        
        init(withFileURL url: URL?, filename: String, name: String, mimetype: String) {
            guard let url = url else { return }
            fileContents = try? Data(contentsOf: url)
            self.filename = filename
            self.name = name
            self.mimetype = mimetype
        }
    }
    var requestHttpHeaders = RestEntity()
    
    var urlQueryParameters = RestEntity()
    
    var httpBodyParameters = RestEntity()
    
    var httpBody: Data?

    
    struct Results {
        var data: Data?
        var response: Response?
        var error: Error?
        
        init(withData data: Data?, response: Response?, error: Error?) {
            self.data = data
            self.response = response
            self.error = error
        }
        
        init(withError error: Error) {
            self.error = error
        }
    }

    struct Response {
        var response: URLResponse?
        var httpStatusCode: Int = 0
        var headers = RestEntity()
        
        init(fromURLResponse response: URLResponse?) {
            guard let response = response else { return }
            self.response = response
            httpStatusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            
            if let headerFields = (response as? HTTPURLResponse)?.allHeaderFields {
                for (key, value) in headerFields {
                    headers.add(value: "\(value)", forKey: "\(key)")
                }
            }
        }
    }
    
    enum CustomError: Error {
        case failedToCreateRequest
        case failedToCreateBoundary
        case failedToCreateHttpBody
    }
   
    func uploadFileWithAsyncURLSession(folderURL:URL) async throws -> URLResponse {
        
        
        let url = URL(string: "http://192.168.1.208:3276/UploadFile")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
         
        let boundary = createBoundary()
                
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
         
         
         var body = self.getHttpBody(withBoundary: boundary)
         
        var FilesToUpload : [FilesUploader.FileInfo] = []
        let fileManager = FileManager.default
        //let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: folderURL.path)
            var i = 0
            for item in filePaths {
                if (item.starts(with:"scan"))
                {
                    i += 1
                print("Found \(item)")
                
                let fileURL = URL.createFile(folderURL: folderURL, fileName: item)
                    let scanFileInfo = FilesUploader.FileInfo(withFileURL: fileURL, filename: fileURL.lastPathComponent, name: "uploadedFile" + String(i), mimetype: "text/plain")
                    FilesToUpload.append( scanFileInfo)
                }
            
            }
        } catch {
            print("Error while enumerating files \(folderURL.path): \(error.localizedDescription)")
        }
        
        
        
        
      /*   let textFileURL = Bundle.main.url(forResource: "sampleText", withExtension: "txt")
         let textFileInfo = FilesUploader.FileInfo(withFileURL: textFileURL, filename: "sampleText.txt", name: "uploadedFile1", mimetype: "text/plain")
         
         let pdfFileURL = Bundle.main.url(forResource: "samplePDF", withExtension: "pdf")
         let pdfFileInfo = FilesUploader.FileInfo(withFileURL: pdfFileURL, filename: "samplePDF.pdf", name: "uploadedFile2", mimetype: "application/pdf")
         
         let imageFileURL = Bundle.main.url(forResource: "sampleImage", withExtension: "jpg")
         let imageFileInfo = FilesUploader.FileInfo(withFileURL: imageFileURL, filename: "sampleImage.jpg", name: "uploadedFile3", mimetype: "image/jpg")

        //let files = [textFileInfo, pdfFileInfo,imageFileInfo]*/
        _ = add(files: FilesToUpload, toBody: &body, withBoundary: boundary)
         close(body: &body, usingBoundary: boundary)
        let (_, response) = try await URLSession.shared.upload(
                     for: request,
                     from: body
                 )

       
       
        print ("response=",response)
         return response
        
     }
     func createBoundary() -> String {
        // Uncomment the following lines to create a boundary
        // string using a UUID value. Do not forget to comment out
        // the second way!
        
        var uuid = UUID().uuidString
        uuid = uuid.replacingOccurrences(of: "-", with: "")
        uuid = uuid.map { $0.lowercased() }.joined()
        
        let boundary = String(repeating: "-", count: 20) + uuid + "\(Int(Date.timeIntervalSinceReferenceDate))"
        
        return boundary
       
    }
    private func getHttpBody(withBoundary boundary: String) -> Data {
        var body = Data()
        
        for (key, value) in httpBodyParameters.allValues() {
            let values = ["--\(boundary)\r\n",
                "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n",
                "\(value)\r\n"]
            
            _ = body.append(values: values)
        }
        
        return body
    }
    private func add(files: [FileInfo], toBody body: inout Data, withBoundary boundary: String) -> [String]? {
        var status = true
        var failedFilenames: [String]?
        
        for file in files {
            guard let filename = file.filename, let content = file.fileContents, let mimetype = file.mimetype, let name = file.name else { continue }
            
            status = false
            var data = Data()
            
            let formattedFileInfo = ["--\(boundary)\r\n",
                "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\n",
                "Content-Type: \(mimetype)\r\n\r\n"]
            
            if data.append(values: formattedFileInfo) {
                if data.append(values: [content]) {
                    if data.append(values: ["\r\n"]) {
                        status = true
                    }
                }
            }
            
            
            if status {
                body.append(data)
            } else {
                if failedFilenames == nil {
                    failedFilenames = [String]()
                }
                
                failedFilenames?.append(filename)
            }
        }
        
        return failedFilenames
    }
    
    
    private func close(body: inout Data, usingBoundary boundary: String) {
        _ = body.append(values: ["\r\n--\(boundary)--\r\n"])
    }
    
  
}
extension Data {
    mutating func append<T>(values: [T]) -> Bool {
        var newData = Data()
        var status = true
        
        if T.self == String.self {
            for value in values {
                guard let convertedString = (value as! String).data(using: .utf8) else { status = false; break }
                newData.append(convertedString)
            }
        } else if T.self == Data.self {
            for value in values {
                newData.append(value as! Data)
            }
        } else {
            status = false
        }
        
        
        if status {
            self.append(newData)
        }
        
        return status
    }
}
