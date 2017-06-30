pushd /home/vagrant/openattic/backend
find * -name '*.pyc' | xargs rm
popd

if [[ "$(sudo docker images -q openattic-dev 2> /dev/null)" == "" ]]; then
  pushd /home/vagrant/openattic-docker/openattic-dev/opensuse_leap_42.2
  sudo docker build --network=host -t openattic-dev .
  popd
fi

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
