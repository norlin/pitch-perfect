//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by norlin on 25/05/15.
//  Copyright (c) 2015 norlin. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject {
	var filePath: NSURL!
	var title: String!
	
	init(filePath: NSURL, title: String) {
		self.filePath = filePath
		self.title = title
	}
}