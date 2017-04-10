for container in $(sudo docker ps -qa); do
  sudo docker rm -f $container
done

sudo docker run -t \
  -v /home/vagrant/openattic:/srv/openattic \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  -v /etc/ceph:/etc/ceph \
  --net=host \
  --privileged \
  --security-opt seccomp=unconfined \
  --stop-signal=SIGRTMIN+3 \
  --tmpfs /run/lock \
  openattic-dev
