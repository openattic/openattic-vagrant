# TODO destroy ceph cluster if exists

for i in 1 2 3; do
  ssh node$i 'sudo rm /etc/salt/pki/minion/minion_master.pub'
  ssh node$i 'sudo systemctl restart salt-minion'
done

sudo docker run -t \
  -v /home/vagrant/openattic:/srv/openattic \
  -v /home/vagrant/DeepSea:/srv/deepsea \
  -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
  -v /etc/ceph:/etc/ceph \
  --net=host \
  --privileged \
  --security-opt seccomp=unconfined \
  --stop-signal=SIGRTMIN+3 \
  --tmpfs /run/lock \
  openattic-dev
