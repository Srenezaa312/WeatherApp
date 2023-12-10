
import UIKit
import CoreLocation
import SDWebImage

class AddLocationController: UIViewController, UITextFieldDelegate {
    
    static var items = [LocModel]()
    
    @IBOutlet weak var locationname: UILabel!
     
    @IBOutlet weak var condition: UILabel!
    
    var item : LocModel = LocModel()
    
    private let locationManager = CLLocationManager()
    
    @IBOutlet weak var tf_serch: UITextField!
    
    
    @IBOutlet weak var image_weather: UIImageView!
    
    
    @IBOutlet weak var tempLB: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        displaySampleImage()
        tf_serch.delegate = self
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    private func displaySampleImage(){
        let config=UIImage.SymbolConfiguration(paletteColors: [
            .systemPink,.systemBrown,.systemOrange
        ])
        image_weather.preferredSymbolConfiguration=config
        image_weather.image=UIImage(systemName: "sun.min")?.withTintColor(.blue, renderingMode: .alwaysOriginal)

    }

    @IBAction func onLocationTapped(_ sender: UIButton) {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
    }
    
    public func displayLocation(locationText : String){
        locationname.text=locationText
    }
    
    @IBAction func onSearchTapped(_ sender: UIButton) {
        loadWeather(search: tf_serch.text)
        
    }
    
    private func loadWeather(search: String?){
        guard let search = search else{
            return
        }
        guard let url=getURL(query: search) else{
            return
        }
         
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url) { data, response, error in
            
            // network call finished
            print("Network call complete")
            
            guard error == nil else {
                 print("ERROR RECEIVED")
                return
            }
            guard let data = data else
            {
                print("no data found ")
                return
            }
            
            if let weatherResponse = self.parseJSON(data: data){
                let weath = weatherResponse.current.condition.code
                
                self.item.name = weatherResponse.location.name
                self.item.temp = weatherResponse.current.temp_c
                self.item.icon = "https:"+weatherResponse.current.condition.icon
                self.item.lat = weatherResponse.location.lat
                self.item.lon = weatherResponse.location.lon
                
                
                DispatchQueue.main.async { [self] in
                    self.locationname.text = weatherResponse.location.name
                    self.tempLB.text = "\(weatherResponse.current.temp_c) C"
                    self.condition.text = weatherResponse.current.condition.text
                    self.image_weather?.sd_setImage(with: URL(string: self.item.icon), placeholderImage: UIImage(named: "placeholder.png"))
                
                }
                
                AddLocationController.items.append(self.item)

            }
        }
        dataTask.resume()
        
        
    }
    private func getURL(query : String)-> URL? {
        self.item = LocModel()
        let baseURL = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "current.json"
        let apiKey = "283b9e47bbe84088939190412231603"
       guard  let url = "\(baseURL)\(currentEndpoint)?key=\(apiKey)&q=\(query)"
        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
           return nil
       }
        
        print(url)
        
           
        return URL(string: url)
        
        
    }
    private func parseJSON(data:Data) -> WeatherResponse? {
        
        let decoder = JSONDecoder()
        var weather: WeatherResponse?
        
        do{
            weather = try decoder.decode(WeatherResponse.self, from: data)
            
        } catch {
            print("ERROR IN DECODING ")
        }
        return weather
    }
   
}

struct WeatherResponse: Decodable{
    let location : Location
    let current : Weather
}

struct Location: Decodable{
    let name: String
    let lat: Double
    let lon: Double
}
struct Weather: Decodable{
    let temp_c :Float
    let condition: WeatherCondition
    
}
struct WeatherCondition: Decodable{
    let text:String
    var icon:String
    var code:Int
}
extension AddLocationController : CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("GOT IT")
        
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            print("Latlng: (\(latitude),\(longitude))")
            displayLocation(locationText: "Latlng: (\(latitude),\(longitude))")
            self.loadWeather(search: "\(latitude),\(longitude)")
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
     print (error)
    }
    
}
