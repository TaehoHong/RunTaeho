import MetalKit
import UnityFramework

class Unity: ObservableObject  {
    /* UnityFramework's principal class is implemented as a singleton
       so we will do the same. Singleton init is lazy and thread safe. */
    static let shared = Unity()

    // MARK: Lifecycle
    private let frameworkPath: String = "/Frameworks/UnityFramework.framework"

    private var loaded = false
    private let framework: UnityFramework

    private init() {
        // Load framework and get the singleton instance
        let bundlePath = Bundle.main.bundlePath + self.frameworkPath
        let bundle = Bundle(path: bundlePath)
        
        if bundle?.isLoaded == false {
            bundle?.load()
        }
        
        framework = bundle?.principalClass?.getInstance()! as! UnityFramework

        let executeHeader = #dsohandle.assumingMemoryBound(to: MachHeader.self)
        framework.setExecuteHeader(executeHeader)

        framework.setDataBundleId("com.unity3d.framework")
    }

    func start() {
        // Load native state textures concurrently
        let loadingGroup = DispatchGroup()
        loadingGroup.wait()

        /* Unity finishes starting - runEmbedded() returns - before completing
           its first render. If the view is displayed immediately it often shows the
           content leftover from the previous run until Unity renders again and overwrites it.
           Clearing Unity's layer with transparent color before restart hides this brief artifact. */
        if let layer = framework.appController()?.rootView?.layer as? CAMetalLayer, let drawable = layer.nextDrawable(), let buffer = MTLCreateSystemDefaultDevice()?.makeCommandQueue()?.makeCommandBuffer() {
            let descriptor = MTLRenderPassDescriptor()
            descriptor.colorAttachments[0].loadAction = .clear
            descriptor.colorAttachments[0].storeAction = .store
            descriptor.colorAttachments[0].texture = drawable.texture
            descriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0)
            /* Unity does not render an alpha value by default; transparent is written
               as opaque. To fix this we have enabled "Render Over Native UI" in the Unity
               project player settings. This is an alias for the preserveFramebufferAlpha scripting
               property: docs.unity3d.com/ScriptReference/PlayerSettings-preserveFramebufferAlpha.html */

            if let encoder = buffer.makeRenderCommandEncoder(descriptor: descriptor) {
                encoder.label = "Unity Prestart Clear"
                encoder.endEncoding()
                buffer.present(drawable)
                buffer.commit()
                buffer.waitUntilCompleted()
            }
        }

        // Start Unity
        framework.runEmbedded(withArgc: CommandLine.argc, argv: CommandLine.unsafeArgv, appLaunchOpts: nil)

        // Hide Unity's UIWindow so it won't display UIView or intercept touches
        framework.appController().window.isHidden = true

        loaded = true
    }

    func stop() {
        // docs.unity3d.com/ScriptReference/Application.Unload.html
        framework.unloadApplication()

        /* We could unload native state textures here too, but on restart
           we will have to ensure Unity does not have any texture reference else reading
           will result in a null pointer exception. For now we will leave the memory as allocated. */

        loaded = false
    }

    // Expose Unity's UIView while loaded
    var view: UIView? { loaded ? framework.appController().rootView : nil }

    func sendMessage(_ objectName: String, methodName: String, parameter: String) {
        // Unity와의 통신을 위한 코드 구현
        
        if loaded {
            self.framework.sendMessageToGO(withName: objectName, functionName: methodName, message: parameter)
        }
    
        // let unityObject = unityView.findObject(named: objectName)
        // unityObject?.sendMessage(methodName, parameter: parameter)
    }
}

// MARK: Extensions

extension URL {
    func loadTexture() -> MTLTexture? {
        let device = MTLCreateSystemDefaultDevice()!
        let loader = MTKTextureLoader(device: device)
        return try? loader.newTexture(URL: self)
    }
}
