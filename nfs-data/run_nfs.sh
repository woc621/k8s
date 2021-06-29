#!/bin/bash
function start()
{
  for i in "$@";do
	  echo "$i *(rw,fsid=0,insecure,no_root_squash)">>/etc/exports
	  /bin/cp /tmp/index.html $i/
	  chmod 644 $i/index.html
	  echo "serving $i"
  done
  /usr/sbin/rpcinfo 127.0.0.1 > /dev/null; s=$?
  if [  $s -ne 0 ]; then
	  echo "starting rpcbind"
	  /usr/sbin/rpcbind -w
  fi
  mount -t nfsd nfds /proc/fs/nfsd
  /usr/sbin/rpc.mountd -N 2 -V 3 -N 4 -N 4.1
  /usr/sbin/exportfs -r
  /usr/sbin/rpc.nfsd -G 10 -N 2 -V 3 -N 4 -N 4.1 2
  /usr/sbin/rpc.statd --no-notify
  echo "nfs started"
}
trap stop TERM
start "$@"
# Ugly hack to do nothing and wait for SIGTERM
while true; do
  sleep 5
done
