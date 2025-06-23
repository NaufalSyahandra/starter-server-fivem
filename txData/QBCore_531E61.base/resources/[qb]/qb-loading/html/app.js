// Global variables
let audioEnabled = true;
let videoEnabled = true;
let motionEnabled = true;

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    initializeAudio();
    startProgressAnimation();
    setupEventListeners();
});

function initializeAudio() {
    const audio = document.getElementById('background-audio');
    audio.volume = 0.1;
    audio.play().catch(console.log);
}

function setupEventListeners() {
    document.getElementById('settings-btn').onclick = () => openModal('settings-modal');
    document.getElementById('info-btn').onclick = () => openModal('info-modal');

    // Close modals on outside click
    document.querySelectorAll('.modal').forEach(modal => {
        modal.onclick = (e) => {
            if (e.target === modal) closeModal(modal.id);
        };
    });
}

function openModal(modalId) {
    document.getElementById(modalId).classList.add('active');
}

function closeModal(modalId) {
    document.getElementById(modalId).classList.remove('active');
}

function toggleAudio() {
    const toggle = document.getElementById('audio-toggle');
    const audio = document.getElementById('background-audio');

    audioEnabled = !audioEnabled;
    toggle.classList.toggle('active', audioEnabled);

    if (audioEnabled) {
        audio.play().catch(console.log);
    } else {
        audio.pause();
    }
}

function toggleVideo() {
    const toggle = document.getElementById('video-toggle');
    const video = document.querySelector('.video-background');

    videoEnabled = !videoEnabled;
    toggle.classList.toggle('active', videoEnabled);

    if (videoEnabled) {
        video.play().catch(console.log);
    } else {
        video.pause();
    }
}

function toggleMotion() {
    const toggle = document.getElementById('motion-toggle');
    motionEnabled = !motionEnabled;
    toggle.classList.toggle('active', motionEnabled);

    document.body.style.setProperty('--animation-duration', motionEnabled ? '1s' : '0.1s');
}

function startProgressAnimation() {
    const progressBar = document.getElementById('progress');
    let progress = 0;

    const interval = setInterval(() => {
        progress += Math.random() * 5;
        if (progress >= 100) {
            progress = 100;
            clearInterval(interval);
            setTimeout(() => {
                // Simulate connection complete
                document.querySelector('.progress-text').textContent = 'Connection Complete!';
            }, 500);
        }
        progressBar.style.width = progress + '%';
    }, 200);
}

// FiveM Loading Handler Functions
const handlers = {
    startInitFunctionOrder(data) {
        this.count = data.count;
        document.querySelector('.progress-text').textContent = 'Initializing Functions...';
    },

    initFunctionInvoking(data) {
        const progress = (data.idx / this.count) * 100;
        document.getElementById('progress').style.width = progress + '%';
    },

    startDataFileEntries(data) {
        this.count = data.count;
        document.querySelector('.progress-text').textContent = 'Loading Data Files...';
    },

    performMapLoadFunction(data) {
        this.thisCount = (this.thisCount || 0) + 1;
        const progress = (this.thisCount / this.count) * 100;
        document.getElementById('progress').style.width = progress + '%';
        document.querySelector('.progress-text').textContent = 'Loading Map Data...';
    }
};

// FiveM message handler
window.addEventListener('message', function(e) {
    (handlers[e.data.eventName] || function(){}).call(handlers, e.data);
});