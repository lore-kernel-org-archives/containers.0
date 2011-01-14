From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: kernel BUG at fs/dcache.c:1363 (from cgroup)
Date: Fri, 14 Jan 2011 13:29:34 +0800
Message-ID: <4D2FDF3E.5030309__8820.48330172456$1294983091$gmane$org@cn.fujitsu.com>
References: <4D2FD771.9040301@cn.fujitsu.com>
	<20110114051453.GY19804@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110114051453.GY19804-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Nick Piggin <npiggin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Al Viro wrote:
> On Fri, Jan 14, 2011 at 12:56:17PM +0800, Li Zefan wrote:
>> Just mount the cgroupfs:
>>
>> # mount -t cgroup -o cpuset xxx /mnt
>> (oops!!)
>>
>> The bug is caused by:
>>
>> =========
>> commit 0df6a63f8735a7c8a877878bc215d4312e41ef81
>> Author: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
>> Date:   Tue Dec 21 13:29:29 2010 -0500
>>
>>     switch cgroup
>>     
>>     switching it to s_d_op allows to kill the cgroup_lookup() kludge.
>>     
>>     Signed-off-by: Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
>> =========
>>
>> This line:
>>
>> +       sb->s_d_op = &cgroup_dops;
> 
> Oh, crap...  Right, it's using simple_lookup().  Let me check if anything
> else might be stepping on that.
> 
> Umm...  There's a very strange codepath in btrfs that also might.
> Interesting.  Fix for cgroup, AFAICS, should be this:
> 

patch tested. thanks!
