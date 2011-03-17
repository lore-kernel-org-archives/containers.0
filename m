From: "Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: scripts to simplify application checkpoint/restart testing
Date: Thu, 17 Mar 2011 10:00:10 -0500
Message-ID: <20110317150009.GA11388__5806.46742969311$1300374206$gmane$org@peq.hallyn.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="6sX45UoQRIJXqkqR"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, lxc-users <lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org


--6sX45UoQRIJXqkqR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Let me first off admit that I have not gotten checkpoint/restart
to work with the ckpt-v23-rc1-pids tree.  But hopefully this will
help make it easier to debug that.

Ideally (and eventually), the lxc toolsuite will be used for
checkpoint/restart.  However, c/r is too unflexible and lxc too
flexible, so for now I've just coded some scripts to create little
containers.  The start_job.sh script takes two arguments, a name for the
job, and the program to run.  It creates a container with private netns,
running an ssh server and a running your job in a screen session.  You
can checkpoint it with checkpoint.sh, and restart it with restart.sh.
kill_job.sh kills the job and cleans up the cgroup and other state.

You can get this from https://launchpad.net/~appcr/+archive/ppa,
or just put the attached scripts into /usr/bin.  They assume
nsexec, appcheckpoint, and apprestart exist (yes, bc 'restart'
is hijacked by upstart :( ).

The next time I can spend some time on c/r, I'll be using these
scripts to try and figure out why kernel isn't treating me
right.  I may go back to the rc1 (not '-pids') version.

-serge

PS - I did start on creating a 'lxc-cr'-like container template
to create checkpointable containers with lxc, but never quite got
that to work.  Perfecting that seemed inappropriate when
sys_checkpoint isn't working anyway.

--6sX45UoQRIJXqkqR
Content-Type: application/x-sh
Content-Disposition: attachment; filename="checkpoint.sh"
Content-Transfer-Encoding: quoted-printable

#!/bin/bash=0A=0Aif [ $# -lt 1 ] ; then=0A	echo "usage: $0 jobname"=0A	exit=
 1=0Afi=0A=0Ajobname=3D$1=0Acgroupdir=3D/cgroup/$jobname=0Avardir=3D/var/li=
b/crdemo/$jobname=0A=0Aif [ ! -d "$cgroupdir" ]; then=0A	echo "$cgroupdir d=
oes not exist"=0A	exit 1=0Afi=0Aif [ ! -d "$vardir" ]; then=0A	echo "$vardi=
r does not exist"=0A	exit 1=0Afi=0Apid=3D`head -1 $cgroupdir/tasks`=0Aecho =
FROZEN > $cgroupdir/freezer.state=0A=0Aecho "checkpoint -N -l $vardir/log $=
pid > $vardir/ckpt"=0A/usr/bin/appcheckpoint -N -l $vardir/log $pid > $vard=
ir/ckpt=0Aret=3D$?=0Aif [ $ret -ne 0 ]; then=0A	echo "checkpoint failed wit=
h return code $ret"=0A	echo "log says:"=0A	cat $vardir/log=0Aelse=0A	echo "=
checkpoint succeeded"=0A	kill -9 $pid=0Afi=0Asleep 1=0Aecho THAWED > $cgrou=
pdir/freezer.state=0Aexit $ret=0A
--6sX45UoQRIJXqkqR
Content-Type: application/x-sh
Content-Disposition: attachment; filename="jobinit.sh"
Content-Transfer-Encoding: quoted-printable

#!/bin/bash=0A=0Aif [ $$ !=3D 1 ]; then=0A	echo 'must be container init'=0A=
	exit 1=0Afi=0Ahostname $1=0A=0A#umount -a -t tmpfs > /tmp/a 2>&1=0A=0Avard=
ir=3D/var/lib/crdemo/$1=0Amkdir -p $vardir/tmp=0Amount --bind $vardir/tmp /=
tmp=0A=0A# Give screen its own private /var/run/screen=0Ascreendir=3D$vardi=
r/screen=0Amkdir $screendir=0Amount --bind $screendir /var/run/screen=0A=0A=
exec 0<&-=0Aexec 0</dev/null=0A=0Aexec 1>&-=0Aexec 1>nohup.out=0Aexec 2>&-=
=0Aexec 2>nohup.out=0A=0A#for f in `/bin/ls /proc/self/fd`; do=0A	#echo reo=
pening $f as $d=0A	#d=3D`readlink /proc/$$/fd/$f`=0A	#exec $f<&-=0A	#exec $=
f<$d=0A#done=0A=0Acgroupdir=3D/cgroup/$1=0Amkdir -p $cgroupdir=0Aecho $$  >=
 $cgroupdir/tasks=0A#mount -t proc proc /proc=0A#mount -t devpts -o newinst=
ance,ptmxmode=3D666 pts2 /dev/pts=0A=0Atouch $vardir/container_waiting=0A=
=0A# wait for parent to pass us our network device=0Awhile [ ! -f $vardir/d=
evready ]; do=0A	sleep 1=0Adone=0A=0Aa0=3D`head -2 $vardir/addr | tail -1`=
=0Ad1=3D`head -3 $vardir/addr | tail -1`=0Aa1=3D`head -4 $vardir/addr | tai=
l -1`=0Aip link set $d1 name eth0=0Aifconfig eth0 $a1 up=0Aroute add -host =
$a0 gateway $a1=0Aifconfig -a > /root/list=0A=0A/usr/sbin/sshd=0A=0Apid=3D$=
!=0Atouch $vardir/container_ready=0Awhile [ -d /proc/$pid ]; do=0A	sleep 20=
=0Adone=0Aecho "sshd (pid $pid) exited, container is now exiting"=0Aexit 0=
=0A
--6sX45UoQRIJXqkqR
Content-Type: application/x-sh
Content-Disposition: attachment; filename="kill_job.sh"
Content-Transfer-Encoding: quoted-printable

#!/bin/sh=0A=0Aif [ $# -lt 1 ]; then=0A	echo "Usage: $0 jobname"=0A	exit 1=
=0Afi=0A=0Ajobname=3D$1=0Avardir=3D"/var/lib/crdemo/$jobname"=0Acgroupdir=
=3D"/cgroup/$jobname"=0A=0At1=3D`head -1 /$cgroupdir/tasks`=0Akill -9 $t1=
=0Asleep 1=0Armdir $cgroupdir=0Arm -rf $vardir=0A=0Aecho "job $jobname is n=
ow cleaned up"=0A
--6sX45UoQRIJXqkqR
Content-Type: application/x-sh
Content-Disposition: attachment; filename="restart_real.sh"
Content-Transfer-Encoding: quoted-printable

#!/bin/bash=0Aif [ $# -lt 1 ]; then=0A	echo "usage: $0 <jobname>"=0A	exit 1=
=0Afi=0A=0Ajobname=3D$1=0Avardir=3D"/var/lib/crdemo/$jobname"=0Acgroupdir=
=3D"/cgroup/$jobname"=0Ascreendir=3D$vardir/screen=0A=0Aif [ ! -d "$vardir"=
 ]; then=0A	echo "$vardir does not exist"=0A	exit 1=0Afi=0A=0Aif [ ! -d "$c=
groupdir" ]; then=0A	echo "$cgroupdir does not exist"=0A	exit 1=0Afi=0A=0A#=
 uncomment the following line if restart doesn't have the -t option=0A#moun=
t -t devpts -o newinstance,ptmxmode=3D666 pts2 /dev/pts=0A=0A# remount /tmp=
 and /var/run/screen=0Amount --bind $vardir/tmp /tmp=0Amount --bind $screen=
dir /var/run/screen=0A=0Arm -f $vardir/rlog=0A# uncomment the following lin=
e if your kernel doesn't have chroot c/r patch=0A#cd hpl-2.0/bin/x86=0A# re=
move the '-t' if restart doesn't support it (and see comment above)=0Arm -f=
 $vardir/rlog=0A/usr/bin/apprestart -vd --mntns --mount-pty --pids -l $vard=
ir/rlog < $vardir/ckpt=0A=0A# use the following two lines instead if you wa=
nt to restart frozen (to debug)=0A# mkdir -p /cgroup/2=0A#restart -F /cgrou=
p/2 -t --pids -l $1/rlog < $1/ckpt=0A
--6sX45UoQRIJXqkqR
Content-Type: application/x-sh
Content-Disposition: attachment; filename="restart.sh"
Content-Transfer-Encoding: quoted-printable

#!/bin/bash=0A=0Aif [ $# -lt 1 ]; then=0A	echo "Usage: $0 <jobname>"=0A	exi=
t 1=0Afi=0A=0Ajobname=3D$1=0Aif [ ! -d /cgroup/$jobname ]; then=0A	echo "/c=
group/$jobname does not exist"=0A	exit 1=0Afi=0A=0A# move ourselves into th=
e child's cgroup=0Aecho $$ > /cgroup/$jobname/tasks=0Ansexec -m /usr/bin/re=
start_real.sh $*=0A
--6sX45UoQRIJXqkqR
Content-Type: application/x-sh
Content-Disposition: attachment; filename="start_job.sh"
Content-Transfer-Encoding: quoted-printable

#!/bin/bash=0A#=0A# serge=0A# requires you to ssh-keygen and put id_rsa.pub=
 into=0A# .ssh/authorized_keys=0A=0Aif [ $# -lt 2 ]; then=0A	echo "Usage: $=
0 jobname program"=0A	exit 1=0Afi=0A=0Ajobname=3D$1=0Aprogram=3D$2=0A=0Avar=
dir=3D/var/lib/crdemo/$jobname=0Aif [ -d $vardir ]; then=0A	echo "$vardir e=
xists.  Please terminate existing jobs and rmdir"=0A	exit 1=0Afi=0Amkdir -p=
 $vardir=0Acp $program $vardir/=0A=0A# create addresses=0A# XXX TODO make t=
his play nicely with multiple jobs!=0Aip link add type veth=0Ad0=3Dveth0=0A=
d1=3Dveth1=0Aa0=3D10.50.1.1=0Aa1=3D10.50.1.2=0A=0Aifconfig $d0 $a0 up=0Aifc=
onfig $d1 $a1 up=0A=0Aecho $d0 > $vardir/addr=0Aecho $a0 >> $vardir/addr=0A=
echo $d1 >> $vardir/addr=0Aecho $a1 >> $vardir/addr=0A=0ACONTAINERINIT=3D/u=
sr/bin/jobinit.sh=0A=0Anohup nsexec -tncmpiu $CONTAINERINIT $jobname &=0Aec=
ho "Waiting for $vardir/container_waiting to be created..."=0Awhile [ ! -f =
$vardir/container_waiting ]; do=0A	echo -n '.'=0A	sleep 1=0Adone=0Apid=3D`h=
ead -1 /cgroup/$jobname/tasks`=0Aip link set $d1 netns $pid=0A=0Atouch $var=
dir/devready=0A=0Aecho "Waiting for $vardir/container_ready to be created..=
=2E"=0Awhile [ ! -f $vardir/container_ready ]; do =0A	echo -n '.'=0A	sleep =
1=0Adone=0A=0Aroute add -host $a1 gateway $a0=0A=0Aecho "$vardir/container_=
ready was created.  Ssh'ing into container to start $program"=0Assh root@$a=
1 screen -A -d -m -S $jobname $vardir/$program=0Aps -ef | grep -v grep | gr=
ep $program > /dev/null 2>&1=0Aret=3D$?=0Aecho "Waiting for $program to sta=
rt..."=0Awhile [ $ret -ne 0 ]; do=0A	echo -n '.'=0A	ps -ef | grep -v grep |=
 grep $program > /dev/null 2>&1=0A	ret=3D$?=0Adone=0Aecho "Program $program=
 started.  You can ssh to $a1 and 'screen -r'."=0A#echo "ssh to $a1 and scr=
een -r, make any changes you like, logout,"=0A#echo "then use /usr/bin/chec=
kpoint.sh, kill, use /bin/restart.sh"=0A#echo "and look for successful rest=
art"=0A
--6sX45UoQRIJXqkqR
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--6sX45UoQRIJXqkqR--
