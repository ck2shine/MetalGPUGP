//
//  NormalCaculationModule.swift
//  MetalCaculation
//
//  Created by Shine on 2021/1/24.
//

import Foundation
final class NormalCaculationModule{
    
    private var arrayA : [Float] = []
    private var arrayB : [Float] = []
    private var arrayResult : [Float] = []
    
    
    final func caculateArray(){
        arrayA = generateData()
        arrayB = generateData()
        for idx in 0..<arrayLength{
            arrayResult.append(arrayA[idx]+arrayB[idx])
        }
    }
    
    
    private func generateData()->[Float]{
        var tempAry : [Float] = []
        for idx in 0..<arrayLength{
            tempAry.append(Float(idx))
        }
        return tempAry
    }
    
}
