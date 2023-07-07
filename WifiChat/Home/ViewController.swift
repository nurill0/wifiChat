//
//  ViewController.swift
//  WifiChat
//
//  Created by Nurillo Domlajonov on 08/06/23.
//

import UIKit
import MultipeerConnectivity


class ViewController: UIViewController {
    
    var messageTime: [String] = []
    var deviceName: [String] = []
    var isConnected = false
    var allMessages: [String] = []
    var userDefault = UserDefaultsManager.shared
    var currentTime = ""
    //MARK: private constants
    private let serviceType = "mctest"
    let currentDate = Date() // Get the current date and time
    let dateFormatter = DateFormatter() // Create a date formatter

    //MARK: private
    private var multipeerSession: MCSession?
    private var peerId = MCPeerID(displayName: UIDevice.current.name)
    private var browser: MCNearbyServiceBrowser?
    private var advertiser: MCNearbyServiceAdvertiser?
    
    lazy var containerV : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = #colorLiteral(red: 0.8799401522, green: 0.9148583412, blue: 0.9700120091, alpha: 1)
        
        return view
    }()
    
    
    lazy var messageTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Message"
        tf.layer.cornerRadius = 15
        tf.leftView = UIView(frame: CGRect(x: 15, y: 15, width: 15, height: 15))
        tf.leftViewMode = .always
        tf.layer.borderWidth = 0.5
        
        return tf
    }()
    
    
    lazy var sendButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "paperplane.fill")?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
        btn.addTarget(self, action: #selector(sendMessages), for: .touchUpInside)
        
        return btn
    }()
    
    
    lazy var messageTableView: UITableView = {
        let tbV = UITableView()
        tbV.translatesAutoresizingMaskIntoConstraints = false
        tbV.autoresizesSubviews = true
        tbV.register(MessageTableViewCell.self, forCellReuseIdentifier: "messageCell")
        tbV.delegate = self
        tbV.dataSource = self
        tbV.separatorStyle = .none
        tbV.rowHeight = UITableView.automaticDimension
        tbV.backgroundColor = #colorLiteral(red: 0.8799401522, green: 0.9148583412, blue: 0.9700120091, alpha: 1)

        return tbV
    }()
    
    
}



//life cycle
extension ViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Waiting..."
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "antenna.radiowaves.left.and.right")?.withTintColor(.black, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(getConnect))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "trash.fill")?.withTintColor(.black, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(clearMessages))
        
        
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.timeStyle = .medium // Set the time style
        currentTime = dateFormatter.string(from: currentDate)
        configureUI()
        view.backgroundColor = #colorLiteral(red: 0.8799401522, green: 0.9148583412, blue: 0.9700120091, alpha: 1)
        multipeerSession = MCSession(peer: peerId, securityIdentity: nil, encryptionPreference: .none)
        multipeerSession?.delegate = self
        startBrowser()
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
}



//actions
extension ViewController {
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func clearMessages(){
        allMessages = []
        deviceName = []
        messageTime = []
        messageTableView.reloadData()
    }
    
    
    @objc func getConnect(){
        if isConnected {
            multipeerSession?.connectedPeers.forEach({
                multipeerSession?.cancelConnectPeer($0)
                navigationItem.leftBarButtonItem?.image = UIImage(systemName: "antenna.radiowaves.left.and.right.slash")
            })
            stopBrowsingAndAdvertising()
            startBrowser()
        }else{
            stopBrowsingAndAdvertising()
            startAdvertiser()
            navigationItem.leftBarButtonItem?.image = UIImage(systemName: "antenna.radiowaves.left.and.right.slash")
        }
        isConnected.toggle()
    }
    
    
    @objc func sendMessages(){
        guard let message = messageTextField.text else {return}
       
        sendMessage(message: message)
        messageTime.append(currentTime)
        deviceName.append(peerId.displayName)
        print(messageTime)
        allMessages.append(message)
        messageTableView.reloadData()
        messageTextField.text = ""
    }
    
}



//MARK: tableView delegate
extension ViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMessages.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageTableViewCell
        cell.messageLbl.text = allMessages[indexPath.row]
        cell.deviceNameLbl.text = deviceName[indexPath.row]
        cell.timeLbl.text = messageTime[indexPath.row]
        return cell
    }
    
    
}



//MARK: Functions
private extension ViewController {
    
    
    func startAdvertiser(){
        advertiser = MCNearbyServiceAdvertiser(peer: peerId, discoveryInfo: nil, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }
    
    
    func startBrowser(){
        browser = MCNearbyServiceBrowser(peer: peerId, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
    }
    
    
    func stopBrowsingAndAdvertising(){
        if let browser = browser {
            browser.stopBrowsingForPeers()
        }
        
        if let advertiser = advertiser {
            advertiser.stopAdvertisingPeer()
        }
        
        multipeerSession?.disconnect()
    }
    
    
    func sendMessage(message: String){
        guard let connectedPeers = multipeerSession?.connectedPeers,
              let messageData = try? JSONEncoder().encode(message) else {return}
        do {
            try multipeerSession?.send(messageData, toPeers: connectedPeers, with: .reliable)
        }catch{}
    }
    
}


//MARK: MCSessionDelegate
extension ViewController: MCSessionDelegate {
    
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connecting:
            DispatchQueue.main.async {
                self.navigationItem.title = "Connecting"
            }
        case .connected:
            DispatchQueue.main.async {
                self.navigationItem.title = "Connected"
                self.navigationItem.leftBarButtonItem?.image = UIImage(systemName: "antenna.radiowaves.left.and.right.slash")?.withTintColor(.red, renderingMode: .alwaysOriginal)
            }
        case .notConnected:
            DispatchQueue.main.async {
                self.navigationItem.title = "Disconnected!"
                self.navigationItem.leftBarButtonItem?.image = UIImage(systemName: "antenna.radiowaves.left.and.right")?.withTintColor(.green, renderingMode: .alwaysOriginal)
            }
        @unknown default:
            DispatchQueue.main.async {
                self.navigationItem.title = "Unknown error!"
            }
        }
    }
    
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async { [self] in
            guard let message = try? JSONDecoder().decode( String.self, from: data) else {return}
            dateFormatter.timeStyle = .short // Set the time style
            self.deviceName.append(peerID.displayName)
            self.allMessages.append(message)
            self.messageTime.append(currentTime)
            self.messageTableView.reloadData()
        }
    }
    
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
    }
    
    
}



//MARK: MCNearbyServiceAdvertiserDelegate
extension ViewController: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        invitationHandler(true, multipeerSession)
    }
    
}



//MARK: MCNearbyServiceBrowserDelegate
extension ViewController: MCNearbyServiceBrowserDelegate {
    
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        guard let multipeerSession = multipeerSession else { return }
        browser.invitePeer(peerID, to: multipeerSession, withContext:  nil, timeout: 10.0)
    }
    
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
    }
    
}



//MARK: UI
extension ViewController {
    
    
    fileprivate func configureUI(){
        containerVConst()
        sendMessageBtnConst()
        messageTFConst()
        tableViewConst()
    }
    
    
    fileprivate func containerVConst(){
        view.addSubview(containerV)
        NSLayoutConstraint.activate([
            containerV.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerV.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            containerV.rightAnchor.constraint(equalTo: view.rightAnchor),
            containerV.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])
    }
    
    
    fileprivate func messageTFConst(){
        containerV.addSubview(messageTextField)
        NSLayoutConstraint.activate([
            messageTextField.bottomAnchor.constraint(equalTo: containerV.bottomAnchor),
            messageTextField.leftAnchor.constraint(equalTo: containerV.leftAnchor, constant: 10),
            messageTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: -10),
            messageTextField.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
    
    
    fileprivate func sendMessageBtnConst(){
        containerV.addSubview(sendButton)
        NSLayoutConstraint.activate([
            sendButton.bottomAnchor.constraint(equalTo: containerV.bottomAnchor),
            sendButton.rightAnchor.constraint(equalTo: containerV.rightAnchor, constant: -10),
            sendButton.heightAnchor.constraint(equalToConstant: 45),
            sendButton.widthAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    
    fileprivate func tableViewConst(){
        containerV.addSubview(messageTableView)
        NSLayoutConstraint.activate([
            messageTableView.topAnchor.constraint(equalTo: containerV.topAnchor),
            messageTableView.bottomAnchor.constraint(equalTo: messageTextField.topAnchor, constant: -10),
            messageTableView.rightAnchor.constraint(equalTo: containerV.rightAnchor),
            messageTableView.leftAnchor.constraint(equalTo: containerV.leftAnchor),
        ])
    }
    
    
}
