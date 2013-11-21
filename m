From: Chen Gang <gang.chen.5i5j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Suggestion] kernel: cgroup: mount failure in LTP
	cgroup_regression_test.sh
Date: Thu, 21 Nov 2013 10:21:13 +0800
Message-ID: <528D6E19.4080100@gmail.com>
References: <527C9D9B.8090802@asianux.com>
	<20131120173549.GO28946@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20131120173549.GO28946-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Chen Gang <gang.chen-bOixZGp5f+dBDgjK7y7TUQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On 11/21/2013 01:35 AM, Tejun Heo wrote:
> Hello,
> 
> Sorry about the delay.
> 

Oh, No problem, every members time resources are expensive, thank you
for your reply.


> On Fri, Nov 08, 2013 at 04:15:23PM +0800, Chen Gang wrote:
>> After simplify, the related operation, environments and output are:
>>
>>   [root@gchenlinux tmp]# df -Th | grep cgroup
>>   tmpfs                             tmpfs    1001M     0 1001M   0% /sys/fs/cgroup
>>   [root@gchenlinux tmp]# lsof | grep cgroup | grep -v grep
>>   systemd       1          root    6r      DIR               0,18         0       5998 /sys/fs/cgroup/systemd/system
>>   [root@gchenlinux tmp]# cat /proc/cgroups 
>>   #subsys_name	hierarchy	num_cgroups	enabled
>>   cpuset	3	4	1
>>   cpu	4	35	1
>>   cpuacct	4	35	1
>>   freezer	5	4	1
>>   [root@gchenlinux tmp]# mkdir cgroup
>>   [root@gchenlinux tmp]# mount -t cgroup -o freezer,cpuacct xxx cgroup/
>>   mount: xxx already mounted or cgroup/ busy
>>
>> Is it real issue of cgroup? If it is, I will/should continue analyzing.
> 
> Hmmm... I'm a bit confused.  What is it testing?  "cat /proc/cgroup"
> is showing that freezer is already mounted and the kernel seems to
> have correctly refused to mount it in a different hierarchy.  What am
> I missing here?
> 

Hmm... I am not quit familiar about it, either, but at least I can
contact related LTP members (I guess they can make sure about it).


Excuse me, I am changing/finding new job, so I should not use Asianux
Corporation mail again.  And it seems I can not be focus on upstream
kernel as much as before.  :-(

But at least, I will/should continue providing some contributions (more
or less) to Public Open Source as volunteers. And for upstream kernel,
I plan to make 1-3 patches per month (mainly for cross compiling).

 - if can not get companies support, I can not provide enough time
   resource on upstream kernel (I have to get pay check for family).

 - New company may mainly focus on open source tool chains (not only
   kernel), so I will/should also provide some contributions to them
   (e.g. KVM, GCC ...).


At last, sorry again for I have to give up 10 patches per month for
upstream kernel.


Thanks.
-- 
Chen Gang
