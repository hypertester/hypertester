# TCP SYN Scanning

SYN scan is another form of TCP scanning. This scan type is also known as "half-open scanning", because it never actually opens a full TCP connection. The port scanner generates a SYN packet. If the target port is open, it will respond with a SYN-ACK packet. The scanner host responds with an RST packet, closing the connection before the handshake is completed.[3] If the port is closed but unfiltered, the target will instantly respond with an RST packet.


