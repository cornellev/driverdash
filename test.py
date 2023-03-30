import socket
import time
import random

from argparse import ArgumentParser

def main():
    parser = ArgumentParser(
        description="Tests TCP transmission with iPhone app.")
    
    parser.add_argument("ip", help="IP address of the phone")
    parser.add_argument("--repetitions", "-r", metavar="n", type=int, default=1, required=False,
        help="Number of times to repeat each request")

    args = parser.parse_args()

    print("Sending payload to back server")
    # create the TCP socket object
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client_socket.connect((args.ip, 8080))
    # send a message to the server
    for _ in range(args.repetitions):
        message = '{{"voltage": {voltage}, "safety": {safety}, "rpm": {rpm}}}'.format(
            voltage=random.random() * 1000,
            safety=0 if random.random() < .5 else 1,
            rpm=random.randrange(0, 50000))
        print(message)
        client_socket.sendall(len(message).to_bytes(4, "little"))
        client_socket.sendall(message.encode())
        time.sleep(.5)
    client_socket.close()

    print("Sending payload to LORD server")
    # create the TCP socket object
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client_socket.connect((args.ip, 8082))
    message = r'{"latitude": 42.444288, "longitude": -76.483284, "speed": 0.0, "heading": 0.0}'
    print(message)
    client_socket.sendall(len(message).to_bytes(4, "little"))
    client_socket.sendall(message.encode())
    time.sleep(.5)
    message = r'{"acceleration": {"x": 0.167943, "y": -0.313749, "z": -1.009234}, "gyro":{"roll": -0.050956, "pitch": 0.0796, "yaw": 2.837746}}'
    print(message)
    client_socket.sendall(len(message).to_bytes(4, "little"))
    client_socket.sendall(message.encode())
    time.sleep(.5)
    client_socket.close()


if __name__ == "__main__":
    main()
