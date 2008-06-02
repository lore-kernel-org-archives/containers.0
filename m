From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: [PATCH 0/2] dm-ioband: I/O bandwidth controller v1.1.0: Introduction
Date: Mon, 02 Jun 2008 21:34:33 +0900 (JST)
Message-ID: <20080602.213433.193692201.ryov__33836.1092530706$1212410216$gmane$org@valinux.co.jp>
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
Cc: agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org
List-Id: containers.vger.kernel.org

Hi everyone,

This is dm-ioband version 1.1.0 release.

Dm-ioband is an I/O bandwidth controller implemented as a device-mapper
driver, which gives specified bandwidth to each job running on the same
physical device.

- Can be applied to the kernel 2.6.26-rc2-mm1.
- Changes from 1.0.0 (posted on May 19, 2008):
  - Measures against high memory pressure.
    I/O requests to reclaim pages won't be blocked in dm-ioband
    even when the group doesn't have the right to issue any more I/Os.
    But it can keep to control the bandwidth of the group since these
    I/Os will be counted as debt of the group.
  - Performance tuning
    Improve the performance when a lot of ioband groups are created.
    It is useful when you want to control bandwidth on a per user
    basis. For example, you can create an ioband group and give an
    weight to a user once the user is logged in. The combination of
    dm-ioband, the cgroup memory resource controller and the
    CPU resource controller will work more effectively.

I also announce that we have launched "Linux Block I/O Bandwidth
Control Project" website http://people.valinux.co.jp/~ryov/bwctl/ .
The goal of this project is to develop a block I/O bandwidth
controller on Linux. You can find information about the followings:

- dm-ioband
  This device mapper driver.
- iobandctl
  An administration tool for dm-ioband, which makes it easy to
  configure the dm-ioband device.
- Block I/O Tracking
  Block I/O tracking, which we call "bio cgroup", provides block I/O
  tracking mechanism. It makes dm-ioband be able to control the block
  I/O bandwidths even when it accepts delays write requests.

Thanks,
Ryo Tsuruta
