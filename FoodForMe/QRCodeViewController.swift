// Project: BagawadiEllurSatvik - Final
// EID: sb64354
// Course: CS329E

import UIKit
import AVFoundation

class QRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    // video preview layer to show camera feed
    var video = AVCaptureVideoPreviewLayer()
    var isProcessingBarcode = false
    // session to capture input and output
    var session: AVCaptureSession?

    override func viewDidLoad() {
        super.viewDidLoad()

        // request camera authorization and set up camera
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                if granted {
                    self.setupCamera()
                } else {
                    self.showAlert(title: "Camera Access", message: "Camera access is required to scan barcodes.")
                }
            }
        }
    }

    // setup camera for scanning barcodes
    func setupCamera() {
        // initialize capture session
        session = AVCaptureSession()
        // trys to get access to camera
        guard let captureDevice = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: captureDevice),
              let session = session else {
            // shows an alert if the camera is not available
            showAlert(title: "Error", message: "Unable to access the camera.")
            return
        }

        // add camera input to the session
        if session.canAddInput(input) {
            session.addInput(input)
        }
        // set up the metadata output for barcode detection
        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            // define the barcode types to detect
            output.metadataObjectTypes = [.qr, .ean8, .ean13, .pdf417, .code128, .code39, .code93]
        }

        // setups video preview
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = view.layer.bounds
        video.videoGravity = .resizeAspectFill
        view.layer.addSublayer(video)
        // start capturing the video feed
        session.startRunning()
    }

    // called when a barcode is deteected
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // makes sure only one barcode is processed at a time
        guard !isProcessingBarcode,
              let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
              let barcode = metadataObject.stringValue else { return }

        isProcessingBarcode = true
        session?.stopRunning()
        // grab the product infomation from the scanned barcode
        fetchProductInformation(barcode: barcode)
    }

    // gets the product information from the API using the scanned barcode
    func fetchProductInformation(barcode: String) {
        OpenFoodFactsAPI.fetchProduct(by: barcode) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let product):
                    self.navigateToProductInformationScreen(product)
                case .failure:
                    self.showAlert(title: "Error", message: "Unable to fetch product information.")
                }
            }
        }
    }

    // once the barcode processes the product, it instantly goes to the product information view controller
    func navigateToProductInformationScreen(_ product: OpenFoodFactsAPI.Product) {
        guard let productInfoVC = storyboard?.instantiateViewController(withIdentifier: "BarcodeToProductIdentifier") as? ProductInformationViewController else {
            // reset scanning if navigation fails
            self.resetScanning()
            return
        }
        // pass product details to next screen
        productInfoVC.productNameText = product.name
        productInfoVC.allergenList = product.allergens
        navigationController?.pushViewController(productInfoVC, animated: true)
    }

    // shows an alert with a message passed from the method call
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            // reset the scannng once the alert is dismissed
            self.resetScanning()
        })
        present(alert, animated: true)
    }

    // resets the scanning state and restarts the session
    func resetScanning() {
        isProcessingBarcode = false
        session?.startRunning()
    }

    // start scanning when the view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetScanning()
    }

    // stops scanning when the view disappears
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session?.stopRunning()
    }
}
