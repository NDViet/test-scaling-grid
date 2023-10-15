from http.server import BaseHTTPRequestHandler,HTTPServer
from os import environ
import json
import psutil
import time
import signal
import sys

video_ready_port = int(environ.get('VIDEO_READY_PORT', 9000))

class Handler(BaseHTTPRequestHandler):

    def do_GET(self):
        if self.path == '/recording':
            self.video_recording()
        elif self.path == '/status':
            self.video_status()
        else:
            self.video_status()

    def do_POST(self):
        if self.path == '/drain':
            self.video_drain()

    def video_recording(self):
        self.send_response(200)
        self.end_headers()
        self.wfile.write(json.dumps(Handler.is_recording()).encode('utf-8'))

    def video_status(self):
        video_status = Handler.is_alive()
        response_code = 200 if video_status else 404
        self.send_response(response_code)
        self.end_headers()
        self.wfile.write(json.dumps(video_status).encode('utf-8'))

    def video_drain(self):
        recording = Handler.is_recording()
        response_text = 'waiting for recording to be completed' if recording else 'terminating now'
        self.send_response(200)
        self.end_headers()
        self.wfile.write(json.dumps({'status': response_text}).encode('utf-8'))
        quit()

    @staticmethod
    def terminate_gracefully(signum, stack_frame):
        print("Trapped SIGTERM/SIGINT/x so shutting down video-ready...")
        while Handler.is_recording():
            time.sleep(1)
        quit()

    @staticmethod
    def is_alive():
        return Handler.is_proc_running("video.sh")

    @staticmethod
    def is_recording():
        return Handler.is_proc_running("ffmpeg")

    @staticmethod
    def is_proc_running(process_name):
        for proc in psutil.process_iter():
            if process_name in "".join(proc.cmdline()):
                return True
        return False

    @staticmethod
    def stop_proc(process_name):
        for proc in psutil.process_iter():
            if process_name in "".join(proc.cmdline()):
                proc.terminate()
                print("Terminated process: " + process_name)

# register SIGTERM handlers to enable graceful shutdown of recording
signal.signal(signal.SIGINT, Handler.terminate_gracefully)
signal.signal(signal.SIGTERM, Handler.terminate_gracefully)

httpd = HTTPServer( ('0.0.0.0', video_ready_port), Handler )
httpd.serve_forever()
