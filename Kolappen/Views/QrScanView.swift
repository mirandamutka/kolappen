//
//  QrScanView.swift
//  Kolappen
//
//  Created by Miranda Mutka on 2021-02-15.
//

import Foundation
import SwiftUI
import Firebase

struct QrScanView: View {
    
    @ObservedObject var viewModel = ScannerViewModel()
    
    @State var codeScanned = false
    
    
    @State var shopName : String = ""

    @State var shopOpen : Bool = true
    
    @State var uid : String = ""
    
    @State var uidWasFound = false
    @State var hasScanned = false
    
    
    
    var db = Firestore.firestore()
    
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
                        if uidWasFound == false && hasScanned == true {
                            Text("") //Button to rescan when QR-code is not found
                        } else {
                            if shopOpen == false {
                                Text("Butiken är tyvärr stängd - kom gärna tillbaka senare")
                            } else {
                                NavigationLink(
                                    destination: ContentView(scannedUid: self.viewModel.lastQrCode), isActive: $codeScanned) {
                                    Button(action: {
                                        navigateForward()
                                    }) {
                                        Text("Ställ dig i kö till \(shopName)")
                                    }
                                    
                                    }.onAppear() {
                                        codeWasScanned()
//                                        navigateForward()
                                    }
                            }
                        }
                        
                    }
                
                
            }
            .padding(.vertical, 20)
            
            Spacer()
            HStack {
                Text("")
            }
            .background(Color("Background"))
            .cornerRadius(10)
            
        }.padding()
            
            
        }
    }
    
    private func codeWasScanned() {
        hasScanned = true
        db.collection("users").addSnapshotListener() { (snapshot, error) in
            if let error = error {
                print("Could not read from firebase: \(error)")
            } else {
                for document in snapshot!.documents {
                    
                    let result = Result {
                        try document.data(as: Shop.self)
                    }
                    
                    switch result {
                    case .success(let shop):
                        if let shop = shop {
                            uid = shop.uid
                            
                            if uid == self.viewModel.lastQrCode {
                                uidWasFound = true
                                shopName = shop.shopName
                                shopOpen = shop.shopOpen
                            }
                            
                            print("uidWasFound: \(uidWasFound)")
                            
                        } else {
                            print("Document does not exist")
                        }
                    case.failure(let error):
                        print("Error decoding item: \(error)")
                    }
                    
                }
            }
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
