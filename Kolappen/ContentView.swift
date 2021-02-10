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
    
    var db = Firestore.firestore()
    
    var body: some View {
        Text("Hello, kölappisar!")
            .padding()
            .onAppear() {
                print("running!")
                db.collection("test").addDocument(data: ["testRun" : "Kölappen \(Date())"])
            }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
