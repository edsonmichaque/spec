package main

import (
	"github.com/danielgtaylor/openapi-cli-generator/cli"
	"github.com/edsonmichaque/buzi/openapi"
)

func main() {
	cli.Init(&cli.Config{
		AppName:   "buzi",
		EnvPrefix: "BUZI",
		Version:   "1.0.0",
	})

	// TODO: Add register commands here.
	openapi.YmlRegister(false)
	cli.Root.Execute()
}
