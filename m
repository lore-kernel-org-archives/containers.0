From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: [RFC] IO Controller
Date: Wed, 11 Mar 2009 21:56:45 -0400
Message-ID: <1236823015-4183-1-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: nauman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, mikew-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, fer
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org



Hi All,

Here is another posting for IO controller patches. Last time I had posted
RFC patches for an IO controller which did bio control per cgroup.

http://lkml.org/lkml/2008/11/6/227

One of the takeaway from the discussion in this thread was that let us
implement a common layer which contains the proportional weight scheduling
code which can be shared by all the IO schedulers.

Implementing IO controller will not cover the devices which don't use
IO schedulers but it should cover the common case.

There were more discussions regarding 2 level vs 1 level IO control at
following link.

https://lists.linux-foundation.org/pipermail/containers/2009-January/015402.html

So in the mean time we took the discussion off the list and spent time on
making the 1 level control apporoach work where majority of the proportional
weight control is shared by the four schedulers instead of each one having
to replicate the code. We make use of BFQ code for fair queuing as posted
by Paolo and Fabio here.

http://lkml.org/lkml/2008/11/11/148

Details about design and howto have been put in documentation patch.

I have done very basic testing of running 2 or 3 "dd" threads in different
cgroups. Wanted to get the patchset out for feedback/review before we dive
into more bug fixing, benchmarking, optimizations etc.

Your feedback/comments are welcome.

Patch series contains 10 patches. It should be compilable and bootable after
every patch. Intial 2 patches implement flat fair queuing (no cgroup
support) and make cfq to use that. Later patches introduce hierarchical
fair queuing support in elevator layer and modify other IO schdulers to use
that.

Thanks
Vivek
