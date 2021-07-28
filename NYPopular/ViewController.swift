//
//  ViewController.swift
//  NYPopular
//
//  Created by Mohamed Anas on 7/28/21.
//

import UIKit
import SafariServices

// API Key
var apiKey = "7RiweG7vkiWsiqHw90eafBpobQGjTO8u"

class ViewController: UIViewController {

    @IBOutlet weak var nyListview: UITableView!
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var indicatorVu: UIActivityIndicatorView!

    var articles = [Article]()
    var period = 1
    
    // MARK: - View Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        nyListview.tableFooterView = UIView(frame: .zero)
        getArticles()
    }

    // MARK: - Loaders
    func showLoader() {
        loaderView.isHidden = false
        indicatorVu.startAnimating()
    }
    
    func hideLoader() {
        loaderView.isHidden = true
        indicatorVu.stopAnimating()
    }
    
    // MARK: - API Services
    func getArticles() {
        guard let url = URL(string: "http://api.nytimes.com/svc/mostpopular/v2/mostviewed/all-sections/\(period).json?api-key=\(apiKey)") else { return }

        // Show Loader View
        self.showLoader()

        let request = URLRequest(url: url)
        URLSession(configuration: .default).dataTask(with: request) { (data, response, error) in
            // Hiding Loader
            DispatchQueue.main.async { self.hideLoader() }
            
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let data = data {
                    /*if let string = String(data: data, encoding: .utf8) {
                        print(string)
                    }*/
                    
                    guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String,Any> else
                    { return }
                    
                    guard let status = jsonObject["status"] as? String, status.lowercased().contains("ok")  else { return }
                    
                    guard let results = jsonObject["results"] as? [Dictionary<String,Any>] else { return }
                    
                    guard let jsonData = try? JSONSerialization.data(withJSONObject: results, options: []) else { return }
                    
                    // Map from json data tp model
                    do {
                        let decoded = try JSONDecoder().decode([Article].self, from: jsonData)
                        self.articles = decoded
                        DispatchQueue.main.async { self.nyListview.reloadData() }
                    } catch let e{
                        debugPrint(e.localizedDescription)
                    }
                }
            }
        }.resume()
    }
    
    // MARK: - Actions
    @IBAction func filterTapped() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let action1 = UIAlertAction(title: "Recently Added", style: .default) { (action) in
            self.period = 1
            self.getArticles()
        }
        
        let action2 = UIAlertAction(title: "Last 7 days", style: .default) { (action) in
            self.period = 7
            self.getArticles()
        }
        
        let action3 = UIAlertAction(title: "Last 30 days", style: .default) { (action) in
            self.period = 30
            self.getArticles()
        }
        
        let cancelAction = UIAlertAction(title: "Dismiss", style: .destructive, handler: nil)
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ListCell
        
        let article = articles[indexPath.row]
        
        cell.titleLable.text = article.title
        cell.byLable.text = article.byLine
        cell.dateLable.text = article.date

        cell.circleView.layer.cornerRadius = cell.circleView.bounds.height/2
        cell.circleView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        cell.circleLable.text = String(article.title.prefix(1))
        cell.circleLable.textColor = .white
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let urlString = articles[indexPath.row].url
        
        guard let url = URL(string: urlString) else { return }
        
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        
        let safariVC = SFSafariViewController(url: url, configuration: config)
        safariVC.modalPresentationStyle = .fullScreen
        self.present(safariVC, animated: true, completion: nil)
    }
}

// MARK: - Cells
class ListCell: UITableViewCell {
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var circleLable: UILabel!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var byLable: UILabel!
    @IBOutlet weak var dateLable: UILabel!
}
