//
//  MetalCaculationModule.swift
//  MetalCaculation
//
//  Created by i9400503 on 2021/1/22.
//

import Foundation
import Metal


let arrayLength = 1 << 24 // 2^24
let bufferSize = arrayLength * MemoryLayout<Float>.size

final class MetalCaculationModule{
    var _mDevice : MTLDevice
    
    var _mFunctionPSO : MTLComputePipelineState
    
    var _mCommandQueue : MTLCommandQueue
    
    
    var _mBufferA : MTLBuffer?
    
    var _mBufferB : MTLBuffer?
    
    var _mBufferResult : MTLBuffer?
    
    init(device : MTLDevice){
        _mDevice = device
        
        let library = _mDevice.makeDefaultLibrary()
        
        guard let function = library?.makeFunction(name: "add_arrays")else{
            fatalError("can not init MLT function with add_arrys")
        }
        
        guard let function_PSO = try? _mDevice.makeComputePipelineState(function: function) else {
            fatalError("can not init pipelineStatus")
        }
        
        _mFunctionPSO = function_PSO
        guard let commandQueue = _mDevice.makeCommandQueue() else{
            fatalError("can not init commandQueue")
        }
        
        _mCommandQueue = commandQueue
        
    }
}

extension MetalCaculationModule{
    final func generateBuffer(){
        _mBufferA = _mDevice.makeBuffer(length: bufferSize, options: .storageModeShared)
        _mBufferB = _mDevice.makeBuffer(length: bufferSize, options: .storageModeShared)
        _mBufferResult = _mDevice.makeBuffer(length: bufferSize, options: .storageModeShared)
        
        generalRandomFloatData(buffer: _mBufferA)
        generalRandomFloatData(buffer: _mBufferB)
    }
    
    final private func generalRandomFloatData(buffer : MTLBuffer?){
        guard let buffer = buffer else {return}
        var dataPtr =  buffer.contents()
        
        for idx in 0..<arrayLength{
            dataPtr.storeBytes(of: Float(idx), as: Float.self)
            dataPtr += MemoryLayout<Float>.stride
        }
    }
    
    final func setupComputeCommand(){
        let commandBuffer = _mCommandQueue.makeCommandBuffer()
        let computeEncoder = commandBuffer?.makeComputeCommandEncoder()
        
        //set pipeline status and argument data
        computeEncoder?.setComputePipelineState(_mFunctionPSO)
        computeEncoder?.setBuffer(_mBufferA, offset: 0, index: 0)
        computeEncoder?.setBuffer(_mBufferB, offset: 0, index: 1)
        computeEncoder?.setBuffer(_mBufferResult, offset: 0, index: 2)
        
        let gridSize = MTLSizeMake(arrayLength, 1, 1)
        
        var threadGroupSize = _mFunctionPSO.maxTotalThreadsPerThreadgroup
        if threadGroupSize > arrayLength{
            threadGroupSize = arrayLength
        }
        
        let threadgroupSize = MTLSizeMake(threadGroupSize,1,1)
        computeEncoder?.dispatchThreads(gridSize, threadsPerThreadgroup: threadgroupSize)
        // End the compute pass.
        computeEncoder?.endEncoding()
        
        // Execute the command.
        commandBuffer?.commit()
        
        commandBuffer?.waitUntilCompleted()        
        
    }
    
    private func verifyResults(){
        //check the result
        var resultPoint = _mBufferResult?.contents()
        
        var Apoint = _mBufferA?.contents()
        var Bpoint = _mBufferB?.contents()
        
        
        for idx in 0..<arrayLength {
            
            if let valueA = Apoint?.load(as: Float.self) ,
               let valueB = Bpoint?.load(as: Float.self) ,
               let valueResult = resultPoint?.load(as: Float.self)
            {
                if valueResult != valueA + valueB{
                    print(idx)
                    print(valueA)
                    print(valueB)
                    print(valueResult)
                    assert(valueResult == valueA + valueB)
                }
                Apoint! += MemoryLayout<Float>.stride
                Bpoint! += MemoryLayout<Float>.stride
                resultPoint! += MemoryLayout<Float>.stride
            }
        }
        Apoint! -= MemoryLayout<Float>.stride
        Bpoint! -= MemoryLayout<Float>.stride
        resultPoint! -= MemoryLayout<Float>.stride
        print("last result , A : \(Apoint?.load(as: Float.self) ) ,  B: \(Bpoint?.load(as: Float.self) ),RESULT : \(resultPoint?.load(as: Float.self) )")
        print("caculate complete")
    }
}
