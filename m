From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: [PATCH 1/7] blkio-cgroup: Introduction
Date: Tue, 28 Apr 2009 21:44:23 +0900 (JST)
Message-ID: <20090428.214423.193684619.ryov__22589.3494360664$1240922789$gmane$org@valinux.co.jp>
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

This is a new release of blkio-cgroup which provides an IO tracking
mechanism. You can also download this series of patches from
http://people.valinux.co.jp/~ryov/blkio-cgroup/

Changes from the previous release
=================================
- bio-cgroup renamed to blkio-cgroup.
- Use part of page_cgroup->flags to store the blkio-cgroup ID.
  This code is taken from Andrea's io-throttle.
  http://download.systemimager.org/~arighi/linux/patches/io-throttle/cgroup-io-throttle-v14.patch
- Add a new function blkio_cgroup_lookup(ID) which can be called from
  other cgroup subsystems and return the cgroup associated with a
  given blkio-cgroup ID. It makes it easy to use blkio-cgroup from other
  cgroup subsystems.
- Add an extra patch which reduces the overhead of IO tracking.
- Can be applied to 2.6.30-rc3 and 2.6.30-rc3-git3.

What's blkio-cgroup all about?
==============================

With this feature, you can determine the owners of any type of
I/Os. This makes dm-ioband_--_I/O_bandwidth_controller_-- be able to
control the Block I/O bandwidths even when it accepts delayed write
requests. Dm-ioband can find the owner cgroup of each request. It is
also possible that the other people who work on the I/O bandwidth
throttling use this functionality to control asynchronous I/Os with a
little enhancement.

Setting up blkio-cgroup
=======================

You have to apply the patch dm-ioband before applying this series of
blkio-cgroup patches.
And you have to select the following config options when compiling
kernel.

      CONFIG_CGROUPS=y
      CONFIG_CGROUP_BLKIO=y

And I recommend you should also select the options for cgroup memory
subsystem, because it makes it possible to give some I/O bandwidth and
some memory to a certain cgroup to control delayed write requests and
the processes in the cgroup will be able to make pages dirty only
inside the cgroup even when the given bandwidth is narrow.

      CONFIG_RESOURCE_COUNTERS=y
      CONFIG_CGROUP_MEM_RES_CTLR=y

Using blkio-cgroup
==================

The following shows how to use dm-ioband with cgroups. Please assume
that you want make two cgroups, which we call "bio cgroup" here, to
track down block I/Os and assign them to ioband device "ioband1".

First, mount the bio cgroup filesystem.

      # mount -t cgroup -o blkio none /cgroup

Then, make new bio cgroups and put some processes in them.

      # mkdir /cgroup/grp1
      # mkdir /cgroup/grp2
      # echo 1234 > /cgroup/grp1/tasks
      # echo 5678 > /cgroup/grp2/tasks

Now, check the ID of each blkio cgroup which is just created.

      # cat /cgroup/grp1/blkio.id
      2
      # cat /cgroup/grp2/blkio.id
      3

Finally, attach the cgroups to "ioband1" and assign them weights.

      # dmsetup message ioband1 0 type cgroup
      # dmsetup message ioband1 0 attach 2
      # dmsetup message ioband1 0 attach 3
      # dmsetup message ioband1 0 weight 2:30
      # dmsetup message ioband1 0 weight 3:60
