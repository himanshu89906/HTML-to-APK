<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Mobile App</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
            text-align: center;
        }
        header {
            background-color: #333;
            color: #fff;
            padding: 10px 0;
        }
        .container {
            max-width: 800px;
            margin: auto;
            padding: 20px;
        }
        video, img {
            max-width: 100%;
            margin-top: 20px;
            border: 1px solid #ccc;
            border-radius: 5px;
        }
        button {
            padding: 10px 20px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            margin-top: 10px;
            font-size: 16px;
        }
        button:hover {
            background-color: #45a049;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group input[type="text"],
        .form-group input[type="password"] {
            padding: 8px;
            width: 200px;
        }
        .form-group button {
            margin-top: 0;
            padding: 8px 20px;
        }
    </style>
</head>
<body>
    <header>
        <h1>AI Mobile App</h1>
    </header>

    <div class="container">
        <h2>Camera View</h2>
        <video id="videoElement" autoplay></video>
        <br>
        <button onclick="toggleCamera()">Toggle Camera</button>
        <button onclick="toggleRecording()">Start/Stop Recording</button>
        <br><br>

        <h2>Video Call</h2>
        <div class="form-group">
            <input type="email" id="email" placeholder="Enter Email">
        </div>
        <div class="form-group">
            <input type="password" id="password" placeholder="Enter Password">
        </div>
        <div class="form-group">
            <button onclick="signIn()">Sign In</button>
        </div>
        <div class="form-group">
            <button onclick="initiateCall()">Call Friend</button>
        </div>
        <br>
        <video id="remoteVideo" autoplay style="display:none;"></video>
    </div>

    <script>
        let videoStream;
        let mediaRecorder;
        let recordedChunks = [];
        let isCameraOn = true;
        let isRecording = false;
        let isCalling = false;
        let peerConnection;

        async function startCamera() {
            try {
                const constraints = {
                    video: true,
                    audio: true
                };

                videoStream = await navigator.mediaDevices.getUserMedia(constraints);
                document.getElementById("videoElement").srcObject = videoStream;

            } catch (error) {
                console.error("Error accessing camera:", error);
            }
        }

        function toggleCamera() {
            if (isCameraOn) {
                videoStream.getVideoTracks()[0].enabled = false;
                isCameraOn = false;
            } else {
                videoStream.getVideoTracks()[0].enabled = true;
                isCameraOn = true;
            }
        }

        function toggleRecording() {
            if (!isRecording) {
                startRecording();
            } else {
                stopRecording();
            }
        }

        function startRecording() {
            recordedChunks = [];
            mediaRecorder = new MediaRecorder(videoStream);

            mediaRecorder.ondataavailable = function(event) {
                if (event.data.size > 0) {
                    recordedChunks.push(event.data);
                }
            };

            mediaRecorder.start();
            isRecording = true;
        }

        function stopRecording() {
            mediaRecorder.stop();
            isRecording = false;
        }

        function signIn() {
            // Simulate sign-in with email and password
            const email = document.getElementById('email').value;
            const password = document.getElementById('password').value;

            // Perform authentication (mocked for demonstration)
            if (email && password) {
                alert('Signed in successfully!');
            } else {
                alert('Please enter valid credentials.');
            }
        }

        async function initiateCall() {
            const email = document.getElementById('email').value;
            const password = document.getElementById('password').value;

            // Simulate sign-in with email and password
            if (!email || !password) {
                alert('Please sign in with valid credentials.');
                return;
            }

            // Replace with your signaling server URL or use a signaling service
            const signalingServerUrl = 'ws://localhost:8080';

            peerConnection = new RTCPeerConnection();

            // Get local video/audio tracks and add them to the peer connection
            videoStream.getTracks().forEach(track => peerConnection.addTrack(track, videoStream));

            // Handle incoming media streams
            peerConnection.ontrack = function(event) {
                document.getElementById("remoteVideo").srcObject = event.streams[0];
                document.getElementById("remoteVideo").style.display = 'block';
            };

            // Simulated signaling server connection (replace with your logic)
            const ws = new WebSocket(signalingServerUrl);
            ws.onmessage = async function(event) {
                const message = JSON.parse(event.data);

                if (message.type === 'offer') {
                    await peerConnection.setRemoteDescription(new RTCSessionDescription(message));
                    const answer = await peerConnection.createAnswer();
                    await peerConnection.setLocalDescription(answer);
                    ws.send(JSON.stringify(answer));
                } else if (message.type === 'answer') {
                    await peerConnection.setRemoteDescription(new RTCSessionDescription(message));
                } else if (message.type === 'candidate') {
                    await peerConnection.addIceCandidate(new RTCIceCandidate(message.candidate));
                }
            };

            // Simulated offer creation
            const offer = await peerConnection.createOffer();
            await peerConnection.setLocalDescription(offer);
            ws.send(JSON.stringify(offer));

            isCalling = true;
        }

        // Start the camera when the page loads
        startCamera();
    </script>
</body>
</html>
