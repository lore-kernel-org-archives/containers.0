From: "Mukesh G" <mukgbv-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Devel] Re: Write Error: No space left on device
Date: Wed, 17 Sep 2008 18:27:09 +0530
Message-ID: <c7704c490809170557o21330ceaoeca5193add14c6d4@mail.gmail.com>
References: <c7704c490809050541v2df520f9ja9edc4582ee1199f@mail.gmail.com>
	<20080905080008.bf9748ab.pj@sgi.com>
	<c7704c490809150455r3376db54g8d37aba6670500a9@mail.gmail.com>
	<6599ad830809151726t4ff6082dsfda259dccd503415@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830809151726t4ff6082dsfda259dccd503415-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi
 Thanks for the help... I got cpu, memory cgroups at least mounted... I got
a basic task (my shell) assigned to cpu cgroup, memory cgroup

mount -t cgroup -o cpu none /container/cpu
mount -t cgroup -o memory none /container/memory
mount -t cgroup -o cpuset none /container/cpuset

Each of the sub-directories have files that can be modified for a designated
purpose....

The questions that I am now trying to resolve

a)Definition of cpu.shares?
   the default value is 1024. What is the max? What is the relation b/w cpu
cores, freq of the cores etc...? What is 1 cpu share worth?
b) What is the relation between cpuset.cpu* values and cpu cgroup?
c) What is the relation between cpuset.mem* values and memory cgroup?

Thanks in advance

Mukesh

On Tue, Sep 16, 2008 at 5:56 AM, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:

> Hi Mukesh,
>
> You should either:
>
> - mount with just the cgroup subsystems that you care about (e.g.
> "-ocpu,memory")
>
> - set the "cpuset.cpus" and "cpuset.mems" files in the child cgroup to
> be equal to those of the parent (root) cgroup.
>
> Paul
>
> On Mon, Sep 15, 2008 at 4:55 AM, Mukesh G <mukgbv-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > Hi Paul,
> >     How do I determine the no of memory nodes in shared systems (E.g: x86
> > based systems)? How do you define a memory node in the context of the
> shared
> > systems?
> >
> > I figured that I need to increase the memory nodes but unable to do so...
> >
> > Thanks
> >
> > Mukesh
> >
> >
> > On Fri, Sep 5, 2008 at 6:30 PM, Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org> wrote:
> >
> >> Mukesh wrote:
> >> > "Write Error: No space left on device".
> >>
> >> Search for
> >>
> >>     ENOSPC
> >>
> >> on the (brand new) cpuset(7) man page, such as at:
> >>
> >>     ftp://oss.sgi.com/projects/cpusets/download/cpuset.7
> >>
> >> --
> >>                  I won't rest till it's the best ...
> >>                  Programmer, Linux Scalability
> >>                  Paul Jackson <pj-sJ/iWh9BUns@public.gmane.org> 1.940.382.4214
> >>
> > _______________________________________________
> > Containers mailing list
> > Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> > https://lists.linux-foundation.org/mailman/listinfo/containers
> >
> > _______________________________________________
> > Devel mailing list
> > Devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
> > https://openvz.org/mailman/listinfo/devel
> >
>
