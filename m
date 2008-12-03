From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 2/3] cgroups: add inactive subsystems to rootnode.root_list
Date: Wed, 03 Dec 2008 09:10:00 +0800
Message-ID: <4935DC68.5030109__22146.5938179337$1228266765$gmane$org@cn.fujitsu.com>
References: <492FC1BD.4010705@cn.fujitsu.com>	
	<6599ad830812011735i565087dfg7ebad01a1f0400ad@mail.gmail.com>	
	<4934AA53.4000308@cn.fujitsu.com>
	<6599ad830812021453m44e948b1p83f6e02aa7e9068@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830812021453m44e948b1p83f6e02aa7e9068-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

>>>> @@ -2522,6 +2522,7 @@ static void __init cgroup_init_subsys(struct cgroup_subsys *ss)
>>>>        printk(KERN_INFO "Initializing cgroup subsys %s\n", ss->name);
>>>>
>>>>        /* Create the top cgroup state for this subsystem */
>>>> +       list_add(&ss->sibling, &rootnode.root_list);
>>> This is wrong. cgroup_subsys.sibling is a member of the list of
>>> subsystems attached to a given root, and rootnode.root_list is a
>>> member of the list of hierarchies. Did you actually meant
>>> &rootnode.subsys_list?
>>>
>> I thought I corrected all the s/root_list/subsys_list/ in patch v2. :(
>>
>> If this patch makes sense, I'll fix it, otherwise we'll going to ask Andrew to drop it from -mm.
> 
> Looking at the existing code, it's not actually broken - but only by accident.
> 

Yes, since it's not broken, I didn't claim this patch as a bug fix that
should go into 2.6.28.

> We aim to add a link for each cgroup, which we do by finding the first
> subsystem in each hierarchy and adding a link for its cgroup, and then
> adding a link for dummytop if there weren't any subsystems in the
> inactive hierarchy.
> 
> But since rootnode.subsys_list is always empty, we always skip the
> inactive hierarchy in the main loop (if it has any subsystems), and
> always add the inactive hierarchy afterwards. So everything works out
> OK (all hierarchies do get linked), but it's horribly unreadable.
> 

I found this confusion when I was trying to understand this part of code.

> Having the subsys_list be correct for the inactive hierarchy is
> probably a good thing, so this patch should go ahead (once the typos
> is fixed).
> 

I'll fix it. :)
