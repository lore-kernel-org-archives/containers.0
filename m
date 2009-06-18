From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: cgroup attach/fork hooks consistency with the ns_cgroup
Date: Thu, 18 Jun 2009 20:36:12 +0200
Message-ID: <4A3A891C.8020305@free.fr>
References: <4A390D5D.5040702@free.fr> <20090617212614.GA26781@us.ibm.com>
	<6599ad830906171821v3c97f176y65bd4b7fa9a405e9@mail.gmail.com>
	<20090618134527.GA3186@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090618134527.GA3186-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Quoting Paul Menage (menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org):
>   
>> On Wed, Jun 17, 2009 at 2:26 PM, Serge E. Hallyn<serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
>>     
>>> The ns cgroup is really only good for preventing root in a container
>>> from escaping its cgroup-imposed limits.  The same can be done today
>>> using smack or selinux, and eventually will be possible using user
>>> namespaces.  Would anyone object to removing ns_cgroup?
>>>       
>> Sounds reasonable to me. It feels to me that there ought to be some
>> good way to integrate namespaces and cgroups, but I'm not quite sure
>> exactly how, and ns_cgroup sort of hovers in the "toy" category rather
>> than something very useful.
>>     
>
> So the question becomes: does the presence of the ns cgroup constitute
> an API?  Can we just yank it out?
>
> Daniel, AFAIK liblxc is the only thing that actually uses it.  Do
> you mind manually moving the container init into a new cgroup?
>   

It is not a big deal to manually create and attach to the cgroup and I 
would prefer to remove the ns_cgroup if that helps to keep the cgroup 
behaviour consistent.
But the behaviour will change, no ? I mean the ns_cgroup clones the 
cgroup parent so we inherit its values. If we remove the ns_cgroup, that 
won't happen and I will have to handle some specific cases. For example, 
cpuset.cpus and cpuset.mems won't be filled and I will not be able to 
attach until I set them, so I have to be aware of this control group in 
the code and copy the values from the parent. That's annoying, I tried 
to have the liblxc cgroup code generic so it supports any kind of cgroup :/

There isn't a rule saying that we will inherit the values set by the 
parent ? If it is case, maybe we can remove the ns_cgroup and fix the 
cpuset at the same time, no ?

By the way, Andrew complained when we changed the name of the ns_cgroup 
"node_<pid>" by "<pid>" that we don't have to change the api when 
something is in the kernel. IMO, he won't be happy if we remove the 
ns_cgroup :/
Maybe, we can first fix the ns_cgroup hook problem by moving the 
ns_cgroup_clone after cgroup_fork_callbacks and propose a cgroup related 
to the namespaces. When we activate this new cgroup that disables the 
ns_cgroup and we put this cgroup_namespace as default in the Kconfig, no ?

Thanks
-- Daniel
