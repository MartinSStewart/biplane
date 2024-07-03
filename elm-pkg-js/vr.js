exports.init = async function init(app)
{
    console.log("js");
    // XR globals.
    let xrSession = null;
    let xrRefSpace = null;

    // WebGL scene globals.
    let gl = null;

    // Checks to see if WebXR is available and, if so, requests an XRDevice
    // that is connected to the system and tests it to ensure it supports the
    // desired session options.
    function initXR() {
        // Is WebXR available on this UA?
        if (navigator.xr) {
          // If the device allows creation of exclusive sessions set it as the
          // target of the 'Enter XR' button.
          navigator.xr.isSessionSupported('immersive-vr').then((supported) => {
            if (supported) {
              // Updates the button to start an XR session when clicked.
            }
          });
        }
    }

    app.ports.requestVrToJs.subscribe((a) => {
        console.log("start");
        if (!xrSession) {
          console.log("abc");
          console.log(navigator.xr);
          navigator.xr.requestSession('immersive-vr').then((session) => {
            console.log("requested session");
            onSessionStarted();
          });
        } else {
          xrSession.end();
        }
    });

    // Called when we've successfully acquired a XRSession. In response we
    // will set up the necessary session state and kick off the frame loop.
    function onSessionStarted(session) {
    console.log("1");
    xrSession = session;

    // Listen for the sessions 'end' event so we can respond if the user
    // or UA ends the session for any reason.
    session.addEventListener('end', onSessionEnded);
    console.log("2");
    // Create a WebGL context to render with, initialized to be compatible
    // with the XRDisplay we're presenting to.
    let canvas = document.createElement('canvas');
    gl = canvas.getContext('webgl', { xrCompatible: true });
    console.log("3");
    // Use the new WebGL context to create a XRWebGLLayer and set it as the
    // sessions baseLayer. This allows any content rendered to the layer to
    // be displayed on the XRDevice.
    session.updateRenderState({ baseLayer: new XRWebGLLayer(session, gl) });
    console.log("4");
    // Get a reference space, which is required for querying poses. In this
    // case an 'local' reference space means that all poses will be relative
    // to the location where the XRDevice was first detected.
    session.requestReferenceSpace('local').then((refSpace) => {
      xrRefSpace = refSpace;

      // Inform the session that we're ready to begin drawing.
      session.requestAnimationFrame(onXRFrame);
    });
    }

    // Called either when the user has explicitly ended the session by calling
    // session.end() or when the UA has ended the session for any reason.
    // At this point the session object is no longer usable and should be
    // discarded.
    function onSessionEnded(event) {
        xrSession = null;

        // In this simple case discard the WebGL context too, since we're not
        // rendering anything else to the screen with it.
        gl = null;
    }

    // Called every time the XRSession requests that a new frame be drawn.
    function onXRFrame(time, frame) {
    let session = frame.session;

    // Inform the session that we're ready for the next frame.
    session.requestAnimationFrame(onXRFrame);

    // Get the XRDevice pose relative to the reference space we created
    // earlier.
    let pose = frame.getViewerPose(xrRefSpace);

    // Getting the pose may fail if, for example, tracking is lost. So we
    // have to check to make sure that we got a valid pose before attempting
    // to render with it. If not in this case we'll just leave the
    // framebuffer cleared, so tracking loss means the scene will simply
    // disappear.
    if (pose) {
      let glLayer = session.renderState.baseLayer;

      // If we do have a valid pose, bind the WebGL layer's framebuffer,
      // which is where any content to be displayed on the XRDevice must be
      // rendered.
      gl.bindFramebuffer(gl.FRAMEBUFFER, glLayer.framebuffer);

      // Update the clear color so that we can observe the color in the
      // headset changing over time.
      gl.clearColor(Math.cos(time / 2000),
                    Math.cos(time / 4000),
                    Math.cos(time / 6000), 1.0);

      // Clear the framebuffer
      gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

      // Normally you'd loop through each of the views reported by the frame
      // and draw them into the corresponding viewport here, but we're
      // keeping this sample slim so we're not bothering to draw any
      // geometry.
      /*for (let view of pose.views) {
        let viewport = glLayer.getViewport(view);
        gl.viewport(viewport.x, viewport.y,
                    viewport.width, viewport.height);

        // Draw a scene using view.projectionMatrix as the projection matrix
        // and view.transform to position the virtual camera. If you need a
        // view matrix, use view.transform.inverse.matrix.
      }*/
    }
    }

    // Start the XR application.
    initXR();

}