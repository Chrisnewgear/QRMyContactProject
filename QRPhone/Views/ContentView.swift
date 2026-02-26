//
//  ContentView.swift
//  QRPhone
//
//  Created by Christian Abraham Sanchez on 16/2/26.
//

import SwiftUI

struct ContentView: View{
    @StateObject private var viewModel = UserDataViewModel()
    
    var body: some View{
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.qrGradientStart, .qrGradientEnd]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            if viewModel.isDataSaved{
                QRDisplayView(viewModel: viewModel)
                    .transition(.opacity.combined(with: .scale))
            }else{
                UserFormView(viewModel: viewModel)
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(.spring(), value: viewModel.isDataSaved)
    }
}

#Preview{
    ContentView()
}
