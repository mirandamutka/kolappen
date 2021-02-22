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
    
    
    @State var currentQueueNumber : Int = 0
    @State var highestQueueNumber : Int = 0
    @State var queueLength : Int = 0
    
    
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
                .frame(width: 400, height: 400, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .background(Color("Background"))
                .cornerRadius(10)

                
            VStack {
                VStack {
                    Spacer()
                    if !hasScanned {
                        Text("Scanna QR-koden framför dig för att få en kölapp")
                            .foregroundColor(Color("Text"))
                            .font(.subheadline)
                    }
                    if self.viewModel.lastQrCode == "Standby..." {
                        VStack {
                        Text("Söker efter QR kod...")
                            .bold()
                            .lineLimit(5)
                            .padding()
                            .foregroundColor(Color("Text"))
                        }
                    } else {
                        if uidWasFound == false && hasScanned == true {
                            Text("") //Button to rescan when QR-code is not found
                        } else {
                            if shopOpen == false {
                                Text("Butiken är tyvärr stängd - kom gärna tillbaka senare")
                                //Button to rescan
                            } else {
                                NavigationLink(
                                    destination: ContentView(scannedUid: self.viewModel.lastQrCode), isActive: $codeScanned) {
                                    Button(action: {
                                        navigateForward()
                                    }) {
                                        VStack {
                                            Text("Nu betjänas nummer:")
                                                .foregroundColor(Color("Text"))
                                                .bold()
                                            Text("\(currentQueueNumber)")
                                                .foregroundColor(Color("Text"))
                                                .bold()
                                                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                            Text("Personer i kö:")
                                                .foregroundColor(Color("Text"))
                                                .bold()
                                            Text("\(queueLength)")
                                                .foregroundColor(Color("Text"))
                                                .bold()
                                                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                            Spacer()
                                            Text("Ställ dig i kö till \(shopName)")
                                                .padding()
                                                .foregroundColor(Color("Text"))
                                                .background(Color("Background"))
                                        }
                                        .padding(.vertical, 20)
                                        
                                    }
                                    
                                    }.onAppear() {
                                        codeWasScanned()
//                                        navigateForward()
                                    }
                            }
                        }
                        
                    }
                
                
            }
//            .padding(.vertical, 20)

            Spacer()
//            HStack {
//                Text("")
//            }
                        
        }
            .padding()
            
            
        }
        .background(Color("Background"))
        .ignoresSafeArea()
    }
        
    private func codeWasScanned() {
        hasScanned = true
        db.collection("users").getDocuments() { (snapshot, error) in
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
                                
                                currentQueueNumber = shop.currentQueueNumber
                                highestQueueNumber = shop.highestQueueNumber
                                queueLength = highestQueueNumber - currentQueueNumber
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
