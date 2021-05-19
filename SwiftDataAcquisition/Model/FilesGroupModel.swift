//
//  FilesGroupModel.swift
//  SwiftDataAcquisition
//
//  Created by Konrad von Broen on 19/05/2021.
//

import Foundation

//files will be saved with names such as:
// 2021-01-01-A
// 2021-01-01-B
// 2021-01-01-C
// 2021-01-01-D
// in order to avoid confusion. <- TBD

struct FileGroup {
    let date: Date
    let file_0: String
    let file_1: String
    let file_2: String
    let file_3: String
    
    init(_date: Date, _file_0: String, _file_1: String, _file_2: String, _file_3: String)
    {
        self.date = _date;
        self.file_0 = _file_0;
        self.file_1 = _file_1;
        self.file_2 = _file_2;
        self.file_3 = _file_3;
    }
}
