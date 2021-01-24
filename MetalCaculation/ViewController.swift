//
//  ViewController.swift
//  MetalCaculation
//
//  Created by i9400503 on 2021/1/22.
//

import UIKit
import Metal
class ViewController: UIViewController {

    @IBOutlet weak var CPUTextLabel: UILabel!
    @IBOutlet weak var GPUGPTextLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }

    @IBAction func runGPU(_ sender: Any) {
        let start = DispatchTime.now()
        DispatchQueue.global().async {
            let device = MTLCreateSystemDefaultDevice()
            let model = MetalCaculationModule(device: device!)
            model.generateBuffer()
            model.setupComputeCommand()
            let end = DispatchTime.now()
            let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
            let timeInterval = Double(nanoTime) / 1_000_000_000
            DispatchQueue.main.async {
                self.GPUGPTextLabel.text = "\(timeInterval) seconds"
                print("GPU done")
            }
        }
    }
    @IBAction func runCPU(_ sender: Any) {
        
        let start = DispatchTime.now()
        DispatchQueue.global().async {
            let module = NormalCaculationModule()
            module.caculateArray()
            let end = DispatchTime.now()
            let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
            let timeInterval = Double(nanoTime) / 1_000_000_000
            DispatchQueue.main.async {
                self.CPUTextLabel.text = "\(timeInterval) seconds"
                print("CPU done")
            }
        }
    }
    
}

