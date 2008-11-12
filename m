From: Fabio Checconi <fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/3] BFQ I/O Scheduler (second take)
Date: Wed, 12 Nov 2008 13:38:49 +0100
Message-ID: <20081112123849.GA14817__37937.1639145122$1226493538$gmane$org@gandalf.sssup.it>
References: <20081111125148.GD9508@gandalf.sssup.it>
	<491A43E0.2080109@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <491A43E0.2080109-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

> From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> Date: Wed, Nov 12, 2008 10:48:00AM +0800
>
> CC: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
>     Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> 
...
> So this is another cgroup-aware block i/o controller. ;)
> 
> People are sending different proposals for bio controller. A summary
> on this can be found here:
> 	http://marc.info/?l=linux-kernel&m=121798534716673&w=2
> 
> And a new proposal sent by Vivek several days ago:
> 	http://lkml.org/lkml/2008/11/6/227
> 
> And there are some discussions about can we modify the elevator layer
> and create a common layer so we can provide group control for all
> the 4 io schedulers. (in the above mail thread)
> 
> You may share some ideas with us.
> 

  yes, BFQ is another block I/O controller, and the ongoing discussion
is very interesting, as the other patchsets proposed.

BFQ deals with hierarchical scheduling in the same way as the proposed
CFQ extensions do, and it does not handle the I/O traking issue, as we
considered it not belonging directly to the elevator layer.

Talking about what may be interesting from the controller POV, it supports
arbitrary hierarchies (not only two layers) and ioprio classes for cgroups.
It can be easily extended to support any I/O tracking mechanism and
per-device ioprio_class/ioprio (it's just about choosing a sane interface
for that).

The main reasons why we turned BFQ into a cgroup controller were:
  - the algorithm was quite easy to adapt, and in a hierarchical
    context the advantages of using WF2Q+ over RR are more relevant.
  - Being a new scheduler, we had some freedom experimenting with it.
  - Avi asked for it :)

I'd like to stress the fact that the I/O controller thing is _not_ the
main feature of BFQ.  At least at this point of its development, we are
more interested in understanding if the differences it introduces WRT
CFQ (namely, the mixed time-service domain approach, WF2Q+ scheduling,
the feedback on budget lengths, etc.) are of interest or not for the
comminity and/or are worth the effort of a new I/O scheduler.
