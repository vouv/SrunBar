
import Cocoa

class Request : NSObject, URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession,
                             task: URLSessionTask,
    willPerformHTTPRedirection response: HTTPURLResponse,
                  newRequest request: URLRequest,
                  completionHandler: @escaping (URLRequest?) -> Void) {
        debugPrint(response)
    }
}
