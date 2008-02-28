From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [RFC] Prefixing cgroup generic control filenames with "cgroup."
Date: Thu, 28 Feb 2008 14:21:00 -0800
Message-ID: <20080228142100.2dce0e46.akpm@linux-foundation.org>
References: <6599ad830802281314s25c033d6tc021725ae28aef8d@mail.gmail.com>
	<20080228132142.4d4b1eef.akpm@linux-foundation.org>
	<6599ad830802281328q162d0585v3ac6b45a119a4a05@mail.gmail.com>
	<20080228134027.05b2aa87.akpm@linux-foundation.org>
	<6599ad830802281406t38e486d8g267df1873bc754c2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830802281406t38e486d8g267df1873bc754c2-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 28 Feb 2008 14:06:30 -0800
"Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:

> On Thu, Feb 28, 2008 at 1:40 PM, Andrew Morton
> <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
> >
> >  Maybe cgroups shouldn't be putting kernel-generated files in places where
> >  user-specified files appear?
> >
> 
> Well, that API (mixing control files and group directories in the same
> directory namespace) was inherited directly from cpusets.
> 
> It wouldn't be hard to throw that away and move all the user-created
> group directories into their own subdirectory, i.e. change the
> existing directory layout from something like:
> 
> /mnt/cgroup/
>     tasks
>     cpu.shares
>     memory.limit_in_bytes
>     memory.usage_in_bytes
>     user_created_groupname1/
>         tasks
>         cpu.shares
>         memory.limit_in_bytes
>         memory.usage_in_bytes
>     user_created_groupname2/
>         tasks
>         cpu.shares
>         memory.limit_in_bytes
>         memory.usage_in_bytes
> 
> to something like:
> 
> /mnt/cgroup/
>     tasks
>     cpu.shares
>     memory.limit_in_bytes
>     memory.usage_in_bytes
>     groups/
>         user_created_groupname1/
>             tasks
>             cpu.shares
>             memory.limit_in_bytes
>             memory.usage_in_bytes
>             groups/
>         user_created_groupname2/
>             tasks
>             cpu.shares
>             memory.limit_in_bytes
>             memory.usage_in_bytes
>             groups/

That looks nice.

> That would completely solve the namespace problem, at the cost of a
> little extra verbosity/inelegance for human users (I suspect
> programmatic users would prefer it), and lack of compatibility with
> 2.6.24. I'd also need to make the existing model a mount option so
> that we could keep compatibility with the cpusets filesystem API.

That doesn't.  It sounds like cpusets legacy has mucked us up here?

Could we do something like auto-prefixing user-created directories with a
fixed string so that there is no way in which the user can cause a
collision with kernel-created files?

I suppose that would break cpusets back-compatibility as well?  If so, we
could do the prefixing only for non-cpusets directories, but that's getting
a bit weird.

> >  (Am still thrashing around a bit here without an overview of the overall
> >  layout and naming).
> 
> Pretty much the same as cpusets, other than the additional
> kernel-generated files in each directory, as provided by the resource
> subsystems. So the same potential problem faced cpusets, but the fact
> that new cpuset features weren't being developed quickly meant the
> problem was less likely to actually bite people.

hm.  I guess that all the kernel-generated file names are known up-front
and that they are instantiated early, so if a user tried to create a cgroup
called "tasks", than that would just fail.

But, as you say, later addition of new kernel-created files might collide
with prior userspace installations.

So yet another option would be to promise to prefix all _future_
kernel-generated files with "kern_", and to change the implementation now
to reject any user-created files which start with "kern_".  hm.
