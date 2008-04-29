From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [Devel] Re: [RFC][v2][patch 0/12][CFQ-cgroup]Yet another I/O
	bandwidth controlling subsystem for CGroups based on CFQ
Date: Tue, 29 Apr 2008 09:44:38 +0900 (JST)
Message-ID: <20080429.094438.48502686.ryov__36020.3455704779$1209430012$gmane$org@valinux.co.jp>
References: <005d01c89559$9e538200$dafa8600$@jp.nec.com>
	<20080425.185444.115924172.ryov@valinux.co.jp>
	<20080425213702.GL19845@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080425213702.GL19845-N26foeg2n7CSQxDm3FYtNwe+0vtP5+jfMa5aj3AfGnc@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vtaras-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, tom-sugawara-LYU95VJlayp8UrSeD/g0lQ@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Florian,

> Here are a few results.

Thank you very much.

> What i found surprising is that Satoshis scheduler has
> about twice of the io count...

Of my previous results, Satoshi's scheduler has about twice of the io
count on the write test, but both io counts on the read test are
nearly the same.

Here are another results. The test procedure is as follows:
  o Prepare 3 partitions sdc2, sdc3 and sdc4.
  o Run 50 processes for sdc2, 100 processes for sdc3 and 150 processes
    for sdc4. Apply I/O loads in inverse to the priority level.
  o Each process issuing random read/write direct I/O with 4KB data.
  o Count up the number of I/Os which have done in 60 seconds.

               The number of I/Os (percentage to total I/Os)
   -------------------------------------------------------------------
  | partition       |    sdc2     |    sdc3     |    sdc4     | total |
  | processes       |     50      |    100      |    150      |  I/Os |
  |-----------------+-------------+-------------+-------------|-------|
  | Normal          |  2281(18%)  |  4287(34%)  |  6005(48%)  | 12573 |
  |-----------------+-------------+-------------+-------------+-------|
  | Vasily's sched. |             |             |             |       |
  | cgroup priority |  7(highest) |     4       |  0(lowest)  |       |
  |                 |  3713(24%)  |  6587(42%)  |  5354(34%)  | 15654 |
  |-----------------+-------------+-------------+-------------+-------|
  | Satoshi's sched.|             |             |             |       |
  | cgroup priority |  0(highest) |     4       |  7(lowest)  |       |
  |                 |  5399(42%)  |  6506(50%)  |  1034( 8%)  | 12939 |
   -------------------------------------------------------------------

Satoshi's scheduler suppressed the I/O to the lowest priority
partition better than Vasily's one, but Vasily's scheduler got the
highest total I/Os.

Thanks,
Ryo Tsuruta
