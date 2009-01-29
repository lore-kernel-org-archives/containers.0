From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Hierarchical grouping facility for IO controller (Re: [dm-devel]
	[PATCH 1/2] dm-ioband: I/O bandwidth controller v1.10.0: Source code
	and patch)
Date: Thu, 29 Jan 2009 12:39:55 +0900 (JST)
Message-ID: <20090129.123955.102562289.ryov__540.114651858126$1233200530$gmane$org@valinux.co.jp>
References: <20090122161218.GA28795@redhat.com>
	<20090123.191404.39168431.ryov@valinux.co.jp>
	<20090126162951.GI31802@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090126162951.GI31802-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, chrisw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Vivek,

This mail is about hierarchical grouping facility for IO controller.

> I think with the introduction of cgroup, IO scheduling has become now
> a hierarhical scheduling. Previously it was flat scheduling where there
> was only one level. Not there can be multiple levels and each level
> can have groups and queues. I don't think that we can break down
> hiearchical scheduling problem in two parts where top level part is moved
> into a module. It is something like saying that lets break out cpu group
> schedling into a separate module and it should not be part of kernel.
> 
> I think we need to implement this hiearchical IO scheduler in kernel which
> can schedule groups as well as end level io queues. (maintained by cfq,
> deadline, as, or noop).

I can implement the hierarchical grouping facility if really necessary
and the patch will be released after dm-ioband is merged into the
kernel. But do you believe the hierarchical grouping facility should
be implemented in the kernel, even if we can do it in the userland?
I think disk bandwidth control doesn't need responsiveness like the
CPU scheduler. I know it's possible to implement in the kernel, but
does it only make the kernel complex?

> > > - Task grouping logic
> > > 	- We already have the notion of cgroup where tasks can be grouped
> > > 	  in hierarhical manner. dm-ioband does not make full use of that and
> > > 	  comes up with own mechansim of grouping tasks (apart from cgroup).
> > > 	  And there are odd ways of specifying cgroup id which configuring the
> > > 	  dm-ioband device. I think once somebody has created the cgroup
> > > 	  hieararchy, any IO controller logic should be able to internally
> > > 	  read that hiearchy and provide control. There should not be need
> > > 	  of any other configuration utity on top of cgroup.
> > > 
> > > 	  My RFC patches had done that.
> > 
> > Dm-ioband can work with the bio-cgroup mechanism, which makes task groups
> > in manner of the cgroup, of course.
> > I already have a basic design to make dm-ioband support the cgroup
> > hierarchy. This should be started after the core code of bio-cgroup,
> > which helps trace each I/O requests, is merged in -mm tree.
> 
> bio-cgroup patches are fine because they provide us the capability to 
> map delayed writes to right cgroup. And it can be used by any IO
> controller. 
> 
> > And the reason dm-ioband uses cgroup id to specify a cgroup is that
> > the current cgroup infrastructure lacks features to manage resources
> > placed in the kernel modules.
> 
> Can you elaborate on that please? We have heard in the past that cgroup 
> does not give you enough flexibility but never got details.

The current cgroup framework can't manage resources dynamically. The
reason for using a cgroup ID to specify a cgroup is that it makes the
implementation quite simple. Although it is possible to implement the
function without using the ID, it makes the kernel complex due to the
function has to be implemented outside of the kernel.

Thanks,
Ryo Tsuruta
