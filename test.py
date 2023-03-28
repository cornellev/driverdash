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

    print("Sending payload to front server")
    # create the TCP socket object
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client_socket.connect((args.ip, 8081))
    # send a message to the server
    for _ in range(args.repetitions):
        message = '{{"throttle": {throttle}, "angle": {angle}, "tof": {tof}}}'.format(
            throttle=random.randrange(0, 100),
            angle=random.randrange(0, 359),
            tof=random.random())
        print(message)
        client_socket.sendall(len(message).to_bytes(4, "little"))
        client_socket.sendall(message.encode())
        time.sleep(.5)
    client_socket.close()

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


if __name__ == "__main__":
    main()
