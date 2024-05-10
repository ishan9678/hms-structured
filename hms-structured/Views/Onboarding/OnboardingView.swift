//
//  OnboardingView.swift
//  hms-structured
//
//  Created by srijan mishra on 09/05/24.
//


import SwiftUI

struct OnBoardingScreen: View {
    @State private var currentPage = 0
    
    var body: some View {
        NavigationStack{
            VStack{
                if(currentPage<2){ // Display 'Skip' button until the second screen
                    Button(action: {
                        // Action to perform when the button is tapped
                    }) {
                        NavigationLink(destination: LoginView()) {
                            Text("Skip")
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding([.leading, .trailing])
                        }
                    }
                }
                
                TabView(selection: $currentPage) {
                    OnboardingStepView(imageName: "FindDoc", title: "Find The Doctor", description: "Quickly locate and connect with healthcare professionals in your area.", isLastScreen:false).tag(0)
                    
                    OnboardingStepView(imageName: "BookAppoint", title: "Book your Appointment", description: "Easily schedule appointments with healthcare professionals to address your concerns.", isLastScreen:false).tag(1)
                    
                    OnboardingStepView(imageName: "Result", title: "Get The Solution", description: "Discover solutions tailored to your needs and receive personalized recommendations from the specialised ones.", isLastScreen: true).tag(2)
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            }
            .navigationBarHidden(true)
            .padding()
        }
    }
}

struct OnboardingStepView: View {
    var imageName: String
    var title: String
    var description: String
    var isLastScreen: Bool
    
    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 360, height: 400)
                .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 2)
            
            Text(title)
                .font(.system(size: 28))
                .fontWeight(.bold)
                .foregroundColor(.bgColor1)
                .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 2)
//
            
            Text(description)
                .foregroundColor(.black)
                .font(.callout)
                .multilineTextAlignment(.center)
//                .padding(.top,3)
            
            if isLastScreen {
                            // Get Started button
                            NavigationLink(destination: LoginView()) {
                                Text("   ")
                                Spacer()
                                Text("Get Started")
                                    .foregroundColor(.white) // Change text color to blue
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.bgColor1)
                                    .cornerRadius(10) // Round button corners Add padding to button
                            }
                        }
        }
        .padding()
    }
}

#Preview {
    OnBoardingScreen()
}

