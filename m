From: MALATTAR <mouhannad.alattar-jI/kxupzh7HSLaPbPq81kw@public.gmane.org>
Subject: cannot make ssh connection between host to container
Date: Fri, 12 Nov 2010 16:15:56 +0100
Message-ID: <4CDD5A2C.8040302@univ-fcomte.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi all,
I tried to make ssh connection between my host (ubuntu 10.10) and lxc =

(fedora 12) but i did not succeeded.
I am using lxc-start -n dora1 command to start the container and =

lxc-console -n dora1 to get a shell in it.
the configuration file of the container like this:
lxc.utsname =3D dora1
lxc.tty =3D 4
lxc.network.type =3D veth
lxc.network.flags =3D up
lxc.network.link =3D br-node1
lxc.network.name =3D eth0
lxc.network.mtu =3D 1500
lxc.network.ipv4 =3D 10.0.0.1/24
lxc.network.hwaddr =3D 12:DA:00:4B:54:45
lxc.rootfs =3D /lxc/rootfs.fedora
lxc.mount =3D /lxc/fstab.fedora
lxc.cgroup.devices.deny =3D a
# /dev/null and zero
lxc.cgroup.devices.allow =3D c 1:3 rwm
lxc.cgroup.devices.allow =3D c 1:5 rwm
# consoles
lxc.cgroup.devices.allow =3D c 5:1 rwm
lxc.cgroup.devices.allow =3D c 5:0 rwm
lxc.cgroup.devices.allow =3D c 4:0 rwm
lxc.cgroup.devices.allow =3D c 4:1 rwm
# /dev/{,u}random
lxc.cgroup.devices.allow =3D c 1:9 rwm
lxc.cgroup.devices.allow =3D c 1:8 rwm
# /dev/pts/* - pts namespaces are "coming soon"
lxc.cgroup.devices.allow =3D c 136:* rwm
lxc.cgroup.devices.allow =3D c 5:2 rwm
# rtc
lxc.cgroup.devices.allow =3D c 254:0 rwm
lxc.pts=3D1

I followed the tutorial at: =

http://www.ibm.com/developerworks/linux/library/l-lxc-containers/
in order to created a bridge between eth0 in my host and the container:
brctl addbr br-node1
ifconfig br-node1 "myHostIP" up
brctl addif br-node1 eth0
ifconfig eth0 0.0.0.0 promisc up

i read the discussion "Unable to SSH to the containers" in lxc-users =

mailing list.
But i did not arrive to make the connection.
Also making ssh localhost in a container shell will ask for a password =

but the shell will be freezed....and does not return any thing...
Any idea to solve this problem?
a+

-- =

MAlATTAR
Doctorant =E0 L=92UFR Sciences,Techniques et Gestion de l=92Industrie
