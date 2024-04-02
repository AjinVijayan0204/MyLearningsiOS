//
//  CurrencyFormatter.swift
//  Bankey
//
//  Created by Ajin on 02/04/24.
//

import UIKit

class CurrencyFormatter{
    
    public func makeAttributedCurrency(_ amount: Decimal)-> NSMutableAttributedString {
        let tuple = breakIntoDollarsAndCents(amount)
        return makeFormattedBalance(dollars: tuple.0, cents: tuple.1)
    }
    
    func breakIntoDollarsAndCents(_ amount: Decimal)-> (String, String){
        let tuple = modf(amount.doubleValue)
        
        let dollars = convertDollar(tuple.0)
        let cents = convertCents(tuple.1)
        
        return (dollars, cents)
    }
    
    private func convertDollar(_ dollarPart: Double)-> String{
        let dollarWithDecimal = dollarsFormatted(dollarPart)
        let formatter = NumberFormatter()
        let decimalSeperator = formatter.decimalSeparator!
        let dollarComponents = dollarWithDecimal.components(separatedBy: decimalSeperator)
        var dollars = dollarComponents.first!
        dollars.removeFirst()
        
        return dollars
    }
    
    private func convertCents(_ centPart: Double)-> String{
        let cents: String
        if centPart == 0{
            cents = "00"
        }else{
            cents = String(format: "%.0f", centPart*100)
        }
        return cents
    }
    
    func dollarsFormatted(_ dollars: Double)-> String{
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.usesGroupingSeparator = true
        
        if let result = formatter.string(from: dollars as NSNumber){
            return result
        }
        return ""
    }
    
    private func makeFormattedBalance(dollars: String, cents: String)-> NSMutableAttributedString{
        let dollarSignAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(forTextStyle: .callout),
            .baselineOffset: 8]
        let dollarAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(forTextStyle: .title1)]
        let centAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.preferredFont(forTextStyle: .footnote),
            .baselineOffset: 8]
        
        let rootString = NSMutableAttributedString(string: "$", attributes: dollarSignAttributes)
        let dollarString = NSMutableAttributedString(string: dollars, attributes: dollarAttributes)
        let centString = NSMutableAttributedString(string: cents, attributes: centAttributes)
        
        rootString.append(dollarString)
        rootString.append(centString)
        
        return rootString
    }
}
