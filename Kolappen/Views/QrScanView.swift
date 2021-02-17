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
    
    @State var codeScanned = false
    
    var scannedUid : String

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
                    if self.viewModel.lastQrCode == "Standby..." {
                        Text("Please scan a QR code")
                            .bold()
                            .lineLimit(5)
                            .padding()
                    } else {
                        NavigationLink(
                            destination: ContentView(scannedUid: self.viewModel.lastQrCode), isActive: $codeScanned) {
                            Button(action: {
                                navigateForward()
                            }) {
                                Text("Queue for \(self.viewModel.lastQrCode)")
                            }
                            
                        }
                    }
                
                
            }
            .padding(.vertical, 20)
//                .onAppear() {
//                    print("status: \(codeScanned)")
//                    while viewModel.lastQrCode != "Standby..." {
//                        codeScanned = true
//                        print("status: \(codeScanned)")
//                        print(viewModel.lastQrCode)
//                        codeScanned = false
//                    }
//
//                }
                
            
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
    
    private func navigateForward() {
        //check if uid is valid
        //pass along uid scanned
        codeScanned = true
    }
    
}

//struct QrScanView_Preview: PreviewProvider {
//    static var previews: some View {
//        QrScanView()
//    }
//}
