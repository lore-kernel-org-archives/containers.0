From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH] proc: Do not invalidate dentries with submounts
Date: Thu, 06 Dec 2007 09:05:02 -0700
Message-ID: <m17ijru7v5.fsf@ebiederm.dsl.xmission.com>
References: <20071205143518.GA24886@iris.sw.ru>
	<m1bq94t951.fsf@ebiederm.dsl.xmission.com> <4757CF70.3020508@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4757CF70.3020508-3ImXcnM4P+0@public.gmane.org> (Denis V. Lunev's message of "Thu, 06
	Dec 2007 13:31:12 +0300")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, marcus-sJr3legBufCzQB+pC5nmwQ@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

"Denis V. Lunev" <den-3ImXcnM4P+0@public.gmane.org> writes:

> you have changed the behavior of revalidation by shadows. I think it
> will be better to restore it and keep new one for shadows (and below)
> only, which has been done by my yesterday patch.

- I think it is better to move forward rather then back.
- The old proc dentry caching behavior is actually too aggressive, and has
  problem corner cases.  Keeping the dentries when we have something mounted
  on top is a trade off that is the least of two evils.
- My change fixes the mount leak on all of /proc not just on /proc/generic.

What you did is a hack that restored the old slightly buggy behavior.  Which
is fine if we can't find anything better.  It is not code that is on the
path towards a /proc that properly caches it's dentries.

With the old behavior a random user space application can open a file or
a directory in /proc pinning it's dcache entry.  Then the module supplying
that open file can be removed and reinserted.  Until the user space application
removes reference to that /proc file all you will be able to find is the
version of the file from before /proc was removed.

That sounds like a way to trigger nasty behavior to me.  I would like
to remove that possibility from the kernel if I can.

Eric
