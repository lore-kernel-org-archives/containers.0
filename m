From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: cgroup attach/fork hooks consistency with the ns_cgroup
Date: Wed, 17 Jun 2009 16:26:14 -0500
Message-ID: <20090617212614.GA26781@us.ibm.com>
References: <4A390D5D.5040702@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4A390D5D.5040702-GANU6spQydw@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
> Hi,
>
> I noticed two different behaviours, the second one looks weird for me:
>
>  1) when the cgroup is manually created:
> 	mkdir /cgroup/foo
> 	echo $$ > /cgroup/foo/tasks
>
>  only the "attach" callback is called as expected.
>
>  2) when the cgroup is automatically created via the ns_cgroup with the  
> clone function and the namespace flags,
>
>   the "attach" *and* the "fork" callbacks are called.
>
>
> IMHO, these two different behaviours look inconsistent. Won't this lead  
> to some problems or a specific code to handle both cases if a cgroup is  
> using the fork and the attach hooks ?
>
> For example, let's imagine we create a control group which shows the  
> number of tasks running. We have a global atomic and we display its  
> value in the cgroupfs.
>
> When a task attaches to the cgroup, we do atomic_inc in the attach  
> callback. For all its child, the fork hook will do atomic_inc and exit  
> hook will do atomic_dec.
>
> If we create the cgroup manually like the case 1) that works. But if we  
> use the control group with the ns_cgroup the task counter will be set to  
> 2 for the first tasks entering the cgroup because the attach callback  
> will increment the counter and the fork callback will increment it again.
>
> In attachment a source code to illustrate the example.
>
> Shouldn't the ns_cgroup_clone be called after the cgroup_fork_callbacks  
> in copy_process function ? So we don't call the fork callback for the  
> first tasks and we keep the consistency ?

The ns cgroup is really only good for preventing root in a container
from escaping its cgroup-imposed limits.  The same can be done today
using smack or selinux, and eventually will be possible using user
namespaces.  Would anyone object to removing ns_cgroup?

It won't just remove kernel/ns_cgroup.c, but some subtle code in
fork.c, nsproxy.c, and of course cgroup.c as well.

There admittedly is minute convenience gain in not having to
manually create a new cgroup and attach a cloned child to it, but
that wasn't the intent of the cgroup.

-serge
