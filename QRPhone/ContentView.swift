//
//  ContentView.swift
//  QRPhone
//
//  Created by Christian Abraham Sanchez on 16/2/26.
//

import SwiftUI

struct ContentView: View{
    @State private var userData = UserData(phoneNumber: "", firstName:"", lastName: "", email: nil)
    @State private var showingForm = true
    @State private var showAlert = false
    
    var body: some View{
        NavigationView{
            VStack{
                if showingForm {
                    Form{
                        Section(header: Text("Datos Personales")){
                            TextField("Nombre", text: $userData.firstName).textContentType(.givenName)
                            TextField("Apellido", text: $userData.lastName).textContentType(.familyName)
                        }
                        Section(header: Text("Detalles del contacto")){
                            TextField("Número de teléfono", text: $userData.phoneNumber).keyboardType(.phonePad).textContentType(.telephoneNumber)
                            TextField("Email", text: Binding(get: {userData.email ?? ""}, set: {userData.email = $0.isEmpty ? nil : $0})).keyboardType(.emailAddress).textInputAutocapitalization(.never).textContentType(.emailAddress)
                        }
                        
                        Section{
                            Button(action: saveData){
                                Text("Guardar y generar QR").frame(maxWidth: .infinity).foregroundColor(.white)
                            }
                            .listRowBackground(Color.blue)
                            .disabled(userData.phoneNumber.isEmpty || userData.firstName.isEmpty || userData.lastName.isEmpty)
                        }
                    }
                }else{
                    VStack(spacing: 20){
                        Text(userData.fullName).font(.title)
                        Image(uiImage: generateQRCode(from: userData.phoneNumber)).interpolation(.none)
                            .resizable()
                            .frame(width: 200, height: 200)
                        
                        Text("Cualquiera que escanee este QR podrá ver tu número de teléfono").font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Editar infromación"){
                            showingForm = true
                        }
                        
                        Button("Eliminar datos", role: .destructive){
                            showAlert = true
                        }.alert("¿Estás seguro de que quieres eliminar tus datos?", isPresented: $showAlert){
                            Button("Cancelar", role: .cancel){}
                            Button("Eliminar", role: .destructive){
                                deleteData()
                            }
                        }message: {
                                Text("Esta acción no se puede deshacer.")
                            }
                        .padding(.top)
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("QR Phone")
            .onAppear(perform: loadData)
        }
    }
    
    func saveData(){
       if let encoded = try?
            JSONEncoder().encode(userData){
            UserDefaults.standard.set(encoded, forKey: "userData")
            showingForm = false
       }
    }
    
    
    func loadData(){
        if let saveData = UserDefaults.standard.data(forKey: "userData"),
           let decoded = try?
            JSONDecoder().decode(UserData.self, from: saveData){
            userData = decoded
            showingForm = false
        }
    }
    
    func deleteData(){
        UserDefaults.standard.removeObject(forKey: "userData")
        userData = UserData(phoneNumber: "", firstName: "", lastName: "", email: nil)
        showingForm = true
    }
    
    func generateQRCode(from string: String) -> UIImage {
        let data = string.data(using: String.Encoding.ascii)
        
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = filter.outputImage?.transformed(by: transform){
                if let cgimg = CIContext().createCGImage(output, from: output.extent){
                    return UIImage(cgImage: cgimg)
                }
            }
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

#Preview{
    ContentView()
}
