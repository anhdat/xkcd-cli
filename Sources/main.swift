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


var done = false

let url = "http://xkcd.com/info.0.json"
fetchJSONData(NSURL(string: url)!) {comicDict in
    print(comicDict)
    let img_link = comicDict["img"] as! String
    print(img_link)
    fetchData(NSURL(string: img_link)!) {data in
        defer {
            done = true
        }
        do {
            try printImage(data: data)
        } catch {
            print(error)
        }
    }
}

while !done {
    continue
}
