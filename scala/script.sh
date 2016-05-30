#!/bin/bash
exec scala "$0" "$@"
!#
object HelloWorld extends App {
	println("Hello, World!")
}
HelloWorld.main(args)
