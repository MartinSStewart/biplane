async function loadAudio(url, context, sounds) {
    try {
        const response = await fetch("/" + url + ".mp3");
        const responseBuffer = await response.arrayBuffer();
        sounds[url] = await context.decodeAudioData(responseBuffer);
    } catch (error) {
        console.log(error);
        sounds[url] = null;
    }
}

exports.init = async function(app) {
    let listeningToConsole = false;
    app.ports.listen_to_console.subscribe((a) => {
        if (!listeningToConsole) {
            listeningToConsole = true;
            console.stdlog = console.log.bind(console);
            console.log = function(){
                setTimeout(() => app.ports.console_log_from_js.send(arguments[0]), 1);
                console.stdlog.apply(console, arguments);
            }
        }
    });



    let context = null;
    let sounds = {};
    app.ports.load_sounds_to_js.subscribe((a) => {
        context = new AudioContext();
        loadAudio("pop", context, sounds);
        loadAudio("brick-placed", context, sounds);
        loadAudio("undo", context, sounds);
        loadAudio("redo", context, sounds);
        loadAudio("resize-brick", context, sounds);
        app.ports.load_sounds_from_js.send(null);
    });
    app.ports.play_sound.subscribe((a) => {
        const source = context.createBufferSource();
        if (sounds[a]) {
            source.buffer = sounds[a];
            source.connect(context.destination);
            source.start(0);
        }
    });
    app.ports.repeat_sound.subscribe((a) => {
        if (sounds[a.name]) {
            for (let i = 0; i < a.count; i++) {
                let source = context.createBufferSource();
                source.buffer = sounds[a.name];
                source.connect(context.destination);
                source.start(context.currentTime + (Math.random() * 20 + i * 20) / 1000);
            }
        }
    });

    app.ports.request_pointer_lock_to_js.subscribe(a => document.body.requestPointerLock());

    app.ports.martinsstewart_elm_device_pixel_ratio_to_js.subscribe(a => app.ports.martinsstewart_elm_device_pixel_ratio_from_js.send(window.devicePixelRatio));

    document.addEventListener("pointerlockchange", (a) => {
        app.ports.pointer_lock_change_from_js.send(document.pointerLockElement !== null);
    });


}
