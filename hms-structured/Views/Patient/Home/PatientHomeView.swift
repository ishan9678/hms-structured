import SwiftUI

struct PatientHomeView: View {
    
    @AppStorage("user_name") var userName: String = ""
    @State var greeting: String = ""
    
    var body: some View {
        NavigationStack {
                VStack {
                    ZStack {
                        Rectangle()
                            .foregroundStyle(Color("bg-color1"))
                            .frame(height: UIScreen.main.bounds.size.height * 0.18)
                        
                        
                        VStack {
                            Text("Good Afternoon, \(userName)")
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
                    
                    ScrollView{
                        
                        PatientAppointmentsView()
                        
                        PatientMedicalTestsView()
                        
                        DoctorCardList()
                        
                        //                    Spacer()
                    }
                    
                }
                .ignoresSafeArea(.all)
            }
            .navigationBarBackButtonHidden()
        }
    
    func timeOfDay(){
        let hour = Calendar.current.component(.hour, from: Date())
        
                                    switch hour {
                                    case 6..<12:
                                        greeting = "Good Morning"
                                    case 12..<17:
                                        greeting = "Good Afternoon"
                                    case 17..<20:
                                        greeting = "Good Evening"
                                    default:
                                        greeting = "Hello"
            }
        }
    }


struct PatientHomeView_Previews: PreviewProvider {
    static var previews: some View {
        PatientHomeView()
    }
}


