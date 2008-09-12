From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [RFC] [PATCH -mm 0/2] memcg: per cgroup dirty_ratio
Date: Fri, 12 Sep 2008 17:09:50 +0200
Message-ID: <1221232192-13553-1-git-send-email-righi.andrea__6547.58339883319$1221232442$gmane$org@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <>
References: <>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: David Radford <dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org>, Marco Innocenti <m.innocenti-qooieK91W7JeoWH0uzbU5w@public.gmane.org>, =?utf-8?q?Fernando=20Luis=20V=C3=A1zquez=20Cao?= <fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, Matt Heaton <matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org


The goal of the patch is to control how much dirty file pages a cgroup can have
at any given time (see also [1]).

Dirty file and writeback pages are accounted for each cgroup using the memory
controller statistics. Moreover, the dirty_ratio parameter is added to the
memory controller. It contains, as a percentage of the cgroup memory, the
number of dirty pages at which the processes belonging to the cgroup which are
generating disk writes will start writing out dirty data.

So, the behaviour is actually the same as the global dirty_ratio, except that
it works per cgroup.

Interface:
- two new entries "writeback" and "filedirty" are added to the file
  memory.stat, to export to userspace respectively the number of pages under
  writeback and the number of dirty file pages in the cgroup

- the new file memory.dirty_ratio is added in the cgroup filesystem to show/set
  the memcg dirty_ratio

[ This patch is still experimental and I only did few quick tests. I'd like to
do run more detailed benchmarks and compare the results, I guess the overhead
introduced by this patch shouldn't be so small... and BTW I would prefer a
dirty limit in bytes, intead of using a percentage of memory. Bytes are hugely
more flexible IMHO, they allow to define more fine-grained limits and so this
would work better on large memory machines. ]

[1] http://lkml.org/lkml/2008/9/9/245

-Andrea
