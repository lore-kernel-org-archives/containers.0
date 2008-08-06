From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: RFC: I/O bandwidth controller (was Re: Too many I/O controller
	patches)
Date: Wed, 06 Aug 2008 11:00:44 -0700
Message-ID: <1218045644.10907.93.camel__719.665984115814$1218046259$gmane$org@nimitz>
References: <20080804.175126.193692178.ryov@valinux.co.jp>
	<1217870433.20260.101.camel@nimitz>
	<1217985189.3154.57.camel@sebastian.kern.oss.ntt.co.jp>
	<4899D464.1070506@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4899D464.1070506-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org, Fernando Luis =?ISO-8859-1?Q?V=E1zquez?= Cao <fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 2008-08-06 at 22:12 +0530, Balbir Singh wrote:
> Would you like to split up IO into read and write IO. We know that read can be
> very latency sensitive when compared to writes. Should we consider them
> separately in the RFC?

I'd just suggest doing what is simplest and can be done in the smallest
amount of code.  As long as it is functional in some way and can be
extended to cover the end goal, I say keep it tiny.

> > Even in the non-hotplug case it would be nice if we could treat each
> > block I/O device as an independent resource, which means we could do
> > things like allocating I/O bandwidth on a per-device basis. As long as
> > performance is not compromised too much, adding some kind of basic
> > hotplug support to cgroups is probably worth it.
> 
> Won't that get too complex. What if the user has thousands of disks with several
> partitions on each?

I think what Fernando is suggesting is that we *allow* each disk to be
treated separately, not that we actually separate them out.  I agree
that with large disk count systems, it would get a bit nutty to deal
with I/O limits on each of them.  It would also probably be nutty for
some dude with two disks in his system to have to set (or care about)
individual limits.

I guess I'm just arguing that we should allow pretty arbitrary grouping
of block devices into these resource pools.

-- Dave
