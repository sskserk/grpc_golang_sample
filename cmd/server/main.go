package main

import (
	context "context"
	"google.golang.org/grpc"
	"grpctst/internal/twit"
	"log"
	"net"
)

func main() {

	srv := new(ImplServiceServer) // create an instance of implementation

	grpcServer := grpc.NewServer() // create an instance of grpc server
	twit.RegisterMsgServiceServer(grpcServer, srv)

	lis, err := net.Listen("unix", "/tmp/echo_server.sock")
	if err != nil {
		log.Fatal(err)
	}
	defer lis.Close()

	grpcServer.Serve(lis)
}

// actual implementation of the server
type ImplServiceServer struct {
}

func (server *ImplServiceServer) EchoMessage(ctx context.Context, message *twit.Msg) (*twit.Msg, error) {

	responseMessage := twit.Msg{MessageBody: "Response:" + message.GetMessageBody()}
	return &responseMessage, nil
}
