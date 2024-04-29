import SwiftUI

class Booking: ObservableObject {
    @Published var index: Int = 0
    @Published var date: Date = Date()
}

let booking: Booking = Booking()

struct DoctorHomeView: View {
    @State private var hello : String = "Mon"
    @State private var presentAppointments = false
    @State private var dayColor: Color = Color(red: 161/255, green: 168/255, blue: 176/255)
    @State private var dateColor: Color = Color(red: 16/255, green: 22/255, blue: 35/255)
    @State private var bgColor: Color = Color(red: 242/255, green: 242/255, blue: 242/255)
    @State private var symptomsColor: Color = Color(red: 157/255, green: 159/255, blue: 159/255)
    @State private var headingColor: Color = Color(red: 28/255, green: 28/255, blue: 28/255)
    @State private var isDropdownExpanded = false
    @State private var selectedDate = Date()
    
    func dateGetter(index: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: index, to: getFirstDayOfWeek(for: selectedDate))!
    }
    
    func getFirstDayOfWeek(for date: Date) -> Date {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        return startOfWeek
    }
    
    func getDay(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        return dateFormatter.string(from: date)
    }
    
    func getDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: date)
    }
    
    func getMonthAndYear(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: date)
    }
    
    @ObservedObject var indexDate = booking
    
    var body: some View {
        ZStack {
            VStack {
                // Dropdown list to select month and year
                HStack {
                    Text(getMonthAndYear(date: selectedDate))
                        .font(.headline)
                        .foregroundColor(.black)
                    Button(action: {
                        self.isDropdownExpanded.toggle()
                    }) {
                        Image(systemName: "chevron.down")
                            .foregroundColor(.black)
                    }
                    Spacer()
                }
                .padding([.horizontal,.top])
                
                .cornerRadius(10)
                
                // Your existing scroll view for the week
               
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(0..<7) { i in
                            let date = dateGetter(index: i)
                            let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                            
                            Button(action: {withAnimation {
                                indexDate.index = i
                                selectedDate = date
                                hello = getDay(date: date)
                            }
                            print(date)}) {
                                VStack {
                                    Text((getDay(date: date)))
                                        .font(Font.custom("SF Pro Display Regular", size: 16))
                                        .foregroundColor(isSelected ? .white : dayColor)
                                    
                                    Text((getDate(date: date)))
                                        .font(Font.custom("SF Pro Display ", size: 18))
                                        .foregroundColor(isSelected ? .white : dateColor)
                                }
                                .frame(alignment: .center)
                                .padding(.leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .frame(width: 64, height: 80)
                                        .foregroundColor(isSelected ? Color(red: 0.24, green: 0.24, blue: 0.26).opacity(0.36) : .white)
                                        .padding(.leading)
                                )
                                .padding()
                            }
                        }
                    }
                    .frame(height: 85)
                    .padding(.bottom)
                    .padding(.trailing, 16)
                    
                }
                
                AppointmentView(temp: hello)
                Spacer()
            }
            
            
            if isDropdownExpanded {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        self.isDropdownExpanded.toggle()
                    }
                
                // Modal containing DatePicker
                VStack {
                    Spacer()
                    DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding()
                }
            }
        }.background(
            LinearGradient(gradient: Gradient(colors: [Color(red: 0, green: 0.60, blue: 0.87), Color(red: 0.56, green: 0.87, blue: 0.97)]), startPoint: .top, endPoint: .bottom)
          )
        .onAppear(){
            self.hello = getDay(date: Date())
        }
    }
}

struct DateCalendarView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorHomeView()
    }
}

struct AppointmentView : View {
    var temp : String
    var body : some View{
        
        VStack{
            ForEach(0..<3){i in
                if(i == 1){
                    HStack{
                        ZStack() {
                          Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 86.78, height: 96)
                            .background(.white)
                            .cornerRadius(20)
                            Text("\(temp)")
                            .font(Font.custom("SF Pro Display", size: 18).weight(.medium))
                            .foregroundColor(.black)
                        }
                        .frame(width: 86.78, height: 96)
                        ZStack() {
                          Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 249.62, height: 96)
                            .background(.white)
                            .cornerRadius(20)
                            VStack(alignment: .leading){
                                Text("11:00-12:00 PM")
                                  .font(Font.custom("SF Pro Display", size: 16).weight(.semibold))
                                  .foregroundColor(.black)
                                  .padding(.bottom)
                                Text("3 Patients")
                                  .font(Font.custom("SF Pro Display", size: 12))
                                  .foregroundColor(.black)
                            }
                            .offset(x:-30)
                        }
                        .frame(width: 249.62, height: 96)
                    }
                    
                }
                else{
                    HStack{
                        ZStack() {
                          Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 86.78, height: 96)
                            .background(Color(red: 0.24, green: 0.24, blue: 0.26).opacity(0.36))
                            .cornerRadius(20)
                          Text("\(temp)")
                            .font(Font.custom("SF Pro Display", size: 18).weight(.medium))
                            .foregroundColor(.white)
                            
                        }
                        .frame(width: 86.78, height: 96)
                        ZStack() {
                          Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 249.62, height: 96)
                            .background(Color(red: 0.24, green: 0.24, blue: 0.26).opacity(0.36))
                            .cornerRadius(20)
                            .offset(x: 0, y: 0)
                            VStack(alignment: .leading){
                                Text("11:00-12:00 PM")
                                  .font(Font.custom("SF Pro Display", size: 16).weight(.semibold))
                                  .foregroundColor(.white)
                                  .padding(.bottom)
                                Text("3 Patients")
                                  .font(Font.custom("SF Pro Display", size: 12))
                                  .foregroundColor(.white)
                                 
                            }
                            .offset(x:-30)
                        }
                        .frame(width: 249.62, height: 96)
                    }
                    
                }
            }
            
        }
    }
}

