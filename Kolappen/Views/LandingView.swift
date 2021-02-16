//
//  LandingView.swift
//  Kolappen
//
//  Created by Miranda Mutka on 2021-02-16.
//

import SwiftUI
struct LandingView: View {
    
    var body: some View {
        
        NavigationView() {
        
            VStack {
                Spacer()
            Text("Kölappen")
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
            Spacer()
                NavigationLink(
                    destination: QrScanView()) {
                        Text("Skanna QR-kod")
                            .font(.system(size: 14))
                    }
                Spacer()
            }
        }
    }
       
}
