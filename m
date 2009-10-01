From: Rishikesh <risrajak-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: [libvirt]: Not able to login to container when cgroup is enabled
Date: Thu, 01 Oct 2009 15:39:35 +0530
Message-ID: <4AC47FDF.6080900__10413.4595407688$1254391840$gmane$org@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------020001080900070209030904"
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
To: libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: iranna.ankad-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, veillard-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, libcg-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

This is a multi-part message in MIME format.
--------------020001080900070209030904
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi All,

On F12 i was playing with libvirt support for container.
I am seeing two issue over here:
    1> Not able to create a container when start cgconfig services.
    2> When i stop cgconfig, then able to create a container, but seeing 
few error messages to libvirtd daemon.
    3> After creation of container through libvirt, i am not able to 
touch any file or directory.

Attached: vm1.xml , through which i created container. I referred 
following link:

http://libvirt.org/drvlxc.html
http://openvz.org/pipermail/devel/2008-September/014314.html

Detailed Bug Report:
When i create a container without starting "cgconfig" service, i am able 
to create but getting some error message in libvirtd daemon:

[root@mx3950 ~]# libvirtd
14:47:24.556: warning : qemudStartup:565 : Unable to create cgroup for 
driver: No such device or address
14:47:24.647: warning : lxcStartup:1462 : Unable to create cgroup for 
driver: No such device or address
libvir: Linux Container error : failed to connect to client socket: No 
such file or directory
libvir: Linux Container error : failed to connect to client socket: No 
such file or directory
libvir: Linux Container error : failed to connect to client socket: No 
such file or directory


But when i start cgconfig service, then i am not able to open console 
for my container. Below is the detailed steps which i executed.

[root@mx3950 ~]# /etc/init.d/cgconfig stop
Stopping cgconfig service:                                 [  OK  ]
[root@mx3950 ~]# virsh -c lxc:/// define vm1.xml
error: Failed to define domain from vm1.xml
error: operation failed: domain 'vm1' is already defined with uuid 
ef558ab3-54ea-5b95-205d-8c0096ae9a4f

[root@mx3950 ~]# virsh -c lxc:/// start vm1
Domain vm1 started

[root@mx3950 ~]# virsh -c lxc:/// console vm1
Connected to domain vm1
Escape character is ^]
sh-4.0# ps -ef
UID        PID  PPID  C STIME TTY          TIME CMD
root         1     0  0 15:23 pts/4    00:00:00 /bin/sh
root         4     1  0 15:23 pts/4    00:00:00 ps -ef
sh-4.0# touch rishi
touch: cannot touch `rishi': Permission denied
sh-4.0# exit
exit

[root@mx3950 ~]# /etc/init.d/cgconfig start
Starting cgconfig service:                                 [  OK  ]
[root@mx3950 ~]# virsh -c lxc:/// start vm1
Domain vm1 started

[root@mx3950 ~]# virsh -c lxc:/// console vm1
Connected to domain vm1
Escape character is ^]
15:24:12.869: error : vshRunConsole:77 : unable to open tty /dev/pts/3: 
No such file or directory


[root@mx3950 ~]#



Package List:
[root@mx3950 ~]# rpm -qa | grep -e libcgroup -e libvirt
libcgroup-0.34-2.fc12.x86_64
libvirt-0.7.1-1.fc12.x86_64
libvirt-client-0.7.1-1.fc12.x86_64
libvirt-python-0.7.1-1.fc12.x86_64
[root@mx3950 ~]# uname -a
Linux mx3950.in.ibm.com 2.6.31-14.fc12.x86_64 #1 SMP Tue Sep 15 03:48:57 
EDT 2009 x86_64 x86_64 x86_64 GNU/Linux


--------------020001080900070209030904
Content-Type: text/xml;
 name="vm1.xml"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vm1.xml"

<domain type='lxc'>
	<name>vm1</name>
	<memory>500000</memory>
	<os>
		<type>exe</type>
		<init>/bin/sh</init>
	</os>
	<vcpu>1</vcpu>
	<clock offset='utc'/>
	<on_poweroff>destroy</on_poweroff>
	<on_reboot>restart</on_reboot>
	<on_crash>destroy</on_crash>
	<devices>
		<emulator>/usr/libexec/libvirt_lxc</emulator>
		<interface type='network'>
			<source network='default'/>
		</interface>
		<console type='pty' />
	</devices>
</domain>


--------------020001080900070209030904
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
--------------020001080900070209030904--
