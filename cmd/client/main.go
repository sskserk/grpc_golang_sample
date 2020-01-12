package main

import (
	"context"
	"google.golang.org/grpc"
	"grpctst/internal/twit"
	"log"
	"time"
)

func main() {
	requestMessage := twit.Msg{MessageBody: "SomeMessage"}

	conn, err := grpc.Dial("passthrough:///unix:///tmp/echo_server.sock", grpc.WithInsecure())
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()

	client := twit.NewMsgServiceClient(conn)

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	responseMessage, err := client.EchoMessage(ctx, &requestMessage)
	if err != nil {
		log.Fatal(err)
	}

	log.Println("Response message", responseMessage)
}
