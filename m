From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [Suggestion] kernel: cgroup: mount failure in LTP
	cgroup_regression_test.sh
Date: Wed, 20 Nov 2013 12:35:49 -0500
Message-ID: <20131120173549.GO28946__49817.4048764215$1384968964$gmane$org@htj.dyndns.org>
References: <527C9D9B.8090802@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <527C9D9B.8090802-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello,

Sorry about the delay.

On Fri, Nov 08, 2013 at 04:15:23PM +0800, Chen Gang wrote:
> After simplify, the related operation, environments and output are:
> 
>   [root@gchenlinux tmp]# df -Th | grep cgroup
>   tmpfs                             tmpfs    1001M     0 1001M   0% /sys/fs/cgroup
>   [root@gchenlinux tmp]# lsof | grep cgroup | grep -v grep
>   systemd       1          root    6r      DIR               0,18         0       5998 /sys/fs/cgroup/systemd/system
>   [root@gchenlinux tmp]# cat /proc/cgroups 
>   #subsys_name	hierarchy	num_cgroups	enabled
>   cpuset	3	4	1
>   cpu	4	35	1
>   cpuacct	4	35	1
>   freezer	5	4	1
>   [root@gchenlinux tmp]# mkdir cgroup
>   [root@gchenlinux tmp]# mount -t cgroup -o freezer,cpuacct xxx cgroup/
>   mount: xxx already mounted or cgroup/ busy
> 
> Is it real issue of cgroup? If it is, I will/should continue analyzing.

Hmmm... I'm a bit confused.  What is it testing?  "cat /proc/cgroup"
is showing that freezer is already mounted and the kernel seems to
have correctly refused to mount it in a different hierarchy.  What am
I missing here?

Thanks.

-- 
tejun
