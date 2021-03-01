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
    
    @Binding var resetScanner : Bool
    
    @State var codeScanned = false
    
    @State var shopName : String = ""

    @State var shopOpen : Bool = true
    
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
    
    @State var currentQueueNumber : Int = 0
    @State var highestQueueNumber : Int = 0
    @State var queueLength : Int = 0
    
    @State var uid : String = ""
    
    @State var uidWasFound = false
    @State var hasScanned = false
    
    @State var documentId : String = ""
    @State var myQueueNumber : Int = 0

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
                                    shopIsClosed
                                    //Button to rescan goes here
                                } else {
                                    readyToQueue
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
                
            if shopOpen {
                QrCodeScannerView()
                .found(r: self.viewModel.onFoundQrCode)
                .torchLight(isOn: self.viewModel.torchIsOn)
                .interval(delay: self.viewModel.scanInterval)
                .frame(width: 350, height: 350, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                .cornerRadius(10)
                    
            }
        }
        .ignoresSafeArea()
    }
    
    var shopIsClosed: some View {
        VStack {
            Spacer()
            Text("Butiken är tyvärr stängd - kom gärna tillbaka senare")
                .foregroundColor(Color("Text"))
                .multilineTextAlignment(.center)
                .padding(.leading, 50)
                .padding(.trailing, 50)
                .padding(.bottom)
            Text("Öppettider:")
                .foregroundColor(Color("Text"))
                .font(.title3)
                .bold()
                .padding(.top)
                .padding(.bottom)
            HStack {
                VStack (alignment: .leading) {
                    Text("Måndag:")
                        .foregroundColor(Color("Text"))
                    Text("Tisdag:")
                        .foregroundColor(Color("Text"))
                    Text("Onsdag:")
                        .foregroundColor(Color("Text"))
                    Text("Torsdag:")
                        .foregroundColor(Color("Text"))
                    Text("Fredag:")
                        .foregroundColor(Color("Text"))
                    Text("Lördag:")
                        .foregroundColor(Color("Text"))
                    Text("Söndag:")
                        .foregroundColor(Color("Text"))
                }
                VStack (alignment: .trailing) {
                    Text("\(mondayOpen) - \(mondayClose)")
                        .foregroundColor(Color("Text"))
                    Text("\(tuesdayOpen) - \(tuesdayClose)")
                        .foregroundColor(Color("Text"))
                    Text("\(wednesdayOpen) - \(wednesdayClose)")
                        .foregroundColor(Color("Text"))
                    Text("\(thursdayOpen) - \(thursdayClose)")
                        .foregroundColor(Color("Text"))
                    Text("\(fridayOpen) - \(fridayClose)")
                        .foregroundColor(Color("Text"))
                    Text("\(saturdayOpen) - \(saturdayClose)")
                        .foregroundColor(Color("Text"))
                    Text("\(sundayOpen) - \(sundayClose)")
                        .foregroundColor(Color("Text"))
                }
            }
            Spacer()
        }
        .navigationBarTitle("\(shopName)")
    }
    
    var readyToQueue: some View {
        NavigationLink(
            destination: ContentView(resetScanner: $resetScanner, scannedUid: self.viewModel.lastQrCode, queueNumber: myQueueNumber), isActive: $codeScanned) {
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
            }
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
                                
                                documentId = document.documentID

                                let openingHours = shop.hoursOpen
                                let closingHours = shop.hoursClosed

                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"

                                let timePickerMondayOpen = dateFormatter.date(from: openingHours[0])!
                                let timePickerMondayClose = dateFormatter.date(from: closingHours[0])!
                                
                                let timePickerTuesdayOpen = dateFormatter.date(from: openingHours[1])!
                                let timePickerTuesdayClose = dateFormatter.date(from: closingHours[1])!
                                
                                let timePickerWednesdayOpen = dateFormatter.date(from: openingHours[2])!
                                let timePickerWednesdayClose = dateFormatter.date(from: closingHours[2])!
                                
                                let timePickerThursdayOpen = dateFormatter.date(from: openingHours[3])!
                                let timePickerThursdayClose = dateFormatter.date(from: closingHours[3])!
                                
                                let timePickerFridayOpen = dateFormatter.date(from: openingHours[4])!
                                let timePickerFridayClose = dateFormatter.date(from: closingHours[4])!
                                
                                let timePickerSaturdayOpen = dateFormatter.date(from: openingHours[5])!
                                let timePickerSaturdayClose = dateFormatter.date(from: closingHours[5])!
                                
                                let timePickerSundayOpen = dateFormatter.date(from: openingHours[6])!
                                let timePickerSundayClose = dateFormatter.date(from: closingHours[6])!
                                
                                dateFormatter.timeStyle = .short
                                
                                mondayOpen = dateFormatter.string(from: timePickerMondayOpen)
                                mondayClose = dateFormatter.string(from: timePickerMondayClose)
                                
                                tuesdayOpen = dateFormatter.string(from: timePickerTuesdayOpen)
                                tuesdayClose = dateFormatter.string(from: timePickerTuesdayClose)
                                
                                wednesdayOpen = dateFormatter.string(from: timePickerWednesdayOpen)
                                wednesdayClose = dateFormatter.string(from: timePickerWednesdayClose)
                                
                                thursdayOpen = dateFormatter.string(from: timePickerThursdayOpen)
                                thursdayClose = dateFormatter.string(from: timePickerThursdayClose)
                                
                                fridayOpen = dateFormatter.string(from: timePickerFridayOpen)
                                fridayClose = dateFormatter.string(from: timePickerFridayClose)
                                
                                saturdayOpen = dateFormatter.string(from: timePickerSaturdayOpen)
                                saturdayClose = dateFormatter.string(from: timePickerSaturdayClose)
                                
                                sundayOpen = dateFormatter.string(from: timePickerSundayOpen)
                                sundayClose = dateFormatter.string(from: timePickerSundayClose)
                                
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
        myQueueNumber = highestQueueNumber + 1
        do {
            db.collection("users").document(documentId).updateData(["highestQueueNumber" : myQueueNumber])
        }
        codeScanned = true
    }
    
}

//struct QrScanView_Preview: PreviewProvider {
//    static var previews: some View {
//        QrScanView()
//    }
//}
