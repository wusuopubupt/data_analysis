#!/bin/bash
# refer: http://scala-lang.org/documentation/getting-started.html

exec scala "$0" "$@"
!#
object HelloWorld extends App {
	println("Hello, World!")
}
HelloWorld.main(args)
