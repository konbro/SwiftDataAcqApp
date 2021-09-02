//
//  FilesHandler.swift
//  SwiftDataAcquisition
//
//  Created by Konrad von Broen on 29/08/2021.
//

import Foundation

class CustomFilesHandler {
    let fm = FileManager.default
    
    public func getDocumentDirectory() -> String {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                    .userDomainMask,
                                                                    true)
        return documentDirectory[0]
    }
    
    public func saveDataBatch(dataToSave: String, timeOfMeasurement: String)
    {
        let pathToDocumentsDir = self.getDocumentDirectory();
        //TODO
        // divide dataToSave in 4 parts and save into
        // Filename_a.txt
        // Filename_b.txt
        // Filename_c.txt
        // Filename_d.txt
        // Was it supposed to be divided in 4 predefined parts or were there more parts possible?
        
        // We have 64 measure devices and each file contains data from 16.
        
        //TODO - SPLIT RECEIVED DATA
        let measurementBatch0 = "null";
        let measurementBatch1 = "null";
        let measurementBatch2 = "null";
        let measurementBatch3 = "null";
        
        let fileName = timeOfMeasurement + "_measurement_";
        let fileNameA = fileName + "A.txt";
        let fileNameB = fileName + "B.txt";
        let fileNameC = fileName + "C.txt";
        let fileNameD = fileName + "D.txt";
        
        saveToFile(text: measurementBatch0, targetDir: pathToDocumentsDir, targetFileName: fileNameA)
        saveToFile(text: measurementBatch1, targetDir: pathToDocumentsDir, targetFileName: fileNameB)
        saveToFile(text: measurementBatch2, targetDir: pathToDocumentsDir, targetFileName: fileNameC)
        saveToFile(text: measurementBatch3, targetDir: pathToDocumentsDir, targetFileName: fileNameD)
    }
    
    private func saveToFile(text: String, targetDir: String, targetFileName: String)
    {
        let filename = targetDir + "/" + targetFileName
//        let fileURL = URL(string: filename)!;
        do {
            try text.write(toFile: filename, atomically: true, encoding: .utf8);
        }
        catch {
            print("Error", error)
            return
        }
//        do {
//            try text.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
//        }
//        catch let error as NSError
//        {
//            print("Failed to write to file to URL: \(filename), Error: " + error.localizedDescription)
//        }
        print("Successufull save of file \(targetFileName)");
        
        
        /*
         private func save(text: String,
         toDirectory directory: String,
         withFileName fileName: String) {
         guard let filePath = self.append(toPath: directory,
         withPathComponent: fileName) else {
         return
         }
         
         do {
         try text.write(toFile: filePath,
         atomically: true,
         encoding: .utf8)
         } catch {
         print("Error", error)
         return
         }
         
         print("Save successful")
         print("FilePath: \(filePath)")
         }
         */
    }
    
    /**
     
     
     - Returns: Array of NSString object which represent each filename in documents directory
     */
    private func listFilesInDir() -> Array<NSString>
    {
        let docDir = self.getDocumentDirectory()
        var resultArray = [NSString]();
        print("DocumentsDir:")
        do{
            var items = try fm.contentsOfDirectory(atPath: docDir)
            //sorting of list in order to get list in which we can get element by using simple [x+1] operand
            items.sort()
            for item in items{
                print("FOUND: \(item)")
                resultArray.append(item as NSString)
            }
        }
        catch
        {
            print("LOL U FAILED - error reading files in docs directory")
        }
        return resultArray
    }
    
    public func listFilesGroups() -> Array<NSString>
    {
//        let docDir = self.getDocumentDirectory()
        var foundGroups = [NSString]();
        var filesInDir = [NSString]();
        filesInDir = listFilesInDir();
        if(filesInDir.isEmpty)
        {
            print("NO FILES FOUND IN DOCS DIR")
            return filesInDir;
        }
        if((filesInDir.count%4) != 0)
        {
            print("WARNING: other files found in docs dir")
        }
        for file in filesInDir{
            if(!file.contains("_measurement_A.txt")){
                //do nothing
            }
            else{
                //file contains "_measurement_" part
                
                //TODO check index of current file and then check
                
                let indexOfFirstFile = filesInDir.firstIndex(of: file);
                let fileB = filesInDir[indexOfFirstFile!+1];
                let fileC = filesInDir[indexOfFirstFile!+1];
                let fileD = filesInDir[indexOfFirstFile!+1];
                if(fileB == nil || fileC == nil || fileD == nil)
                {
                    //TODO LEARN HOW TO HANDLE EXCEPTIONS IN SWIFT
                    //throw
                    print("NOT COMPLETE MEASUREMENT FOUND!")
                }	
                else
                {
                    let tmpFileName = file as String
                    let measurementNamePartStartIndex = tmpFileName.index(tmpFileName.endIndex, offsetBy: -18);
//                    let measurementGroupName = tmpFileName.prefix(upTo: measurementNamePartStartIndex))
                    let measurementGroupName = String(tmpFileName.prefix(upTo: measurementNamePartStartIndex))
                    
                    //TODO MAKE SURE THAT THOSE BATCHES ARE COMPLETE????
                    
                    foundGroups.append(measurementGroupName as NSString);
                    
                }
            }
        }
        return foundGroups;
    }
    
    
    
    
}
