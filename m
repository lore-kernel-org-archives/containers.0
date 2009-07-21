From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: [PATCH 1/9] I/O bandwidth controller and BIO tracking
Date: Tue, 21 Jul 2009 23:09:11 +0900 (JST)
Message-ID: <20090721.230911.193692312.ryov__3351.98684265396$1248185428$gmane$org@valinux.co.jp>
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
Cc: agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi all,

These are new releases of dm-ioband and blkio-cgroup. The major
changes of these releases are:
  - dm-ioband can be configured through the cgroup interface. The
    bandwidth can be assigned on a per cgroup per block device basis.
  - The event tracing is supported that helps in debugging and
    monitoring dm-ioband.
  - A document for blkio-cgroup is available at
    Documentation/cgroup/blkio.txt.

This series of patches consists of two parts:
dm-ioband v1.12.1
  dm-ioband is an I/O bandwidth controller implemented as a
  device-mapper driver and can control bandwidth on per partition, per
  user, per process, per virtual machine (such as KVM or Xen) basis.

blkio-cgruop v9 
  blkio-cgroup is a block I/O tracking mechanism implemented on the
  cgroup memory subsystem. Using this feature the owners of any type
  of I/O can be determined. This allows dm-ioband to control block I/O
  bandwidth even when it is accepting delayed write requests.
  dm-ioband can find the cgroup of each request. It is also for
  possible that others working on I/O bandwidth throttling to use this
  functionality to control asynchronous I/O with a little enhancement.

The patches can be applied to both the current device-mapper development
tree and 2.6.31-rc3.

The list of the patches:
  [PATCH 1/9] I/O bandwidth controller and BIO tracking
  [PATCH 2/9] dm-ioband-1.12.1: All-in-one patch
  [PATCH 3/9] blkio-cgroup-v9: The new page_cgroup framework
  [PATCH 4/9] blkio-cgroup-v9: Refactoring io-context initialization
  [PATCH 5/9] blkio-cgroup-v9: The body of blkio-cgroup
  [PATCH 6/9] blkio-cgroup-v9: The document of blkio-cgroup
  [PATCH 7/9] blkio-cgroup-v9: Page tracking hooks
  [PATCH 8/9] blkio-cgroup-v9: Fast page tracking
  [PATCH 9/9] blkio-cgroup-v9: Add a cgroup support to dm-ioband

Please visit our website, the patches and more information are available.
  Linux Block I/O Bandwidth Control Project
  http://sourceforge.net/apps/trac/ioband/

I'd like to get some feedbacks from the list. Any comments are
appreciated.

Thanks,
Ryo Tsuruta
