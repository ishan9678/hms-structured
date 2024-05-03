import SwiftUI

struct HealthCardView: View {
    var image: Image
    var title: String
    var subTitle: String
    
    var body: some View {
        ZStack{
            Color(uiColor: .systemGray6)
                .cornerRadius(15)
            VStack{
                HStack(alignment: .top){
                    VStack(alignment: .leading, spacing: 5){
                        Text(title)
                            .font(.system(size: 16))
                        Text(subTitle)
                            .font(.system(size: 16))
                            .bold()
                    }
                    Spacer()
                    
                    image
                        .foregroundColor(.blue)
                }
                .padding()
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
        .cornerRadius(15)
    }
}

struct HealthCardView_Previews: PreviewProvider {
    static var previews: some View {
        HealthCardView(image: Image(systemName: "figure.walk"),
                   title: "Daily steps",
                   subTitle: "23")
    }
}


