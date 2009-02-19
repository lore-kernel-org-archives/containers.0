From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Banning checkpoint (was: Re: What can OpenVZ do?)
Date: Thu, 19 Feb 2009 22:06:37 +0300
Message-ID: <20090219190637.GA4846__25721.8050574467$1235070149$gmane$org@x200.localdomain>
References: <20090213105302.GC4608@elte.hu> <1234817490.30155.287.camel@nimitz>
	<20090217222319.GA10546@elte.hu> <1234909849.4816.9.camel@nimitz>
	<20090218003217.GB25856@elte.hu> <1234917639.4816.12.camel@nimitz>
	<20090218051123.GA9367@x200.localdomain>
	<20090218181644.GD19995@elte.hu> <1234992447.26788.12.camel@nimitz>
	<20090218231545.GA17524@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090218231545.GA17524-X9Un+BFzKDI@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Cc: hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

I think that all these efforts to abort checkpoint "intelligently" by
banning it early are completely misguided.

"Checkpointable" property isn't one-way ticket like "tainted" flag,
so doing it like tainted var isn't right, atomic or not, SMP-safe or
not.

With filesystems, one has ->f_op field to compare against banned
filesystems, one more flag isn't necessary.

Inotify isn't supported yet? You do

	if (!list_empty(&inode->inotify_watches))
		return -E;

without hooking into inotify syscalls.

ptrace(2) isn't supported -- look at struct task_struct::ptraced and
friends.

And so on.

System call (or whatever) does something with some piece of kernel
internals. We look at this "something" when walking data structures and
abort if it's scary enough.

Please, show at least one counter-example.
