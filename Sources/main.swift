import Foundation
import ImagePrinting


func fetchData(url: NSURL, completion: (data: NSData) -> ()) {
    NSURLSession
        .sharedSession()
        .dataTaskWithURL(url) { (data, response, error) -> Void in
        guard let data = data else { return }
        completion(data: data)
    }.resume()
}


func fetchJSONData(url: NSURL, completion: (jsonDict: NSDictionary) -> ()) {
    fetchData(url) {data in
        if let json = try? NSJSONSerialization
            .JSONObjectWithData(data, options: .AllowFragments)
            as? NSDictionary,
            let jsonUnWrapped = json {
            completion(jsonDict: jsonUnWrapped)
        }
    }
}


func loadLatestStrip() {
    var done = false

    let latestStripLink = "http://xkcd.com/info.0.json"
    fetchJSONData(NSURL(string: latestStripLink)!) {comicDict in
        let imgLink = comicDict["img"] as! String
        fetchData(NSURL(string: imgLink)!) {data in
            defer {
                done = true
            }
            do {
                try printImage(data: data)
            } catch {
                print(error)
            }
            let imgAltText = comicDict["alt"] as! String
            print(imgAltText)
        }
    }

    while !done {
        continue
    }
}

loadLatestStrip()
