package main

import (
	"github.com/danielgtaylor/openapi-cli-generator/cli"
)

func main() {
	cli.Init(&cli.Config{
		AppName:   "buzi",
		EnvPrefix: "BUZI",
		Version:   "1.0.0",
	})

	// TODO: Add register commands here.

	cli.Root.Execute()
}
