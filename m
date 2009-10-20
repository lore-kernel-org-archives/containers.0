From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] pidns: Fix a leak in /proc inodes and dentries
Date: Tue, 20 Oct 2009 13:58:34 +0200
Message-ID: <4ADDA5EA.2060200@fr.ibm.com>
References: <20091020041337.GA31623@us.ibm.com>
	<m1r5sywebv.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1r5sywebv.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: jack-+ZI9xUNit7I@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, mingo-X9Un+BFzKDI@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, andrea-Vyt77T80VFVWk0Htik3J/w@public.gmane.org, dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On 10/20/2009 12:27 PM, Eric W. Biederman wrote:
> Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:
> 
>> Fix a leak in /proc dentries and inodes with pid namespaces.
>>
>> This fix reverts the commit 7766755a2f249e7e0. The leak was reported by
>> Daniel Lezcano - see  http://lkml.org/lkml/2009/10/2/159.
>>
>> To summarize the thread, when container-init is terminated, it sets the
>> PF_EXITING flag and then zaps all the other processes in the container.
>> When those processes exit, they are expected to be reaped by the container-
>> init and as a part of reaping, the container-init should flush any /proc
>> dentries associated with the processes. But because the container-init is
>> itself exiting and the following PF_EXITING check, the dentires are not
>> flushed, resulting in leak in /proc inodes and dentries.
> 
> Acked-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

there's indeed a lot of progress. A run of our C/R testsuite (spawning and
killing a few thousands pidns) used to leak ~700MB of slab, it's now gone. 
thanks suka for spending time on this. 

but we still have some minor leaks. below are contents of /proc/slabinfo 
before and after the run, you will notice that in some cases, dangling refs 
of nsproxy and pid_namespace are still alive. I wonder if there are some 
cases when this can happen, else I'll try to reproduce it.

Cheers,

C. 

* slabinfo.qemu (i686)

pid_namespace          0      0     64   59    1 
nsproxy                0      0     48   78    1 
proc_inode_cache     193    193   4096    1    1 
dentry              6734   6734   4096    1    1 

pid_2                  0      0     88   44    1 
pid_namespace          0      0     64   59    1 
nsproxy                0      0     48   78    1 
proc_inode_cache       4      4   4096    1    1 
dentry             36112  36112   4096    1    1 

* slabinfo.a13.test.meiosys.com (ppc64)

pid_namespace          0      0   4096    1    1 
nsproxy                0      0     72   53    1 
proc_inode_cache     506    513   4096    1    1 
dentry              6269   6272    280   14    1 

pid_2                  1     28    136   28    1 
pid_namespace          1      1   4096    1    1 
nsproxy                0      0     72   53    1 
proc_inode_cache     486    498   4096    1    1 
dentry             49051  49448    280   14    1 


* slabinfo.f13.test.meiosys.com (ppc64)

pid_namespace          0      0   4096    1    1 
nsproxy                0      0     72   53    1 
proc_inode_cache     248    263   4096    1    1 
dentry              7359   7364    280   14    1 

pid_2                  0      0    136   28    1 
pid_namespace          0      0   4096    1    1 
nsproxy                0      0     72   53    1 
proc_inode_cache     240    240   4096    1    1 
dentry             50253  50666    280   14    1 


* slabinfo.r3-23.test.meiosys.com (x86_64)

pid_namespace          0      0   4096    1    1 
nsproxy                0      0     72   53    1 
proc_inode_cache     479    495   4096    1    1 
dentry              5614   5614    280   14    1 

pid_2                  1     28    136   28    1 
pid_namespace          1      1   4096    1    1 
nsproxy                0      0     72   53    1 
proc_inode_cache     576    576   4096    1    1 
dentry             52202  52444    280   14    1 


* slabinfo.r3-24.test.meiosys.com (x86_64)

pid_namespace          0      0   4096    1    1 
nsproxy                0      0     72   53    1 
proc_inode_cache     464    486   4096    1    1 
dentry              5698   5698    280   14    1 

pid_2                  0      0    136   28    1 
pid_namespace          0      0   4096    1    1 
nsproxy                0      0     72   53    1 
proc_inode_cache     448    448   4096    1    1 
dentry             51845  52164    280   14    1 


* slabinfo.r3-26.test.meiosys.com (i686)

pid_namespace          0      0     64   59    1 
nsproxy                0      0     48   78    1 
proc_inode_cache     449    466   4096    1    1 
dentry              5633   5633   4096    1    1 

pid_2                  0      0     88   44    1 
pid_namespace          0      0     64   59    1 
nsproxy                0      0     48   78    1 
proc_inode_cache     448    448   4096    1    1 
dentry             52039  52039   4096    1    1 


* slabinfo.linuz12 (s390x)

pid_namespace          0      0   2112    3    2 
nsproxy                0      0     48   77    1 
proc_inode_cache     725    798    640    6    1 
dentry              4340   4340    192   20    1 

pid_2                  1     30    128   30    1 
pid_namespace          1      3   2112    3    2 
nsproxy                1     77     48   77    1 
proc_inode_cache      74    180    640    6    1 
dentry             34511  36820    192   20    1 
