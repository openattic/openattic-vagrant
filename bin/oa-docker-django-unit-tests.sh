sudo docker run -t \
  -v /home/vagrant/openattic:/srv/openattic \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  --net=host --privileged \
  --security-opt seccomp=unconfined \
  --stop-signal=SIGRTMIN+3 \
  --tmpfs /run/lock --rm \
  openattic-dev tests
