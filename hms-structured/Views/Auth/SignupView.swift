//
//  SignupView.swift
//  HMS-Team 5
//
//  Created by user1 on 22/04/24.
//

import SwiftUI
import Combine

struct SignupView: View {
    @ObservedObject var viewModel =  AuthenticationViewModel()
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var focus: FocusableField?
    
    @State private var isNavigateToLogin = false
    
    @State private var loggedIn = false

    private enum FocusableField: Hashable {
        case name
        case email
        case password
        case confirmPassword
        case age
        case bloodGroup
        case gender
    }
    
    private func signUpWithEmailPassword() {
        Task {
            let signUpSuccess = await viewModel.signUpWithEmailPassword()
            if signUpSuccess {
               
                loggedIn = true
            }
        }
    }
    
    var body: some View {
        NavigationStack{
            
            VStack {
                Image("SignUp")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minHeight: 300, maxHeight: 400)
                Text("Sign up")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Text("Already have an account?")
                    Button(action: {
                        isNavigateToLogin = true
                    }) {
                        Text("Log in")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
                .padding([.top, .bottom], 50)
                TextField("Name", text: $viewModel.name)
                    .disableAutocorrection(true)
                    .focused($focus, equals: .name)
                    .submitLabel(.next)
                    .onSubmit {
                        self.focus = .password
                    }
                    .padding(.vertical, 6)
                    .background(Divider(), alignment: .bottom)
                    .padding(.bottom, 4)
                
                TextField("Email", text: $viewModel.email)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .focused($focus, equals: .email)
                    .submitLabel(.next)
                    .onSubmit {
                        self.focus = .password
                    }
                    .padding(.vertical, 6)
                    .background(Divider(), alignment: .bottom)
                    .padding(.bottom, 4)
                
                SecureField("Password", text: $viewModel.password)
                    .focused($focus, equals: .password)
                    .submitLabel(.next)
                    .onSubmit {
                        self.focus = .confirmPassword
                    }
                    .padding(.vertical, 6)
                    .background(Divider(), alignment: .bottom)
                    .padding(.bottom, 8)
                
                SecureField("Confirm password", text: $viewModel.confirmPassword)
                    .focused($focus, equals: .confirmPassword)
                    .submitLabel(.next)
                    .onSubmit {
                        self.focus = .age
                    }
                    .padding(.vertical, 6)
                    .background(Divider(), alignment: .bottom)
                    .padding(.bottom, 8)
                
                TextField("Age", value: $viewModel.age, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .padding(.vertical, 6)
                    .background(Divider(), alignment: .bottom)
                    .padding(.bottom, 8)
                
                TextField("Blood Group", text: $viewModel.bloodGroup)
                    .padding(.vertical, 6)
                    .background(Divider(), alignment: .bottom)
                    .padding(.bottom, 8)
                
                TextField("Gender", text: $viewModel.gender)
                    .padding(.vertical, 6)
                    .background(Divider(), alignment: .bottom)
                    .padding(.bottom, 8)
                
                if !viewModel.errorMessage.isEmpty {
                    VStack {
                        Text(viewModel.errorMessage)
                            .foregroundColor(Color(UIColor.systemRed))
                    }
                }
                
                Button(action: signUpWithEmailPassword) {
                    if viewModel.authenticationState != .authenticating {
                        Text("Sign up")
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(!viewModel.isValid)
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                
               
                
                //navigation
                
                NavigationLink(
                    destination: LoginView(),
                    isActive: $isNavigateToLogin,
                    label: {
                        EmptyView()
                    })
                    .hidden()
                
                NavigationLink(
                    destination: PatientHomeView(),
                    isActive: $loggedIn,
                    label: {
                        EmptyView()
                    })
                    .hidden()

            }
            .listStyle(.plain)
            .padding()
        }
        .navigationBarBackButtonHidden()
        
    }
        
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SignupView()
            SignupView()
                .preferredColorScheme(.dark)
        }
    }
}

