From: Andrey Wagin <avagin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Staring with 3.14 devices.allow can't be opened in read-write mode
Date: Mon, 12 May 2014 15:10:12 +0400
Message-ID: <CANaxB-xUm3rJ-Cbp72q-rQJO5mZe1qK6qXsQM=vh0U8upJ44+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: libcg-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

Hello All,

I found the "devices.allow" file can't be opened in read-write mode on
the 3.14 kernel. I uses libcgroup, which opens devices.allow with
O_RDWR. This works fine before 3.14 and fails one 3.14. This files has
write-only permissions. I have tried to create a regular file with the
same permission and kernel allows to open it with O_RDWR.
So what do you think is it a problem, which must be fixed?

5136  stat("/sys/fs/cgroup/devices//vz-101/devices.allow",
{st_mode=S_IFREG|0200, st_size=0, ...}) = 0
5136  open("/sys/fs/cgroup/devices//vz-101/devices.allow",
O_RDONLY|O_CLOEXEC) = -1 EACCES (Permission denied)

Linux avagin-fc19-cr 3.14.0+ #294 SMP Fri Apr 11 20:02:26 MSK 2014
x86_64 x86_64 x86_64 GNU/Linux

----> 1 os.open("/sys/fs/cgroup/devices/devices.deny", os.O_RDWR)

OSError: [Errno 13] Permission denied: '/sys/fs/cgroup/devices/devices.deny'

[root@avagin-fc19-cr ~]# ls -l /sys/fs/cgroup/devices/devices.deny
--w------- 1 root root 0 May  7 15:16 /sys/fs/cgroup/devices/devices.deny


Linux localhost.localdomain 3.13.8-200.fc20.x86_64 #1 SMP Tue Apr 1
03:35:46 UTC 2014 x86_64 x86_64 x86_64 GNU/Linux

In [2]: os.open("/sys/fs/cgroup/devices/devices.deny", os.O_RDWR)
Out[2]: 5

[root@localhost avagin]# ls -l /sys/fs/cgroup/devices/devices.deny
--w------- 1 root root 0 May  3 16:12 /sys/fs/cgroup/devices/devices.deny

Thanks,
Andrey
