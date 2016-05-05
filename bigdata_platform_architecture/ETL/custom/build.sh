#!/bin/bash
$JAVA_HOME/bin/javac -cp $(hadoop classpath) -d . CustomMultiOutputFormat.java
$JAVA_HOME/bin/jar cvf custom.jar com/custom/CustomMultiOutputFormat.class


