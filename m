From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: cgroup attach/fork hooks consistency with the ns_cgroup
Date: Fri, 19 Jun 2009 08:59:40 -0500
Message-ID: <20090619135940.GA22381@us.ibm.com>
References: <4A390D5D.5040702@free.fr> <20090617212614.GA26781@us.ibm.com>
	<6599ad830906171821v3c97f176y65bd4b7fa9a405e9@mail.gmail.com>
	<20090618134527.GA3186@us.ibm.com> <4A3A891C.8020305@free.fr>
	<6599ad830906181141w1669d154j22277070ae221a76@mail.gmail.com>
	<4A3A9ECD.9040908@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A3A9ECD.9040908-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
> Paul Menage wrote:
>> On Thu, Jun 18, 2009 at 11:36 AM, Daniel Lezcano<daniel.lezcano-GANU6spQydw@public.gmane.org> wrote:
>>   
>>> There isn't a rule saying that we will inherit the values set by the parent
>>> ? If it is case, maybe we can remove the ns_cgroup and fix the cpuset at the
>>> same time, no ?
>>>     
>>
>> There's no rule either way, but there is the backward-compatibility
>> aspects of cpusets.
>>
>> One way around that would be to add a "cgroup.clone_children" control
>> file - if you write 1 to it (it defaults to 0) then all mkdir
>> operations do a clone (i.e. pre-populate the child with appropriate
>> defaults even if that's not the normal behaviour for the subsystem.
>> That would avoid compatibility issues.
>>   
>
> Yes, that sounds good.
>>> Maybe, we can first fix the ns_cgroup hook problem by moving the
>>> ns_cgroup_clone after cgroup_fork_callbacks
>>>     
>>
>>  You mean fork the task into the parent cgroup, then clone the new
>> cgroup and reattach to the new cgroup? That could work, although I'm
>> not sure whether it would be bad to have the new task briefly
>> appearing in the parent cgroups.
>>   
> I tried the following patch:

I think the patch should be fine.

-serge

> Index: linux-2.6/kernel/fork.c
> ===================================================================
> --- linux-2.6.orig/kernel/fork.c
> +++ linux-2.6/kernel/fork.c
> @@ -1150,12 +1150,6 @@ static struct task_struct *copy_process(
>        if (clone_flags & CLONE_THREAD)
>                p->tgid = current->tgid;
>
> -       if (current->nsproxy != p->nsproxy) {
> -               retval = ns_cgroup_clone(p, pid);
> -               if (retval)
> -                       goto bad_fork_free_graph;
> -       }
> -
>        p->set_child_tid = (clone_flags & CLONE_CHILD_SETTID) ?  
> child_tidptr : NULL;
>        /*
>         * Clear TID on mm_release()?
> @@ -1204,6 +1198,12 @@ static struct task_struct *copy_process(
>        if (retval)
>                goto bad_fork_free_graph;
>
> +       if (current->nsproxy != p->nsproxy) {
> +               retval = ns_cgroup_clone(p, pid);
> +               if (retval)
> +                       goto bad_fork_cgroup_callbacks;
> +       }
> +
>        /* Need tasklist lock for parent etc handling! */
>        write_lock_irq(&tasklist_lock);
>
> That seems to fix the inconsistency problem but maybe I am missing  
> something...
> Excepting kernel race condition in the copy_process function I may have  
> missed, I don't see the difference with a program forking and adding the  
> task in the child cgroup (or the child process adds itself right after  
> the fork), the child will briefly appear to the parent cgroup, no ?
>
>  -- Daniel
>
>   
