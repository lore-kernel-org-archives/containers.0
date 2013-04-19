From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: the NULL deref on umount in the 3.9.0-rc7 kernel
Date: Fri, 19 Apr 2013 11:22:48 +0800
Message-ID: <5170B888.10304__21411.2191148617$1366341833$gmane$org@huawei.com>
References: <516FDB00.7070605@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <516FDB00.7070605-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: alexey.kodanev-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 2013/4/18 19:37, alexey.kodanev-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org wrote:
> Hi All
> 
> I would like to report the NULL deref on umount. Tested it in linux kernel 3.7.10 and it's still in the 3.9.0-rc7.
> /
> Test-case description:
> Mount cgroup filesystem with xattr option and create inside root cgroup another hierarchy.
> Then set extended attribute to any files within root hierarchy or sub hierarchie.
> Then remove (rmdir) sub hierarchy and call umount cgroup filesystem. Afterthat, umount crash the kernel.
> 
> Also, if you don't remove sub hierarchy (steps 1.4 & 2.9 in examples below), calling umount will produce nothing except that cgroup filesystem will be unmounted (no cgroup files in the directory) but with error: cgroups continue working, while call mount again to get control access to running cgroups will produce error, such as filesystem is already mounted, but in /proc/mounts you don't have such mount point. And there is no way to get control access back to the running cgroups, except for reboot.
> 
> Here are some manual methods which will reproduce Linux crash.
> 
> 1. One way to reproduce this fault:
> 
>     1.1% mount -t cgroup cgroot_test -o xattr /sys/fs/cgroup
>     1.2% mkdir /sys/fs/cgroup/test_subsys
>     1.3% setfattr -n trusted.value -v test_value /sys/fs/cgroup/tasks
>     1.4% rmdir /sys/fs/cgroup/test_subsys
>     1.5% umount cgroot_test
> 

Thanks for the report!

A fix will be followed soon.
