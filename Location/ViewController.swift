import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()
    let text = [ "緯度", "経度", "国名", "郵便番号", "都道府県", "郡", "市区町村", "丁番なしの地名", "地名", "番地" ]
    var item: [ UILabel ] = []
    var location: [ UILabel ] = []
    var address: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //サイズ
        let width = self.view.frame.width / 2
        let height = self.view.frame.height / CGFloat( self.text.count + 2 )
        
        //ラベル
        for ( i, text ) in self.text.enumerated() {
            //項目
            self.item.append( UILabel() )
            self.item.last!.frame.size = CGSize( width: width, height: height )
            self.item.last!.frame.origin = CGPoint( x: 0, y: height * CGFloat( i + 1 ) )
            self.item.last!.textAlignment = .center
            self.item.last!.text = text
            self.view.addSubview( self.item.last! )
            
            //データ
            self.location.append( UILabel() )
            self.location.last!.frame.size = CGSize( width: width, height: height )
            self.location.last!.frame.origin = CGPoint( x: width, y: height * CGFloat( i + 1 ) )
            self.location.last!.textAlignment = .center
            self.view.addSubview( self.location.last! )
        }
        
        //住所
        self.address = UILabel()
        self.address.frame.size = CGSize( width: self.view.frame.width, height: height )
        self.address.frame.origin = CGPoint( x: 0, y: height * CGFloat( self.text.count + 1 ) )
        self.address.textAlignment = .center
        self.view.addSubview( self.address )
        
        //ロケーションマネージャ
        self.locationManager.requestWhenInUseAuthorization()
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            self.locationManager.delegate = self
            self.locationManager.distanceFilter = 10
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager( _ manager: CLLocationManager, didUpdateLocations locations: [ CLLocation ] ) {
        //表示更新
        if let location = locations.first {
            
            //緯度・経度
            self.location[0].text = location.coordinate.latitude.description
            self.location[1].text = location.coordinate.longitude.description
            
            
            //逆ジオコーディング
            self.geocoder.reverseGeocodeLocation( location, completionHandler: { ( placemarks, error ) in
                if let placemark = placemarks?.first {
                    //位置情報
                    self.location[2].text = placemark.country
                    self.location[3].text = placemark.postalCode
                    self.location[4].text = placemark.administrativeArea
                    self.location[5].text = placemark.subAdministrativeArea
                    self.location[6].text = placemark.locality
                    self.location[7].text = placemark.subLocality
                    self.location[8].text = placemark.thoroughfare
                    self.location[9].text = placemark.subThoroughfare
                    
                    //住所
                    let administrativeArea = placemark.administrativeArea == nil ? "" : placemark.administrativeArea!
                    let locality = placemark.locality == nil ? "" : placemark.locality!
                    let subLocality = placemark.subLocality == nil ? "" : placemark.subLocality!
                    let thoroughfare = placemark.thoroughfare == nil ? "" : placemark.thoroughfare!
                    let subThoroughfare = placemark.subThoroughfare == nil ? "" : placemark.subThoroughfare!
                    let placeName = !thoroughfare.contains( subLocality ) ? subLocality : thoroughfare
                    self.address.text = administrativeArea + locality + placeName + subThoroughfare
                }
            } )
        }
    }
}

