import Foundation
import ImagePrinting
import Docoptswift


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


func loadLatestStrip(shouldPrintAltText shouldPrintAltText: Bool = false) {
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

            if shouldPrintAltText {
                let imgAltText = comicDict["alt"] as! String
                print(imgAltText)
            }
        }
    }

    while !done {
        continue
    }
}


let doc : String = "xkcd-cli - xkcd on iTerm\n" +
"\n" +
"Usage:\n" +
"  xkcd [(-a | --altText)]\n" +
"  xkcd (-h | --help)\n" +
"\n" +
"Options:\n" +
"  -h, --help\n"
"  -a, --altText [default: false]\n"


func getTerminalInput() -> [String: AnyObject] {
    let args = Array(Process.arguments.dropFirst())
    // print(args)
    return Docopt.parse(doc, argv: args)
}


func main() {
    let terminalInput = getTerminalInput()

    // Use force unwrap because Optional form Dictionary subscripting will be cast to false
    let inputAltTextOption: Bool = terminalInput["--altText"] as! Bool
    let inputAltTextShortOption: Bool = terminalInput["-a"] as! Bool
    let shouldPrintAltText = inputAltTextOption || inputAltTextShortOption

    loadLatestStrip(shouldPrintAltText: shouldPrintAltText)
}

main()