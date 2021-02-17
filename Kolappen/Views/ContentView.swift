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
    
    @State var shopName : String = ""
    @State var currentQueueNumber : Int = 0
    @State var highestQueueNumber : Int = 0
    @State var queueLength : Int = 0
    @State var documentId : String = ""
    @State var myQueueNumber : Int = 0
    
    var scannedUid : String
    
    var db = Firestore.firestore()
    
    var body: some View {
        VStack {
            Text("\(shopName)")
            Text("\(scannedUid)")
            Spacer()
            if currentQueueNumber == myQueueNumber && currentQueueNumber != 0 {
                Text("Det är din tur!")
                    .foregroundColor(Color("Text"))
            } else {
                if currentQueueNumber > myQueueNumber && myQueueNumber != 0 {
                    Text("Ditt nummer har passerats")
                        .foregroundColor(Color("Text"))
                        .padding(.bottom, 20)
                    ticketButton
                } else {
                    Text("Nu betjänas: \(currentQueueNumber)")
                        .foregroundColor(Color("Text"))
                        .padding(.bottom, 20)
                    if myQueueNumber != 0 {
                        Text("Mitt könummer: \(myQueueNumber)")
                            .foregroundColor(Color("Text"))
                    } else {
                        ticketButton
                    }
                }
            }
            Spacer()
        }
        .padding()
        .onAppear() {
            print("running!")
            getShop()
        }
    }
    
    var ticketButton: some View {
        Button(action: {
            newTicket()
        }, label: {
            Text("Ta kölapp")
                .font(.title2)
                .foregroundColor(Color("Text"))
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
