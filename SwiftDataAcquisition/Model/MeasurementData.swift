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
    var frameIndexes = Array<UInt16>();
    var lastFrameCounterIndex: UInt16 = 0;
    
    var dataIndexes = Array<UInt16>();
    var receivedDataFromMeasuringStations = Array(repeating: Array<UInt16>(), count: 64);
    var lastFrame = Array<UInt16>();
    var previousFrameRest = Array<UInt16>();
    
    public func getLastFrameIndex() -> UInt16
    {
        return self.lastFrameCounterIndex;
    }

    public func getLastFrame() -> Array<UInt16>
    {
        return self.lastFrame;
    }
    
    public func appendData(inputData: Data)
    {
//        self.receivedData.append(contentsOf: inputData);//TODO validate if it will be usefull
        self.receivedDataDecoded.append(contentsOf: decodeData(inputData: inputData));
    }
    
    private func decodeData(inputData: Data) -> Array<UInt16>
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
        
//        for i in stride(from: 64 + (frameOffset), to: resultArr.count, by: 68)
//        {
//            print(resultArr[i], i, resultArr.count)
//            print(resultArr[i+framesMissedIndexOffset], i+framesMissedIndexOffset, "Frames missed index offset: \(framesMissedIndexOffset)")
//            var indexWithMissingFrames = i + framesMissedIndexOffset;
//            if(dataIndexes.count != 0)
//            {
//                //check if previous found frame index is not smaller by one
//                //Rework here needed badly
//                if(dataIndexes[i-1] != resultArr[i]-1)
//                {
//                    //ERROR PREVIOUS FRAME VALUE IS WRONG
////                    resultArr.firstIndex(of: 43948)
//                    let indexesOf0 = resultArr.enumerated().filter
//                    {
//                        $0.element == 43948
//                    }.map{$0.offset}
//                    let indexesOf1 = resultArr.enumerated().filter
//                    {
//                        $0.element == 44462
//                    }.map{$0.offset}
//                    let indexesOf2 = resultArr.enumerated().filter
//                    {
//                        $0.element == 43946
//                    }.map{$0.offset}
//                    if(indexesOf0.count == indexesOf1.count && indexesOf1.count == indexesOf2.count)
//                    {
//                        //if correct then awsome! we have a tad bit easier task
//                        //sizes of found special frame markers match.
//                        //perfect would be like:
//                        /*
//                         indexesOf0[0] = 65
//                         indexesOf1[0] = 66
//                         indexesOf2[0] = 67
//
//                         then the val at index 64 is our frame counter
//                         */
//                        /*TODO
//                         Add check if those frames are actually next to each other (Possibility of data having value of this flag!!
//                        */
//                        for flagIndex in indexesOf0
//                        {
//                            let probableFrameIndex = flagIndex - 1
//                            if(probableFrameIndex > i)
//                            {
//                                //j index is bigger than i
//                                if(resultArr[probableFrameIndex] > self.frameCurrentIndex)
//                                {
//                                    //difference between those indexes should be added to variable which counts missing frames
////                                    i = probableFrameIndex;//NOT A VIABLE METHOD AS i IS A LET CONSTANT
//                                    //
//                                    self.framesMissedCount += Int(resultArr[probableFrameIndex]) - self.frameCurrentIndex;
//                                }
//                                break; //end this for loop as we've found our new value of index i
//                            }
//                            else
//                            {
//                                continue
//                            }
//                        }
//                    }
//                    else
//                    {
//                        //sad part where we have to do magic and remove elements that don't fit
////                        which element is the most often?
//                    }
//                }
//                else
//                {
//                    //yay frames are correct! I assume
//                    //if correct then adding is
//
////                    indexesArr.append(resultArr[i]);
//                }
//            }
//            else
//            {
////                indexesArr.append(resultArr[i]);
//            }
//            self.frameCurrentIndex = Int(resultArr[i]);
//            maxValOfI = i;
//        }
        let indexesOfFlag0 = resultArr.enumerated().filter
        {
            $0.element == 43948
            
        }.map{$0.offset}
        
        let indexesOfFlag2 = resultArr.enumerated().filter
        {
            $0.element == 43946
            
        }.map{$0.offset}
        
        //FRAME SHAPE:
        // DATA * 64
        //COUNTER
        //FLAG0 = 43948
        //FLAG1 = 44462
        //FLAG2 = 43946
        for flag0Index in indexesOfFlag0
        {
            if(resultArr[flag0Index+1]==44462)
            {
                if(resultArr[flag0Index+2]==43946)
                {
                    //flag was found and works correctly
                    lastFrameCounterIndex = resultArr[flag0Index-1];
                    //check if previous flag is found
                    if(self.receivedDataDecoded[Int(lastFrameCounterIndex)]-64 == 43946)
                    {
                        self.lastFrame.removeAll();
                        for i in (lastFrameCounterIndex-64)...lastFrameCounterIndex
                        {
                            self.lastFrame.append(receivedDataDecoded[Int(i)]);
                        }
                    }
                    //value is different than previous flag
                    else
                    {
                        var previousFlag2Index = 0;
                        for flag2index in indexesOfFlag2
                        {
                            if(flag0Index > 64)
                            {
                                if(flag2index < flag0Index)
                                {
                                    previousFlag2Index = flag2index;
                                }
                                else if(previousFlag2Index != 0)
                                {
                                    resultArr.removeSubrange(previousFlag2Index...flag0Index);
                                }
                            }
                            else
                            {
                                //we have to check if
                            }
                        }
                    }
                }
            }
            if(flag0Index + 68 > resultArr.count)
            {
                //we found last element
                self.previousFrameRest.removeAll();
                self.previousFrameRest.append(contentsOf: resultArr[flag0Index...resultArr.count]);
            }
            else if (flag0Index+2==resultArr.count)
            {
                self.previousFrameRest.removeAll();
            }
        }
        
        self.frameOffset = maxValOfI - resultArr.count + 4;
        print(resultArr.count, maxValOfI, self.frameOffset)
        return resultArr;
    }
}
