//
//  LoginView.swift
//  hms-structured
//
//  Created by Ishan on 25/04/24.
//

import SwiftUI
import Combine
import FirebaseAnalyticsSwift

private enum FocusableField: Hashable {
  case email
  case password
}

struct LoginView: View {
    @AppStorage("user_name") var userName: String = ""
    @AppStorage("user_UID") var userUID: String = ""
    @ObservedObject var viewModel =  AuthenticationViewModel()
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var focus: FocusableField?
    
    @State private var isNavigateToSignUp = false
    
    @State private var isLoggedIn = false
    
    private func signInWithEmailPassword() {
        Task {
            if await viewModel.signInWithEmailPassword() == true {
                dismiss()
                isLoggedIn = true
//                if viewModel.role == .doctor{
//                    userName = viewModel.doctor.fullName
//                    if let userid = viewModel.doctor.id{
//                        userUID = userid
//                    }
//                }
                if viewModel.role == .patient{
                    userName = viewModel.patient.name
                    if let userid = viewModel.patient.id{
                        userUID = userid
                    }
                }
                
            }
        }
    }
    
    var body: some View {
        NavigationStack{
            VStack {
                Image("Login")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minHeight: 300, maxHeight: 400)
                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Image(systemName: "at")
                    TextField("Email", text: $viewModel.email)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .focused($focus, equals: .email)
                        .onSubmit {
                            self.focus = .password
                        }
                        .submitLabel(.next)
                    
                }
                .padding(.vertical, 6)
                .background(Divider(), alignment: .bottom)
                .padding(.bottom, 4)
                
                HStack {
                    Image(systemName: "lock")
                    SecureField("Password", text: $viewModel.password)
                        .focused($focus, equals: .password)
                        .submitLabel(.go)
                        .onSubmit {
                            self.focus = .email
                        }
                }
                .padding(.vertical, 6)
                .background(Divider(), alignment: .bottom)
                .padding(.bottom, 8)
                
                if !viewModel.errorMessage.isEmpty {
                    VStack {
                        Text(viewModel.errorMessage)
                            .foregroundColor(Color(UIColor.systemRed))
                    }
                }
                
                Button(action: signInWithEmailPassword) {
                    if viewModel.authenticationState != .authenticating {
                        Text("Login")
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                    }
                    else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                    }
                }
                .disabled(!viewModel.isValidLogin)
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                
                HStack {
                    Text("Don't have an account yet?")
                    Button(action: {
                        isNavigateToSignUp = true
                    }) {
                        Text("Sign up")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
                .padding([.top, .bottom], 50)
                
                // to navigate
                NavigationLink(
                    destination: SignupView(),
                    isActive: $isNavigateToSignUp,
                    label: {
                        EmptyView()
                    })
                    .hidden()
                
                NavigationLink(
                    destination: viewModel.role == .patient ? AnyView(PatientContentView().navigationBarBackButtonHidden()) : viewModel.role == .doctor  ? AnyView(DoctorHomeView().navigationBarBackButtonHidden()) : viewModel.role == .admin ? AnyView(AdminTabBarView().navigationBarBackButtonHidden()) : AnyView(SignupView()),
                    isActive: $isLoggedIn,
                    label: {
                        EmptyView()
                    })
                    .hidden()
                
            }
            .listStyle(.plain)
            .padding()
            .analyticsScreen(name: "\(Self.self)")
        }
    }
}
struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
        LoginView()
      LoginView()
        .preferredColorScheme(.dark)
    }
    .environmentObject(AuthenticationViewModel())
  }
}
