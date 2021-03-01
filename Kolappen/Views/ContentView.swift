//
//  ContentView.swift
//  Kolappen
//
//  Created by Miranda Mutka on 2021-01-22.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct ContentView: View {
    
    @Binding var resetScanner : Bool
    
    @State var shopName : String = ""
    @State var currentQueueNumber : Int = 0
    @State var highestQueueNumber : Int = 0
    @State var queueLength : Int = 0
    @State var documentId : String = ""
    @State var myQueueNumber : Int = 0
    
    var scannedUid : String
    var queueNumber : Int
    
    var db = Firestore.firestore()
    
    var body: some View {
        ZStack {
            Color("Background")

            VStack {
                Text("")
                    .foregroundColor(Color("Text"))
                    .font(.title)
                    .padding(.top, 90)
                    .padding(.bottom)
                Spacer()

                if currentQueueNumber == myQueueNumber && currentQueueNumber != 0 {
                    Text("Det är din tur!")
                        .font(.title)
                        .foregroundColor(Color("Text"))
                } else {
                    if currentQueueNumber > myQueueNumber && myQueueNumber != 0 {
                        Text("Ditt nummer har passerats")
                            .font(.title2)
                            .foregroundColor(Color("Text"))
                            .padding(.bottom, 20)
                        
                        ticketButton
                        
                    } else {
                        queueNumberSlip
                    }
                }
                Spacer()
            }
        }
        .ignoresSafeArea()
        .navigationBarTitle("\(shopName)")
        .navigationBarBackButtonHidden(true)
        .onAppear() {
            myQueueNumber = queueNumber
            getShop()
        }
    }
    
    var queueNumberSlip: some View {
        VStack {
            Spacer()
            Text("Din plats i kön:")
                .foregroundColor(Color("Text"))
                .font(.title3)
                .padding(.bottom, 20)
            ZStack {
                Image("QueueSlip")
                    .resizable()
                    .frame(width: 100, height: 170, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                Text("\(myQueueNumber)")
                    .foregroundColor(.black)
                    .font(.title)
                    .bold()
            }
            Spacer()
            Text("Nu betjänas:")
                .foregroundColor(Color("Text"))
                .font(.title3)
            Text("\(currentQueueNumber)")
                .foregroundColor(Color("Text"))
                .font(.title3)
                .bold()
                .padding(.bottom, 20)
            Spacer()
            Button(action: {
                resetScanner = false
            }, label: {
                Text("Gå ur kö")
                    .font(.title3)
                    .bold()
                    .foregroundColor(Color(.systemRed))
                    .padding(.horizontal)
            })
            Spacer()
        }
        
    }
    
    var ticketButton: some View {
        Button(action: {
            newTicket()
        }, label: {
            Text("Ta kölapp")
                .font(.title2)
                .foregroundColor(Color("Link"))
                .padding(.horizontal)
        })
    }
    
    private func newTicket() {
        myQueueNumber = highestQueueNumber + 1
        do {
            db.collection("users").document(documentId).updateData(["highestQueueNumber" : myQueueNumber])
        }
    }
    
    private func getShop() {
        db.collection("users").whereField("uid", isEqualTo: scannedUid).addSnapshotListener() { (snapshot, error) in
            if let error = error {
                print("there was an error regarding snapshot: \(error)")
            } else {
                for document in snapshot!.documents {
                    
                    let result = Result {
                        try document.data(as: Shop.self)
                    }
                    
                    switch result {
                    case .success(let shop):
                        if let shop = shop {
                            shopName = shop.shopName
                            currentQueueNumber = shop.currentQueueNumber
                            highestQueueNumber = shop.highestQueueNumber
                            queueLength = highestQueueNumber - currentQueueNumber
                            documentId = document.documentID
                            
                            print("Shop: \(shopName)")
                            
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
    
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
