//
//  RealtimeUpdateFeature.swift
//  CrowdinSDK
//
//  Created by Serhii Londar on 3/5/19.
//

import Foundation

protocol RealtimeUpdateFeatureProtocol {
    static var shared: RealtimeUpdateFeatureProtocol? { get set }
    
    var success: (() -> Void)? { get set }
    var error: ((Error) -> Void)? { set get }
    var enabled: Bool { get set }
    
	init(localization: String, strings: [String], plurals: [String], hash: String, sourceLanguage: String, organizationName: String?)
    
    func start(success: (() -> Void)?, error: ((Error) -> Void)?)
    func stop()
    func subscribe(control: Refreshable)
    func unsubscribe(control: Refreshable)
    func refreshAllControls()
}

class RealtimeUpdateFeature: RealtimeUpdateFeatureProtocol {
    static var shared: RealtimeUpdateFeatureProtocol?
    
    var success: (() -> Void)?
    var error: ((Error) -> Void)?
    var localization: String
    var hashString: String
    let organizationName: String?
	
	let distributionsAPI: DistributionsAPI
	var distributionResponse: DistributionsResponse? = nil
	
    var active: Bool { return socketManger?.active ?? false }
    var enabled: Bool {
        set {
            newValue ? start() : stop()
        }
        get {
            return active
        }
    }
    
    private var controls = NSHashTable<AnyObject>.weakObjects()
    private var socketManger: CrowdinSocketManagerProtocol?
    private var mappingManager: CrowdinMappingManagerProtocol
    
    required init(localization: String, strings: [String], plurals: [String], hash: String, sourceLanguage: String, organizationName: String? = nil) {
        self.localization = localization
        self.hashString = hash
		self.organizationName = organizationName
		self.distributionsAPI = DistributionsAPI(hashString: hash, organizationName: organizationName)
        self.mappingManager = CrowdinMappingManager(strings: strings, plurals: plurals, hash: hash, sourceLanguage: sourceLanguage, enterprise: organizationName != nil)
		self.downloadDistribution()
    }
	
	func downloadDistribution(with completion: ((Bool) -> Void)? = nil) {
		// TODO: Add better error handling.
		self.distributionsAPI.getDistribution { (response, error) in
			self.distributionResponse = response
			completion?(error == nil && response != nil)
		}
	}
    
    func subscribe(control: Refreshable) {
        guard let localizationKey = control.key else { return }
        guard let id = self.mappingManager.id(for: localizationKey) else { return }
        socketManger?.subscribeOnUpdateDraft(localization: localization, stringId: id)
        socketManger?.subscribeOnUpdateTopSuggestion(localization: localization, stringId: id)
        controls.add(control)
    }
    
    func unsubscribe(control: Refreshable) {
        controls.remove(control)
    }
    
    func start(success: (() -> Void)? = nil, error: ((Error) -> Void)? = nil) {
        if LoginFeature.isLogined {
            _start(with: success, error: error)
        } else if let loginFeature = LoginFeature.shared {
            loginFeature.login(completion: {
                self.start(success: success, error: error)
            }) { err in
                error?(err)
            }
        } else {
            print("Login feature is not configured properly")
            error?(NSError(domain: "Login feature is not configured properly", code: defaultCrowdinErrorCode, userInfo: nil))
        }
    }
    
    func _start(with success: (() -> Void)? = nil, error: ((Error) -> Void)? = nil) {
        self.success = success
        self.error = error
		guard let projectId = distributionResponse?.data.project.id, let projectWsHash = distributionResponse?.data.project.wsHash, let userId = distributionResponse?.data.user.id else {
			self.downloadDistribution { (downloaded) in
				if downloaded {
					self._start(with: success, error: error)
				} else {
					error?(NSError(domain: "Unable to download project distribution information.", code: defaultCrowdinErrorCode, userInfo: nil))
				}
			}
			return
		}
		self.socketManger = CrowdinSocketManager(hashString: hashString, projectId: projectId, projectWsHash: projectWsHash, userId: userId, enterprise: organizationName != nil)
        self.socketManger?.didChangeString = { id, newValue in
            self.didChangeString(with: id, to: newValue)
        }
        
        self.socketManger?.didChangePlural = { id, newValue in
            self.didChangePlural(with: id, to: newValue)
        }
        
        self.socketManger?.error = error
        self.socketManger?.connect = {
            self.success?()
            self.subscribeAllVisibleConrols()
        }
        
        self.socketManger?.start()
    }
    
    func stop() {
        self.socketManger?.stop()
        self.socketManger?.didChangeString = nil
        self.socketManger?.didChangePlural = nil
        self.socketManger = nil
    }
    
    func refreshAllControls() {
        self.controls.allObjects.forEach { (control) in
            if let refreshable = control as? Refreshable {
                refreshable.refresh()
            }
        }
    }
}

extension RealtimeUpdateFeature {
    func refreshControl(with localizationKey: String, newText: String) {
        self.controls.allObjects.forEach { (control) in
            if let refreshable = control as? Refreshable {
                if let key = refreshable.key, key == localizationKey {
                    refreshable.refresh(text: newText)
                }
            }
        }
    }
    
    func subscribeAllVisibleConrols() {
        guard let window = UIApplication.shared.keyWindow else { return }
        subscribeAllControls(from: window)
    }
    
    func subscribeAllControls(from view: UIView) {
        view.subviews.forEach { (subview) in
            if let refreshable = subview as? Refreshable {
                self.subscribe(control: refreshable)
            }
            subscribeAllControls(from: subview)
        }
    }
    
    func didChangeString(with id: Int, to newValue: String) {
        guard let key = mappingManager.stringLocalizationKey(for: id) else { return }
        self.refreshControl(with: key, newText: newValue)
    }
    
    func didChangePlural(with id: Int, to newValue: String) {
        guard let key = mappingManager.stringLocalizationKey(for: id) else { return }
        self.refreshControl(with: key, newText: newValue)
    }
}
