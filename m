From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] cgroup: memory.force_empty can make system slowdown
Date: Sun, 17 Aug 2008 11:10:08 +0800
Message-ID: <48A79690.1090600__49890.8845162534$1218942835$gmane$org@cn.fujitsu.com>
References: <48A63AD1.3010907@ds.jp.nec.com> <48A77BBB.7050305@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48A77BBB.7050305-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "IKEDA, Munehiro" <m-ikeda-MDRzhb/z0dd8UrSeD/g0lQ@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Li Zefan wrote:
> IKEDA, Munehiro wrote:
>> Cgroup's memory controller has a control file "memory.force_empty"
>> to reset usage account charged to a cgroup.  The account shouldn't
>> be reset if one or more processes are attached to the cgroup (at
>> least for memory controller, IMHO).  So mem_cgroup_force_empty()
>> is implemented to return -EBUSY and do nothing if so.
>> However, cgroup on hierarchy root faultily might be a exception.
>> Even if processes are attached to root cgroup (which is a "default"
>> cgroup for processes), forcing-empty can run by writing something to
>> memory.force_empty and it'll never end.
>>
> 
> I found this bug last week, and I've made patches to fix it, but then
> I was on vacation. I'll send the patches out soon.
> 
>> Following patch prevents this issue.
>>
>> This patch is for cgroup infrastructure code.  The issue can be
>> measured by modifying memory controller code also, namely to change
>> mem_cgroup_force_empty() to see CSS_ROOT bit of css->flags.
>> I believe cgroup->count approach like the patch below is rather
>> generic and reasonable, how does that sound?
>>
> 
> It's ok for the top_group's count to be 0 due to the top_cgroup hack.
> With this patch, the top cgroup's count will be always >0, even if it
> has no tasks in it, so writing to top_cgroup's force_empty will always
> return -EBUSY.
> 

I thought cgrp->css_sets will be empty when there are no tasks in the top cgroup,
but I was wrong, because init_css_set's refcount will always >0,
so cgroup_task_count() won't return 0 for the top cgroup:

# mount -t cgroup -o debug xxx /mnt
# mkdir /mnt/sub
# for pid in `cat /mnt/tasks`; do echo $pid > /mnt/sub/tasks; done
# cat /mnt/tasks
# cat /mnt/debug.taskcount
3
