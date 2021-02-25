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

    @State private var shopOpen : Bool = false
    
    
    @State var currentQueueNumber : Int = 0
    @State var highestQueueNumber : Int = 0
    @State var queueLength : Int = 0
    
    
    @State var uid : String = ""
    
    @State var uidWasFound = false
    @State var hasScanned = false
    
    @State private var mondayOpen : String = ""
    @State private var mondayClose : String = ""
    @State private var tuesdayOpen : String = ""
    @State private var tuesdayClose : String = ""
    @State private var wednesdayOpen : String = ""
    @State private var wednesdayClose : String = ""
    @State private var thursdayOpen : String = ""
    @State private var thursdayClose : String = ""
    @State private var fridayOpen : String = ""
    @State private var fridayClose : String = ""
    @State private var saturdayOpen : String = ""
    @State private var saturdayClose : String = ""
    @State private var sundayOpen : String = ""
    @State private var sundayClose : String = ""

    var db = Firestore.firestore()
    
    var scannedUid : String

    var body: some View {
            ZStack {
                Color("Background")
                VStack {
                    VStack {
                        Spacer()

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
                                    VStack {
                                        Text("\(shopName)")
                                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                            .foregroundColor(Color("Text"))
                                        Text("Butiken är tyvärr stängd - kom gärna tillbaka senare")
                                            .foregroundColor(Color("Text"))
                                            .multilineTextAlignment(/*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/)
                                        padding(.top)
                                        padding(.bottom)
                                        Text("Öppettider:")
                                            .foregroundColor(Color("Text"))
                                            .bold()
                                            .padding(.bottom)
                                        HStack {
                                            Text("Måndag")
//                                            Text("\(mondayOpen) - \(mondayClose)")
                                        }
                                        Spacer()
                                        
                                        
                                    }
                                    //Button to rescan
                                } else {
                                    NavigationLink(
                                        destination: ContentView(scannedUid: self.viewModel.lastQrCode), isActive: $codeScanned) {
                                        VStack {
                                            Spacer()
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
                                            Text("")
                                                .frame(width: 350, height: 350, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                                .padding(.top)
                                            Spacer()
                                            Button(action: {
                                                navigateForward()
                                            }) {
                                                Text("Ställ dig i kö till \(shopName)")
                                            }
                                            Spacer()
                                        }
                                        
                                        }.onAppear() {
                                            codeWasScanned()
    //                                        navigateForward()
                                        }
                                }
                            }
                            
                        }
                        if !hasScanned {
                        Spacer()
                        Text("")
                            .frame(width: 350, height: 350, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        Spacer()
                            Text("Scanna QR-koden framför dig för att få en kölapp")
                                .foregroundColor(Color("Text"))
                                .font(.subheadline)
                        Spacer()
                        }
                }
            }
            QrCodeScannerView()
                .found(r: self.viewModel.onFoundQrCode)
                .torchLight(isOn: self.viewModel.torchIsOn)
                .interval(delay: self.viewModel.scanInterval)
                .frame(width: 350, height: 350, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .cornerRadius(10)
            }
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
                                
                                let openingHours = shop.hoursOpen
                                let closingHours = shop.hoursClosed
//
//                                let dateFormatter = DateFormatter()
//                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
//
//                                let timePickerMondayOpen = dateFormatter.date(from: openingHours[0])!
//                                let timePickerTuesdayOpen = dateFormatter.date(from: openingHours[1])!
//                                let timePickerWednesdayOpen = dateFormatter.date(from: openingHours[2])!
//                                let timePickerThursdayOpen = dateFormatter.date(from: openingHours[3])!
//                                let timePickerFridayOpen = dateFormatter.date(from: openingHours[4])!
//                                let timePickerSaturdayOpen = dateFormatter.date(from: openingHours[5])!
//                                let timePickerSundayOpen = dateFormatter.date(from: openingHours[6])!
                                
//                                let timePickerMondayClose = dateFormatter.date(from: closingHours[0])!
//                                let timePickerTuesdayClose = dateFormatter.date(from: closingHours[1])!
//                                let timePickerWednesdayClose = dateFormatter.date(from: closingHours[2])!
//                                let timePickerThursdayClose = dateFormatter.date(from: closingHours[3])!
//                                let timePickerFridayClose = dateFormatter.date(from: closingHours[4])!
//                                let timePickerSaturdayClose = dateFormatter.date(from: closingHours[5])!
//                                let timePickerSundayClose = dateFormatter.date(from: closingHours[6])!
//
//                                dateFormatter.timeStyle = .short
//                                mondayOpen = dateFormatter.string(from: timePickerMondayOpen)
//                                mondayClose = dateFormatter.string(from: timePickerMondayClose)
                                
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
