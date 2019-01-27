//
//  StringViewController.swift
//  Browse
//
//  Created by Robby on 8/10/16.
//  Copyright © 2016 Robby. All rights reserved.
//

import UIKit

class ObjectViewController: BaseMenuVC {
	
	func urlIsImage(url:URL) -> Bool{
		let ext:String? = url.pathExtension
		if (ext != nil && ["png", "jpg", "jpeg"].contains(ext!)) {
			return true
		}
		return false
	}
	
	var data:Any?{
		didSet{
			if let d = data{
				let type = FireTiny.shared.typeOf(FirebaseData: d)
				self.title = stringForType( type )
				// if type is image, display image
				self.textView.text = String(describing: d)
				if type == .isURL{
					// force cast is okay, we know it's a string
					if let url = URL(string:d as! String){
						if urlIsImage(url: url){
							DispatchQueue.global(qos: .default).async {
								do{
									let data = try Data(contentsOf: url)
									DispatchQueue.main.async {
										self.textView.text = ""
										self.imageView.image = UIImage(data: data)
									}
								} catch{ }
							}
						}
					}
				}
			}
		}
	}
	
	let textView = UITextView()
	let imageView = UIImageView()

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.view.backgroundColor = UIColor.white

		textView.frame = view.frame
		textView.font = UIFont.systemFont(ofSize: 18)
		textView.backgroundColor = UIColor.clear
		self.view.addSubview(textView)

		imageView.frame = view.frame
		imageView.contentMode = .scaleAspectFit
		imageView.backgroundColor = UIColor.clear
		self.view.addSubview(imageView)
	}
}
