From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] cgroup: fix a race condition in manipulating tsk->cg_list
Date: Thu, 17 Apr 2008 13:10:33 +0800
Message-ID: <4806DBC9.3090607__39438.4763123982$1208414077$gmane$org@cn.fujitsu.com>
References: <4806C5EB.3040102@cn.fujitsu.com>	<20080416211144.a38f6fc0.akpm@linux-foundation.org>	<6599ad830804162117w14364b7cg20d3694ffdfeb867@mail.gmail.com>
	<20080416215907.63d71409.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080416215907.63d71409.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Andrew Morton wrote:
> On Wed, 16 Apr 2008 21:17:34 -0700 "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:
> 
>> On Wed, Apr 16, 2008 at 9:11 PM, Andrew Morton
>> <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
>>>  I don't fully understand the race.  Both paths hold css_set_lock.
>>>
>>>  Can you describe it in more detail please?
>> Task A starts exiting, passes the check for unlinking current->cg_list.
> 
> So cgroup_exit() sees !list_empty(tsk->cg_list)
> 

cgroup_exit() sees list_empty(tsk->cg_list), then cgroup_enable_task_cg_list()
links the task to the list, and then the task exited, so the list entry won't
get deleted.

> And the list_del() sets tsk->cg_list to LIST_POISON[12], which still means
> !list_empty().  Or we remove that debugging code and avoid writing to
> tsk->cg_list, and it _still_ is !list_empty().
> 
>> Before it completely exits task B does the very first
>> cgroup_iter_begin() call (via reading a cgroups tasks file) which
>> links all tasks in to their css_set objects via tsk->cg_list.
> 
> But it won't link this task, because it's !list_empty().
> 
>> Then task A finishes exiting and is freed, but doesn't unlink from the cg_list.
>>
>>>  afacit the task at *p could set PF_EXITING immediately after this code has
>>>  tested PF_EXITING and then the task at *p could proceed until we hit the
>>>  same race (whatever that is).
>> The important fact there is that the task sets PF_EXITING *before* it
>> checks whether it needs to unlink from current->cg_list.
>>
>> Paul
> 
> 
