//
//  QrScanView.swift
//  Kolappen
//
//  Created by Miranda Mutka on 2021-02-15.
//

import Foundation
import SwiftUI

struct QrScanView: View {
    
    @ObservedObject var viewModel = ScannerViewModel()

    var body: some View {
        
        ZStack {
            QrCodeScannerView()
                .found(r: self.viewModel.onFoundQrCode)
                .torchLight(isOn: self.viewModel.torchIsOn)
                .interval(delay: self.viewModel.scanInterval)
            
            VStack {
                
                VStack {
                
                Text("Scanna QR-koden framför dig för att få en kölapp")
                    .font(.subheadline)
                Text(self.viewModel.lastQrCode)
                    .bold()
                    .lineLimit(5)
                    .padding()
                
            }
            .padding(.vertical, 20)
            
            Spacer()
            HStack {
                Button(action: {
                    self.viewModel.torchIsOn.toggle()
                }, label: {
                    Image(systemName: self.viewModel.torchIsOn ? "bolt.fill" : "bolt.slash.fill")
                        .imageScale(.large)
                        .foregroundColor(self.viewModel.torchIsOn ? Color.yellow : Color.blue)
                        .padding()
                })
            }
            .background(Color("Background"))
            .cornerRadius(10)
            
        }.padding()
            
        }
        
    }

}

struct QrScanView_Preview: PreviewProvider {
    static var previews: some View {
        QrScanView()
    }
}
