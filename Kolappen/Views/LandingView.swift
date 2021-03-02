//
//  LandingView.swift
//  Kolappen
//
//  Created by Miranda Mutka on 2021-02-16.
//

import SwiftUI
struct LandingView: View {
    
    @State var resetScanner : Bool = false
    
    var body: some View {
        NavigationView() {
            ZStack {
                Color("Background")
                VStack {
                    Spacer()
                Text("Kölappen")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                Spacer()
                    Image("QueueSlip")
                        .resizable()
                        .frame(width: 100, height: 170, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    Spacer()
                    NavigationLink(
                        destination: QrScanView(resetScanner: $resetScanner, scannedUid: ""), isActive: $resetScanner) {
                        Button(action: {
                            resetScanner = true
                        }, label: {
                            Text("Skanna QR-kod")
                        })
                        .font(.system(size: 14))
                        .foregroundColor(Color("Link"))
                    }
                    Spacer()
                }
            }
            .ignoresSafeArea()
        }
        
    }
}
