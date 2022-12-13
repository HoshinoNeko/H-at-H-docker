#!/bin/sh

kill_jar() {
  echo 'Received TERM'
  pkill java
  wait "$(ps -ef | pgrep java)"
  echo 'Process finished'
  delete_route
}

add_route() {
	echo "Adding route"
	ip rule add from 127.0.0.1/8 iif lo table 543
	ip route add local 0.0.0.0/0 dev lo table 543
	ip -6 rule add from ::1/128 iif lo table 543
	ip -6 route add local ::/0 dev lo table 543
	echo "Route added"
}

delete_route() {
	echo "Deleting route"
	ip rule add from 127.0.0.1/8 iif lo table 543
	ip route add local 0.0.0.0/0 dev lo table 543
	ip -6 rule add from ::1/128 iif lo table 543
	ip -6 route add local ::/0 dev lo table 543
	echo "Route deleted"
}

if [ $HatH_KEY ]
	then
		echo -n "${HatH_KEY}" > /hath/data/data/client_login
	else
		if [ ! -f /hath/data/data/client_login ]; then
		echo "Login not found, try specify the HatH_KEY arg, exiting......"
		exit 1
		fi
fi

add_route

./go-mmproxy -4 127.0.0.1:443 -l 127.0.0.1:3000 &

trap 'kill_jar' TERM INT KILL
java $JAVA_OPTS -jar HentaiAtHome.jar $HatH_ARGS $HatH_OPTS  &

wait $!
