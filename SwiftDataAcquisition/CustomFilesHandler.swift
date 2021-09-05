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
    
    public func saveDataBatch(dataToSave: [UInt8], timeOfMeasurement: String)
    {
        let pathToDocumentsDir = self.getDocumentDirectory();
//        dataToSave.split(separator: [0,0] as [UInt8]);
        var measurementDataA = Array<UInt8>();
        var measurementDataB = Array<UInt8>();
        var measurementDataC = Array<UInt8>();
        var measurementDataD = Array<UInt8>();
        //licznik na 128 i 129 indeksie
        var i: Int;
        var framesCount: Int;
        i = 0;
        framesCount = 0;
        while i < dataToSave.count{
//                //TU ZACZYNA SIE SEPARATOR
//                //index:      128   129 130  131  132  133  134  135
//                //value:      0,    0,  171, 172, 173, 174, 171, 170
//                //CZYLI TRZEBA
            //PROBLEM WHEN I IS 8, 16, 24, 40, 48 ETC. IT ENTERS THIS
            if( ( i - framesCount * 8 ) % 32 == 0 && i != 0 && ( i - framesCount * 8 ) != 0 ){
                //od 0 do 31 jest czuj 0
                //od 32 do 63 jest czuj 1
                //od 64 do 95 jest czuj 2
                //od 96 do 127 jest czuj 3
                i+=104;
                framesCount += 1;
                // i - 8*liczbaRamek % 32
            }
            if(i<dataToSave.count){
                measurementDataA.append(dataToSave[i]);
                measurementDataA.append(dataToSave[i+1]);
                
                measurementDataB.append(dataToSave[i+32]);
                measurementDataB.append(dataToSave[i+33]);
                
                measurementDataC.append(dataToSave[i+64]);
                measurementDataC.append(dataToSave[i+65]);
                
                measurementDataD.append(dataToSave[i+96]);
                measurementDataD.append(dataToSave[i+97]);
                i+=2;
            }
        }
        
        let dataA = Data(bytes: measurementDataA);
        let dataB = Data(bytes: measurementDataB);
        let dataC = Data(bytes: measurementDataC);
        let dataD = Data(bytes: measurementDataD);
        
        let fileName = timeOfMeasurement + "_measurement_";
        let fileNameA = fileName + "A.txt";
        let fileNameB = fileName + "B.txt";
        let fileNameC = fileName + "C.txt";
        let fileNameD = fileName + "D.txt";
        
        saveDataToFile(ourData: dataA, targetDir: pathToDocumentsDir, targetFileName: fileNameA);
        saveDataToFile(ourData: dataB, targetDir: pathToDocumentsDir, targetFileName: fileNameB);
        saveDataToFile(ourData: dataC, targetDir: pathToDocumentsDir, targetFileName: fileNameC);
        saveDataToFile(ourData: dataD, targetDir: pathToDocumentsDir, targetFileName: fileNameD);
    }
    
    private func saveDataToFile(ourData: Data, targetDir: String, targetFileName: String)
    {
        let finalURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(targetFileName, isDirectory: false)
        print(finalURL)
        do {
            try ourData.write(to: finalURL);
        }
        catch {
            print("Error", error)
            return
        }
        print("Successufull save of file \(targetFileName)");
    }
    /**
     
     
     - Returns: Sorted array of NSString object which represent each filename in documents directory
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
                    let measurementGroupName = String(tmpFileName.prefix(upTo: measurementNamePartStartIndex))
                    
                    //TODO MAKE SURE THAT THOSE BATCHES ARE COMPLETE????
                    
                    foundGroups.append(measurementGroupName as NSString);
                    
                }
            }
        }
        return foundGroups;
    }
    
    public func getFilesInGroup(fileGroup: String) -> Set<URL>
    {
//        var filesInDir = Array<NSString>();
//        var filesInDir = [NSString]();
        var filesInDir = listFilesInDir();
//        filesInDir.sort(by: <#T##(NSString, NSString) throws -> Bool#>);
        var filesInGroup = Set<URL>();
        for file in filesInDir{
            if(file.contains(fileGroup)){
                if(filesInGroup.count >= 4)
                {
                    //found 4 files so theres no need to check further
                    break;
                }
                filesInGroup.insert(URL(string: file as String)!)
            }
        }
        if(filesInGroup.count != 4)
        {
            print("ERROR: FOUND NUMBER DIFFERENT THAN 4 IN SET OF FILES")
        }
        print(filesInGroup);
        return filesInGroup;
    }
    
    public func deleteFilesInGroup(fileGroup: String)
    {
     var filesInDir = getFilesInGroup(fileGroup: fileGroup)
        let pathToDocumentsDir = self.getDocumentDirectory() as String;
        for file in filesInDir{
            do {
                //let filename = targetDir + "/" + targetFileName
                let filePath = pathToDocumentsDir + "/" + file.absoluteString;
                try FileManager.default.removeItem(atPath: filePath)
            } catch let error as NSError {
                print("YOU FUCKED UP BOI");
                print(error);
            }
        }
    }
}
