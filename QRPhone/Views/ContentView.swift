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
        VStack{
            if viewModel.isDataSaved{
                QRDisplayView(viewModel: viewModel)
            }else{
                UserFormView(viewModel: viewModel)
            }
        }
    }
}

#Preview{
    ContentView()
}
