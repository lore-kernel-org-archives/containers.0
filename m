From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 2/7] proc: Implement support for automounts in task directories
Date: Fri, 07 Nov 2008 08:58:34 -0800
Message-ID: <m1mygbqxqd.fsf@frodo.ebiederm.org>
References: <m1ej1p2l6u.fsf@frodo.ebiederm.org>
	<m1abcd2kqk.fsf@frodo.ebiederm.org>
	<20081106172617.dd51d0af.akpm@linux-foundation.org>
	<m1abccxpc5.fsf@frodo.ebiederm.org>
	<20081106184945.179c248a.akpm@linux-foundation.org>
	<m1iqr0urb8.fsf@frodo.ebiederm.org>
	<20081106202822.a1af8a6e.akpm@linux-foundation.org>
	<m1d4h7v8jf.fsf@frodo.ebiederm.org>
	<20081107080529.6f4de3ad.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753969AbYKGRF3@vger.kernel.org>
In-Reply-To: <20081107080529.6f4de3ad.akpm@linux-foundation.org> (Andrew
	Morton's message of "Fri, 7 Nov 2008 08:05:29 -0800")
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, adobriyan@gmail.com, viro@ZenIV.linux.org.uk, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> writes:

> I was thinking more along the lines of some repeated operation which
> generates reclaimable storage, only nothing reclaims that storage
> sufficiently promptly (the 500 second delay, perhaps).
>
> Like the problem we had with SLAB_DESTROY_BY_RCU and, umm, I think it
> was route cache entries increasing like mad and not getting reaped.

Well what happens is I run reclaim that chain whenever a process
exits or every 500s.  The 500s is really the backup in case
we don't have any processes exiting, which is a really
strange workload.

Now maybe there is an extremely perverse case out there that
can trigger some bad behavior.  But I can't think of anything
like that at the moment.  It would require accessing a lot
of /proc/<pid>/net directories and holding them open even after
their files were gone, pinning a lot of mounts, and then
use a lot of memory elsewhere.  Where the problem would
be that the code is not well tied in with memory reclaim.

A mount is not a big or expensive structure and it requires
a fd somewhere to keep it alive past exit.  Thinking back
to my analysis on /proc a few years ago where I introduced
struct pid to prevent lowmem exhaustion.  I can't think of
a case where it would be a problem or user triggerable.
Basically you have to have a fd open for every proc inode
that lives past process exit.  And we have hard limits on
the number of fds a process can open and limits on the
number of processes we can have.

One of the things on my todo list to look at sometime is the issue
that mounts can deny you the permission to delete a file or directory
when the mount is in another mount namespace.  It is a pretty nasty
DOS from my opinion.  Especially when the last process holding open
the mount namespace oopses and there is no way to remove the mount.
However that DOS is only available to root today so it doesn't feel
like a huge danger.  To fix that we would need to introduce some
better mount reaping logic.  Which I expect would remove the need for
the proc_automounts.   That is tricky subtle vfs logic and I don't
plan to rush into it.

Eric
