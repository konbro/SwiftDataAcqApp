//
//  MeasurementDataModel.swift
//  SwiftDataAcquisition
//
//  Created by Konrad von Broen on 14/12/2021.
//

import Foundation

class MeasurementDataModel {
    
    var frameOffset: Int = 0;
    var frameCurrentIndex: Int = 0;
    var framesMissedCount: Int = 0;
    var receivedData = Array<UInt8>();
    var receivedDataDecoded = Array<UInt16>();
    
    var indexesArr = Array<UInt16>();
    var receivedDataFromMeasuringStations = [[UInt16]]();
    
    
    private func decodeData(inputData: Array<UInt8>) -> Array<UInt16>
    {
        var resultArr = Array<UInt16>();
        var tmpUInt16 = UInt16();
        for i in stride(from: 0, to: inputData.count, by: 2){
            tmpUInt16 = UInt16(inputData[i]);
            tmpUInt16 = tmpUInt16 << 8;
            tmpUInt16 = tmpUInt16|UInt16(inputData[i+1]);
            resultArr.append(tmpUInt16);
        }
        var maxValOfI = 0;
        var framesMissedIndexOffset = 0; //TODO make class-wide variable
        for i in stride(from: 64 + (frameOffset), to: resultArr.count, by: 68)
        {
            print(resultArr[i], i, resultArr.count)
            print(resultArr[i+framesMissedIndexOffset], i+framesMissedIndexOffset, "Frames missed index offset: \(framesMissedIndexOffset)")
            var indexWithMissingFrames = i + framesMissedIndexOffset;
            if(indexesArr.count != 0)
            {
                //check if previous found frame index is not smaller by one
                //Rework here needed badly
                if(indexesArr[i-1] != resultArr[i]-1)
                {
                    //ERROR PREVIOUS FRAME VALUE IS WRONG
//                    resultArr.firstIndex(of: 43948)
                    let indexesOf0 = resultArr.enumerated().filter
                    {
                        $0.element == 43948
                    }.map{$0.offset}
                    let indexesOf1 = resultArr.enumerated().filter
                    {
                        $0.element == 44462
                    }.map{$0.offset}
                    let indexesOf2 = resultArr.enumerated().filter
                    {
                        $0.element == 43946
                    }.map{$0.offset}
                    if(indexesOf0.count == indexesOf1.count && indexesOf1.count == indexesOf2.count)
                    {
                        //sizes of found special frame markers match.
                        //perfect would be like:
                        /*
                         indexesOf0[0] = 65
                         indexesOf1[0] = 66
                         indexesOf2[0] = 67
                         
                         then the val at index 64 is our frame counter
                         */
                        /*TODO
                         Add check if those frames are actually next to each other (Possibility of data having value of this flag!!
                        */
                        for flagIndex in indexesOf0
                        {
                            let probableFrameIndex = flagIndex - 1
                            if(probableFrameIndex > i)
                            {
                                //j index is bigger than i
                                if(resultArr[probableFrameIndex] > self.frameCurrentIndex)
                                {
                                    //difference between those indexes should be added to variable which counts missing frames
//                                    i = probableFrameIndex;//NOT A VIABLE METHOD AS i IS A LET CONSTANT
                                    //
                                    self.framesMissedCount += Int(resultArr[probableFrameIndex]) - self.frameCurrentIndex;
                                }
                                break; //end this for loop as we've found our new value of index i
                            }
                            else
                            {
                                continue
                            }
                        }
                    }
                    else
                    {
                        //sad part where we have to do magic and remove elements that don't fit
                    }
                }
                else
                {
                    indexesArr.append(resultArr[i]);
                }
            }
            else
            {
                indexesArr.append(resultArr[i]);
            }
            self.frameCurrentIndex = Int(resultArr[i]);
            maxValOfI = i;
        }
        self.frameOffset = maxValOfI - resultArr.count + 4;
        print(resultArr.count, maxValOfI, self.frameOffset)
        return resultArr;
    }
}
