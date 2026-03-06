// Audio sprite player using Web Audio API.
// Loaded by Flutter web and called from Dart via dart:js.
window._audioSprite = {
    ctx: null,
    buffer: null,
    currentSource: null,

    init: function () {
        if (this.ctx) return;
        this.ctx = new (window.AudioContext || window.webkitAudioContext)();
        console.log('[AudioSprite] AudioContext created, state=' + this.ctx.state);
    },

    load: async function (url) {
        this.init();
        try {
            const response = await fetch(url);
            const arrayBuffer = await response.arrayBuffer();
            this.buffer = await this.ctx.decodeAudioData(arrayBuffer);
            console.log('[AudioSprite] ✅ Decoded: ' + this.buffer.duration.toFixed(2) + 's');
            return true;
        } catch (e) {
            console.error('[AudioSprite] ✗ load failed:', e);
            return false;
        }
    },

    play: async function (offsetSec, durationSec, label) {
        if (!this.buffer || !this.ctx) {
            console.error('[AudioSprite] ✗ Not loaded for ' + label);
            return;
        }
        // Resume context if Chrome suspended it
        if (this.ctx.state === 'suspended') {
            await this.ctx.resume();
            console.log('[AudioSprite] AudioContext resumed');
        }
        // Stop previous source safely
        if (this.currentSource) {
            try { this.currentSource.stop(0); } catch (e) { }
            this.currentSource.disconnect();
        }
        // New source node (single-use in Web Audio)
        const source = this.ctx.createBufferSource();
        source.buffer = this.buffer;
        source.connect(this.ctx.destination);
        source.start(0, offsetSec, durationSec);
        this.currentSource = source;
        console.log('[AudioSprite] ▶ ' + label + ' @' + offsetSec.toFixed(3) + 's for ' + durationSec.toFixed(3) + 's');
    }
};
