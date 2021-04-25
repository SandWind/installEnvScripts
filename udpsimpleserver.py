import socket
import os
import threading
import time
PORT = 1060
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
network = '<broadcast>'

def get_ip():
    out = os.popen("ifconfig | grep 'inet'|grep -v '127.0.0.1' | cut -d: -f2 |  awk '{print $2}'").read()
    return out

def broadcastIp():
	message = get_ip()
	s.sendto(message.encode('utf-8'),(network, PORT))
	timer = threading.Timer(2.0,broadcastIp)
	timer.start()


if __name__ == "__main__":
	global timer
	timer = threading.Timer(2.0, broadcastIp)
	timer.start()