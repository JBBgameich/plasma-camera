/****************************************************************************
**
** Copyright (C) 2013 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Digia Plc and its Subsidiary(-ies) nor the names
**     of its contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.0
import QtMultimedia 5.4

Rectangle {
	id : cameraUI

	width: 1080
	height: 1920

	// color: "#BBADA0"
	state: "PhotoCapture"

	property bool menuShown: false

	states: [
		State {
			name: "PhotoCapture"
			StateChangeScript {
				script: {
					camera.captureMode = Camera.CaptureStillImage
					camera.start()
				}
			}
			PropertyChanges {
				target: photoPreview
				width: cameraUI.width / 5
				height: cameraUI.height / 5
			}
		},
		State {
			name: "PhotoPreview"
			PropertyChanges {
				target: photoPreview
				width: cameraUI.width
				height: cameraUI.height
			}
			PropertyChanges {
				target: photoPreviewTimer
				running: true
			}
		},
		State {
			name: "VideoCapture"
			StateChangeScript {
				script: {
					camera.captureMode = Camera.CaptureVideo
					camera.start()
				}
			}
		},
		State {
			name: "VideoPreview"
			StateChangeScript {
				script: {
					camera.stop()
				}
			}
		}
	]

	transitions: [
		Transition {
			id: previewTransition
			NumberAnimation {
				properties: "width, height"
				duration: units.longDuration
			}
		}
	]

	Timer {
		id: photoPreviewTimer
		interval: 2000
		onTriggered: cameraUI.state = "PhotoCapture"
	}
	Camera {
		id: camera
		captureMode: Camera.CaptureStillImage

		imageCapture {
			onImageCaptured: {
				stillControls.previewAvailable = true
				previewTransition.enabled = false;
				cameraUI.state = "PhotoPreview"
				previewTransition.enabled = true;
			}
		}

		videoRecorder {
			resolution: "640x480"
			frameRate: 15
		}
	}

	PhotoPreview {
		id : photoPreview
		z: 999
		anchors {
			right : parent.right
			bottom: parent.bottom
		}
		onClicked: {
			cameraUI.state == "PhotoCapture" ? cameraUI.state = "PhotoPreview" : cameraUI.state = "PhotoCapture";
			photoPreviewTimer.running = false;
		}
		//visible: cameraUI.state == "PhotoPreview"

		focus: visible
	}

	VideoPreview {
		id : videoPreview
		anchors.fill : parent
		onClosed: cameraUI.state = "VideoCapture"
		visible: cameraUI.state == "VideoPreview"
		focus: visible

		//don't load recorded video if preview is invisible
		source: visible ? camera.videoRecorder.actualLocation : ""
	}
// 
	VideoOutput {
		id: viewfinder
		visible: cameraUI.state == "PhotoCapture" || cameraUI.state == "VideoCapture"

		anchors.fill: parent

		source: camera
	// orientation: -90
	}
	PinchArea {
		anchors.fill: parent
		property real initialZoom
		onPinchStarted: {
			initialZoom = camera.digitalZoom;
		}
		onPinchUpdated: {
			var scale = camera.maximumDigitalZoom/8 * pinch.scale - camera.maximumDigitalZoom/8;
			camera.setDigitalZoom(Math.min(camera.maximumDigitalZoom, camera.digitalZoom + scale))
		}
	}

	PhotoCaptureControls {
		id: stillControls
		anchors.fill: parent
		camera: camera
		visible: cameraUI.state == "PhotoCapture"
		onPreviewSelected: cameraUI.state = "PhotoPreview"
		onVideoModeSelected: cameraUI.state = "VideoCapture"
	}

	VideoCaptureControls {
		id: videoControls
		anchors.fill: parent
		camera: camera
		visible: cameraUI.state == "VideoCapture"
		onPreviewSelected: cameraUI.state = "VideoPreview"
		onPhotoModeSelected: cameraUI.state = "PhotoCapture"
	}
}
