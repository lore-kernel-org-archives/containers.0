From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: [PATCH 1/9] I/O bandwidth controller and BIO tracking
Date: Fri, 02 Oct 2009 20:56:07 +0900 (JST)
Message-ID: <20091002.205607.193712402.ryov__28984.9297296771$1254484621$gmane$org@valinux.co.jp>
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
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org
List-Id: containers.vger.kernel.org

Hi all,

These are new releases of dm-ioband and blkio-cgroup. The major change
of these releases is that dm-ioband handles sync/async IO requests
separately and it solves write-startve-read issue pointed out by Vivek.
Thank you Vivek for your pointing out the issue.

  Subject: ioband: Writer starves reader even without competitors
  http://lkml.org/lkml/2009/9/15/478

Here is the test result. I did the same test as Vivek did, it reads
32MB files four times during a bufferd writer is running.

dm-ioband v1.14.0
file #   1, plain reading it took: 0.73 seconds
file #   2, plain reading it took: 0.78 seconds
file #   3, plain reading it took: 0.78 seconds
file #   4, plain reading it took: 0.94 seconds

dm-ioband v1.13.0
file #   1, plain reading it took: 14.27 seconds
file #   2, plain reading it took: 22.17 seconds
file #   3, plain reading it took: 12.31 seconds
file #   4, plain reading it took: 17.69 seconds

The summary of the changes are below:
dm-ioband v1.14.0
  - Handle sync/async IO requests separetely, it solves write-starve-read
    issue.
  - Allow it to compile against 2.6.32-rc1.
blkio-cgroup v13
  - Fix style issues caught by checkpatch.pl.
  - Allow it to compile against 2.6.32-rc1.

The list of the patches:
  [PATCH 1/9] I/O bandwidth controller and BIO tracking
  [PATCH 2/9] dm-ioband-1.14.0: All-in-one patch
  [PATCH 3/9] blkio-cgroup-v13: The new page_cgroup framework
  [PATCH 4/9] blkio-cgroup-v13: Refactoring io-context initialization
  [PATCH 5/9] blkio-cgroup-v13: The body of blkio-cgroup
  [PATCH 6/9] blkio-cgroup-v13: Page tracking hooks
  [PATCH 7/9] blkio-cgroup-v13: The document of blkio-cgroup
  [PATCH 8/9] blkio-cgroup-v13: Add a cgroup support to dm-ioband
  [PATCH 9/9] blkio-cgroup-v13: The document of a cgroup support for dm-ioband

About dm-ioband
  dm-ioband is an I/O bandwidth controller implemented as a
  device-mapper driver and can control bandwidth on per partition, per
  user, per process, per virtual machine (such as KVM or Xen) basis.

About blkio-cgruop
  blkio-cgroup is a block I/O tracking mechanism implemented on the
  cgroup memory subsystem. Using this feature the owners of any type
  of I/O can be determined. This allows dm-ioband to control block I/O
  bandwidth even when it is accepting delayed write requests.
  dm-ioband can find the cgroup of each request. It is also for
  possible that others working on I/O bandwidth throttling to use this
  functionality to control asynchronous I/O with a little enhancement.

Please visit our website, the patches and more information are available.
  Linux Block I/O Bandwidth Control Project
  http://sourceforge.net/apps/trac/ioband/

I'd like to get some feedbacks from the list. Any comments are
appreciated.

Thanks,
Ryo Tsuruta
