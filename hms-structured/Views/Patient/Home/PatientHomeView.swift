import SwiftUI

struct PatientHomeView: View {

    var body: some View {
        NavigationView {
            VStack {
                    ZStack {
                        Rectangle()
                            .foregroundStyle(Color("bg-color1"))
                            .frame(height: UIScreen.main.bounds.size.height * 0.20)
                        

                        VStack {
                            Text("Good Morning, Nancy")
                                .foregroundStyle(Color.white)
                                .font(.system(size: 20))
                                .opacity(0.8)
                                .padding(.trailing, 25)

                            Text("Welcome Back")
                                .foregroundStyle(Color.white)
                                .font(.system(size: 32))
                                .bold()
                        }
                        .padding(.trailing, UIScreen.main.bounds.size.height * 0.15)
                        .padding(.top, UIScreen.main.bounds.size.height * 0.05)
                    }
            

                    PatientAppointmentsView(appointments: appointments)
                        .padding(.bottom,10)

                    DoctorCardList()

                Spacer()
                
                    Button(action: {
                        if let url = URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundColor(Color("bg-color1"))
                                .frame(height: 60)
                            
                            Text("Prevent the spread of Covid-19 Virus")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        .padding()
                    }
                Spacer()
                
                }
                .ignoresSafeArea(.all)
            }
        .navigationBarBackButtonHidden()
    }
}

struct PatientHomeView_Previews: PreviewProvider {
    static var previews: some View {
        PatientHomeView()
    }
}


