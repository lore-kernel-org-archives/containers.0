From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 2/2] dm-ioband: I/O bandwidth controller v0.0.4: Document
Date: Sat, 26 Apr 2008 11:45:35 -0700
Message-ID: <20080426114535.e19283be.akpm__30417.3671444461$1209235874$gmane$org@linux-foundation.org>
References: <20080424.201857.183035295.ryov@valinux.co.jp>
	<20080424.202219.59667073.ryov@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080424.202219.59667073.ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, Sergey Kononenko <sergk-4fxBgsLEJ9cH6wp9xFTt+g@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 24 Apr 2008 20:22:19 +0900 (JST) Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org> wrote:

> +What's dm-ioband all about?
> +
> +     dm-ioband is an I/O bandwidth controller implemented as a device-mapper
> +   driver. Several jobs using the same physical device have to share the
> +   bandwidth of the device. dm-ioband gives bandwidth to each job according
> +   to its weight, which each job can set its own value to.
> +
> +     At this time, a job is a group of processes with the same pid or pgrp or
> +   uid. There is also a plan to make it support cgroup. A job can also be a
> +   virtual machine such as KVM or Xen.

Most writes are performed by pdflush, kswapd, etc.  This will lead to large
inaccuracy.

It isn't trivial to fix.  We'd need deep, long tracking of ownership
probably all the way up to the pagecache page.  The same infrastructure
would be needed to make Sergey's "BSD acct: disk I/O accounting" vaguely
accurate.  Other proposals need it, but I forget what they are.

Much more minor points: when merge-time comes, the patches should have the
LINUX_VERSION_CODE stuff removed.  And probably all of the many `inline's
should be removed.
