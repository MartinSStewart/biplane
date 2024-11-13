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
    console.stdlog = console.log.bind(console);
    console.log = function(){
        setTimeout(() => app.ports.console_log_from_js.send(arguments[0]), 1);
        console.stdlog(arguments);
        console.stdlog.apply(console, arguments);
    }


    let context = null;
    let sounds = {};
    app.ports.load_sounds_to_js.subscribe((a) => {
        context = new AudioContext();
        loadAudio("pop", context, sounds);
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
                const source = context.createBufferSource();
                source.buffer = sounds[a.name];
                source.connect(context.destination);
                source.start((Math.random() * 10 + i * 10) / 1000);
            }
        }
    });
}
