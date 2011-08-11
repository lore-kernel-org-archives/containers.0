From: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: cgroup information proc file format
Date: Thu, 11 Aug 2011 16:52:38 -0500
Message-ID: <20110811215238.GC17349@peqn>
References: <4E4441C3.5020603@free.fr> <4E4449F5.3010909@parallels.com>
	<4E444D96.7080206@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4E444D96.7080206-GANU6spQydw@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Balbir Singh1 <balbir.singh-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Daniel Lezcano (daniel.lezcano-GANU6spQydw@public.gmane.org):
> On 08/11/2011 11:30 PM, Glauber Costa wrote:
> > On 08/11/2011 05:55 PM, Daniel Lezcano wrote:
> >> Hi all,
> >>
> >> the cgroup cpuset and memory reduce access to a part of the resources on
> >> the system. Some applications use the /proc/cpuinfo and /proc/meminfo to
> >> allocate the resources. For instance, HPC jobs look at /proc/cpuinfo to
> >> fork the number of cpu found in this file either look at /proc/meminfo
> >> to allocate a big chunk of memory. Each process set the affinity on each
> >> cpu, which in case a subset of cpus is used, some affinity will fail.
> >>
> >> In the case of the container, the cgroup is used to reduce the memory or
> >> to assign a cpu to the container. Unfortunately, as this partitioning is
> >> not reflected in /proc, the different system tools (ps, top, free, ...)
> >> show a wrong information.
> >>
> >> I was wondering if that would make sense to create for the different
> >> cgroup subsystem, when it is relevant, a proc formatted file we can bind
> >> mount /proc.
> >>
> >> For example: /cgroup/memory.proc and /cgroup/cpuset.proc

I think it's a great idea.

-serge
