//
//  ScannerViewModel.swift
//  Kolappen
//
//  Created by Miranda Mutka on 2021-02-15.
//

import Foundation

class ScannerViewModel: ObservableObject {
    
    let scanInterval: Double = 1.0
    
    @Published var torchIsOn : Bool = false
    @Published var lastQrCode : String = "Standby..."
    
    func onFoundQrCode(_ code: String) {
        self.lastQrCode = code
    }
    
}
