From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: RFC: I/O bandwidth controller
Date: Fri, 08 Aug 2008 16:20:24 +0900 (JST)
Message-ID: <20080808.162024.189720323.ryov__41238.4688658223$1218180270$gmane$org@valinux.co.jp>
References: <1217870433.20260.101.camel@nimitz>
	<1217985189.3154.57.camel@sebastian.kern.oss.ntt.co.jp>
	<20080808.152119.43521725.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080808.152119.43521725.taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, uchida-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org, fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, ngupta-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

> >   - Implement a block layer resource controller. dm-ioband is a working
> > solution and feature rich but its dependency on the dm infrastructure is
> > likely to find opposition (the dm layer does not handle barriers
> > properly and the maximum size of I/O requests can be limited in some
> > cases). In such a case, we could either try to build a standalone
> > resource controller based on dm-ioband (which would probably hook into
> > generic_make_request) or try to come up with something new.
> 
> I doubt about the maximum size of I/O requests problem. You can't avoid
> this problem as far as you use device mapper modules with such a bad
> manner, even if the controller is implemented as a stand-alone controller.
> There is no limitation if you only use dm-ioband without any other device
> mapper modules.

The following is a part of source code where the limitation comes from.

dm-table.c: dm_set_device_limits()
        /*
         * Check if merge fn is supported.
         * If not we'll force DM to use PAGE_SIZE or
         * smaller I/O, just to be safe.
         */

        if (q->merge_bvec_fn && !ti->type->merge)
                rs->max_sectors =
                        min_not_zero(rs->max_sectors,
                                     (unsigned int) (PAGE_SIZE >> 9));

As far as I can find, In 2.6.27-rc1-mm1, Only some software RAID
drivers and pktcdvd driver define merge_bvec_fn().

Thanks,
Ryo Tsuruta
