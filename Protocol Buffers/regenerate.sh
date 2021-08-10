#/bin/bash

protoc --grpc-swift_out=. --swift_out=. guest_os_service.proto

