//
//  SwiftUIView.swift
//  TestApp
//
//  Created by Sampel on 06/10/2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct ContentView: View {
 
    
    var body: some View {
        Home()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct Home : View {
    @State var expand = false
    @State var search = ""
    @ObservedObject var RandomImages = getData()
    @State var page = 1
    @State var isSearching  = false
    
    private var data : [Int] = Array(1...20)
        private let colors : [Color] = [.red,.green,.blue,.purple]
        
        private let adaptiveColumns = [
            GridItem(.adaptive(minimum: 170))
        ]
        
        private let numberColumns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
        ]
    var body: some View {
            
        VStack(spacing: 0){
            HStack{
                if !self.expand {
                    VStack(alignment: .leading, spacing: 8){
                        Text("Unsplash")
                            .font(.title)
                            .fontWeight(.bold)
                         
                        Text("Beautiful , Free Photos")
                            .font(.caption)

                    }
                    .foregroundColor(.black)
                }
                    Spacer(minLength: 0)
                
                    
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .onTapGesture {
                            withAnimation {
                                self.expand = true
                            }
                        }
                
                if self.expand{
                    TextField("Search .......",text: self.$search)
                    
                    
                    if self.search != "" {
                        Button(action: {
                            
                            self.RandomImages.Images.removeAll()
                            
                            self.isSearching = true
                            
                            self.page = 1
                            self.SearchData()
                        }) {
                            Text("Find")
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                        }
                    }
                    
                    Button(action: {
                        
                        withAnimation {
                            self.expand = false
                        }
                        
                        self.search = ""
                        
                        if self.isSearching {
                            self.isSearching   = false
                            self.RandomImages.Images.removeAll()
                            self.RandomImages.updatedData()
                        }
                        
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.black)
                        
                    }
                    .padding(.leading, 10)
                    
                    
                }
                    
                
            }
            .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top)
            .padding()
            .background(Color.white)
            
            if self.RandomImages.Images.isEmpty {
                
                
                Spacer()
                if self.RandomImages.noresults {
                    Text("No Result found ")
                }
                
                else {
                    indicator()
                }
                
               
                
                Spacer()
                
            }else {
                
                
                ScrollView(.vertical, showsIndicators: false) {
                    
                    VStack(spacing : 15)  {
                        ForEach(self.RandomImages.Images, id: \.self) { i in
                            
                            HStack(spacing: 20) {
                                ForEach(i){ j in
                                     
                                    AnimatedImage(url: URL(string: j.urls [ "thumb"]!))
                                        .resizable()
                                        .frame(width: (UIScreen.main.bounds.width - 50 ) / 2, height: 200)
                                        .cornerRadius(15)
                                        .contextMenu {
                                            
                                            Button(action: {
                                                
                                                SDWebImageDownloader()
                                                    .downloadImage(with: URL(string: j.urls ["small"]!)) {
                                                        (image, _, _, _ ) in
                                                        
                                                        
                                                        
                                                        UIImageWriteToSavedPhotosAlbum( image!, nil, nil, nil)
                                                    }
                                                
                                            }){
                                                HStack {
                                                    Text("Save")
                                                        
                                                Spacer()
                                                    
                                                    Image(systemName: "square.and.arrow.down.fill")
                                                }
                                                .foregroundColor(.black)
                                            }
                                        }
                                    
                                }
                            }
                        }
                            
                            if !self.RandomImages.Images.isEmpty{
                                
                                if self.isSearching && self.search != ""{
                                    HStack{
                                        Text("Page \(self.page)")
                                        Spacer()
                                        
                                        Button(action: {
                                            self.RandomImages.Images.removeAll()
                                            self.page += 1
                                            self.SearchData()
                                            
                                        }) {
                                            
                                            Text("Next")
                                                .fontWeight(.bold)
                                                .foregroundColor(.black)
                                        }
                                        
                                    }
                                    .padding(.horizontal, 25)
                                }
                                
                                else {
                                    HStack{
                                        Spacer()
                                        
                                        Button(action: {
                                            self.RandomImages.Images.removeAll()
                                            self.RandomImages.updatedData()
                                            
                                        }) {
                                            
                                            Text("Next")
                                                .fontWeight(.bold)
                                                .foregroundColor(.black)
                                        }
                                        
                                    }
                                    .padding(.horizontal, 25)
                                }
                            }
                           
                        }
                        .padding(.top)
                    }
                    
                }
            
        }
        .background(Color.black.opacity(0.07).edgesIgnoringSafeArea(.all))
        .edgesIgnoringSafeArea(.top)
    }

    func SearchData() {
        let key = "kf3qurlWa31AnNL3rE_elcQm95HFCq4-urhfuVN8bQY"
        let query = self.search.replacingOccurrences(of: " ", with: "%20")
        
        let url = "https://api.unsplash.com/search/photos/?page=\(self.page)&query=\(query)&client_id=\(key)"
        
        
        self.RandomImages.SearchData(url: url)
    }
    
}

class getData : ObservableObject {
    @Published var Images : [[Photo]] = []
    @Published var noresults = false
    
    
    init(){
         
        updatedData()
    }
    
    
    func updatedData(){
        
        self.noresults = false
        
        let key = "kf3qurlWa31AnNL3rE_elcQm95HFCq4-urhfuVN8bQY"
        let url = "https://api.unsplash.com/photos/random/?count=30&client_id=\(key)"
        
        let session =  URLSession(configuration: .default)
        session.dataTask(with: URL(string: url)!) { (data, _, err) in
            
            if err != nil{
                print((err?.localizedDescription)!)
                return
                
            }
            do {
                let json = try JSONDecoder().decode([Photo].self, from: data!)
                
                for i in stride(from: 0, to: json.count, by: 2) {
                    var ArrayData :[Photo] = []
                    for j in i..<i+2 {
                        if j < json.count {
                            
                            ArrayData.append(json[j])
                        }
                    }
                    DispatchQueue.main.sync {
                        self.Images.append(ArrayData)
                    }
                    
                }
                
            }catch {
                print(error.localizedDescription)
            }
            
        }
        .resume()
        
    }
    
    func SearchData(url: String){

        
        let session =  URLSession(configuration: .default)
        session.dataTask(with: URL(string: url)!) { (data, _, err) in
            
            if err != nil{
                print((err?.localizedDescription)!)
                return
                
            }
            do {
                let json = try JSONDecoder().decode(SearchPhoto.self, from: data!)
                if json.results.isEmpty {
                    self.noresults = true
                }else{
                    self.noresults = false
                }
                
                for i in stride(from: 0, to: json.results.count, by: 2) {
                    var ArrayData :[Photo] = []
                    for j in i..<i+2 {
                        if j < json.results.count {
                            
                            ArrayData.append(json.results[j])
                        }
                    }
                    DispatchQueue.main.sync {
                        self.Images.append(ArrayData)
                    }
                    
                }
                
            }catch {
                print(error.localizedDescription)
            }
            
        }
        .resume()
        
    }
    
}
struct Photo : Identifiable, Decodable, Hashable {
    var id : String
    var urls : [String : String]
}


struct indicator : UIViewRepresentable {
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .large)
        view.startAnimating()
        
        return view
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView , context: Context) {
        
    }
}

struct SearchPhoto :  Decodable {
    var results: [Photo]
}


