//
//  ProductVC.swift
//  Silpo
//
//  Created by Prefect on 23.10.2021.
//

import Foundation
import UIKit

class ProductVC: UIViewController {
    
    //MARK: - View
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productVolumeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var componentStackAlertImageView: UIImageView!
    @IBOutlet weak var componentStock: UILabel!
    
    @IBOutlet weak var pieChartView: UIView!
    
    
    @IBOutlet weak var helsyPercentLabel: UILabel!
    @IBOutlet weak var helsiTitle: UILabel!
    @IBOutlet weak var helsiItemsLabel: UILabel!
    
    @IBOutlet weak var junkPersenLabel: UILabel!
    @IBOutlet weak var junTitle: UILabel!
    @IBOutlet weak var junkItemsLAbel: UILabel!
    
    @IBOutlet weak var proteins: UILabel!
    @IBOutlet weak var fats: UILabel!
    @IBOutlet weak var carbohydrates: UILabel!

    @IBOutlet weak var package: UILabel!
    @IBOutlet weak var utilize: UILabel!
    
    @IBOutlet weak var cartButton: UIButton!
    
    private var productSizeTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    private let pieChart = PieChartView(
            frame: CGRect(x: 0, y:0, width: 150, height: 150),
            colors: [UIColor(named: "green")!, UIColor(named: "grey")!],
            strokeWidth: 0,
            borderColor: .black)

    
    //MARK: - Variables
    var product: Product!
    
    func configure(with product: Product) {
        let url = URL(string: product.image_url)!
        productImageView.image = UIImage(data: try! Data(contentsOf: url))!
        productTitleLabel.text = product.name
        productVolumeLabel.text = product.mass + " г"
        priceLabel.text = String(Int(Float(product.price) ?? 19.0) ?? 19)
        
        // componentStock
        let string1 = "Цей продукт містить "
        let attributes1: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont.boldSystemFont(ofSize: 22)
        ]
        
        let attributedString1 = NSAttributedString(string: string1, attributes: attributes1)
        let string2 = parsing(product.components)
        let attributes2: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: "red")!,
            .font: UIFont.boldSystemFont(ofSize: 22)
        ]
        let attributedString2 = NSMutableAttributedString(string: string2, attributes: attributes2)
        let resultMutableAtributedString = NSMutableAttributedString()
        resultMutableAtributedString.append(attributedString1)
        resultMutableAtributedString.append(attributedString2)
        
        componentStock.attributedText = resultMutableAtributedString
        
        // PieChart
        setupPieChartData(Float(product.healthy_components_percentage) ?? 100.0)
        
        // Helsi description
        let booferHelsyInt = Int(Float(product.healthy_components_percentage) ?? 100.0) ?? 100
        helsyPercentLabel.text = String(booferHelsyInt) + "%"
        helsiItemsLabel.text = parseComponentsForHelsyTitle(product.components)
        
        if product.healthy_components_percentage == "0" {
            helsyPercentLabel.isHidden = true
            helsiTitle.isHidden = true
            helsiItemsLabel.isHidden = true
        }
        
        // Junk Description
        junkPersenLabel.text = String(100 - booferHelsyInt) + "%"
        junkItemsLAbel.text = parseComponentsForJunkyTitle(product.components)
        
        if product.healthy_components_percentage == "100" {
            junkPersenLabel.isHidden = true
            junTitle.isHidden = true
            junkItemsLAbel.isHidden = true
        }
        
        // Склад
        proteins.text = product.proteins
        fats.text = product.fats
        carbohydrates.text = product.carbohydrates
        
        // Utility
        package.text = product.package
        utilize.text = product.utilize
        
    }
    func parseComponentsForJunkyTitle(_ components: [ProductComponent]?) -> String {
        guard let components = components else {
            junkPersenLabel.isHidden = true
            junTitle.isHidden = true
            junkItemsLAbel.isHidden = true
            return ""
        }
        
        var resultString = ""
        var isOneJunky = false
        
        for component in components {
            if !component.is_healthy {
                isOneJunky = true
                resultString += component.name + ", "
            }
        }
        
        var resultResultString = ""
        
        for (index, char) in resultString.enumerated() {
            if index == resultString.count - 1 ||
                index == resultString.count - 2 {
                continue
            } else {
                resultResultString += String(char)
            }
        }
        
        if isOneJunky {
            return resultResultString
        } else {
            junkPersenLabel.isHidden = true
            junTitle.isHidden = true
            junkItemsLAbel.isHidden = true
            return ""
        }
    }
    
    func parseComponentsForHelsyTitle(_ components: [ProductComponent]?) -> String {
        guard let components = components else {
            helsyPercentLabel.isHidden = true
            helsiTitle.isHidden = true
            helsiItemsLabel.isHidden = true
            return ""
        }
        
        var resultString = ""
        var isOneElementHealsy = false
        
        for component in components {
            if component.is_healthy {
                isOneElementHealsy = true
                resultString += component.name + ", "
            }
        }
        
        var resultResultString = ""
        
        for (index, char) in resultString.enumerated() {
            if index == resultString.count - 1 ||
                index == resultString.count - 2 {
                continue
            } else {
                resultResultString += String(char)
            }
        }
        
        if isOneElementHealsy {
            return resultResultString
        } else {
            helsyPercentLabel.isHidden = true
            helsiTitle.isHidden = true
            helsiItemsLabel.isHidden = true
            return ""
        }
    }
    
    func parsing(_ components: [ProductComponent]?) -> String {
        guard let components = components else {
            componentStackAlertImageView.isHidden = true
            componentStock.isHidden = true
            return ""
        }
        var resultString = ""
        var isOneElementBlackListed = false
        
        for component in components {
            if component.is_blacklisted {
                isOneElementBlackListed = true
                resultString += component.name + ", "
            }
        }
        
        var resultResultString = ""
        
        for (index, char) in resultString.enumerated() {
            if index == resultString.count - 1 ||
                index == resultString.count - 2 {
                continue
            } else {
                resultResultString += String(char)
            }
        }
        
        if isOneElementBlackListed {
            return resultResultString
        } else {
            componentStackAlertImageView.isHidden = true
            componentStock.isHidden = true
            return ""
        }
    }
    
    //MARK: - VC cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Delegates
        configure(with: product)
        configureUI()
    }
    
    func setupPieChartData(_ firstFloat: Float) {
        let seconFloat = 100.0 - firstFloat
        let data: [String: Float] = [
            "test": firstFloat,
            "": seconFloat,
        ]
        
        pieChart.set(data: data)
    }
    
    
    func configureUI() {
        
        cartButton.layer.cornerRadius = 36
        
        pieChartView.addSubview(pieChart)
        // Setup pieChart
        pieChartView.addSubview(pieChart)
        pieChart.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pieChart.topAnchor.constraint(equalTo: pieChartView.topAnchor),
            pieChart.leftAnchor.constraint(equalTo: pieChartView.leftAnchor),
            pieChart.rightAnchor.constraint(equalTo: pieChartView.rightAnchor),
            pieChart.bottomAnchor.constraint(equalTo: pieChartView.bottomAnchor),
        ])
    }
}
