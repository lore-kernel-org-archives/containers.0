From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [PATCH] cgroups: fix possible use after free
Date: Wed, 11 Feb 2009 01:19:33 +0000
Message-ID: <20090211011933.GB28946@ZenIV.linux.org.uk>
References: <4991497B.4030200@cn.fujitsu.com>
	<6599ad830902100215o185edd31k8731e033717dbb49@mail.gmail.com>
	<20090210124527.GA28946@ZenIV.linux.org.uk>
	<6599ad830902101601i294ffaa5xd01611c5121a5685@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6599ad830902101601i294ffaa5xd01611c5121a5685-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Feb 10, 2009 at 04:01:07PM -0800, Paul Menage wrote:
> On Tue, Feb 10, 2009 at 4:45 AM, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org> wrote:
> > On Tue, Feb 10, 2009 at 02:15:36AM -0800, Paul Menage wrote:
> >> On Tue, Feb 10, 2009 at 1:31 AM, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
> >> > In cgroup_kill_sb(), root is freed before sb is detached from the list,
> >> > so another sget() may find this sb and call cgroup_test_super(),
> >> > which will access the root that has been freed.
> >>
> >> I think that I'd assumed that by the time we get to cgroup_kill_sb()
> >> there's no chance of the sb being resurrected by sget().
> >
> > There is none.  grab_super() will fail to get it, so sget() will go
> > through retry logics.  Which doesn't mean that test won't be called
> > on it in the meanwhile.
> 
> OK, so Zefan's patch looks like the safest way to fix this particular
> issue. I think I see some other potential races with
> cgroup_test_super() though - we probably need to synchronize against
> the changing of a root's subsys_bits in rebind_subsystems(). Taking
> cgroup_mutex around the call to sget() would certainly provide that,
> but I'd have to check whether it causes locking cycles.

Deadlock.  The whole point of what sget() is doing with retries is this:
if you have a matching fs in the middle of shutdown, you obviously can't
pick its sb (it's halfway shut down) and you can't start bringing your
instance up until the halfdead one is gone.

So you can't wrap sget() into a mutex that might be grabbed at some
point of ->kill_sb() or it'll wait forever in that scenario.  Note
that test is essentially atomic; we are doing it fast for all superblocks
of this type.

If we find a match, we go ahead and pick that superblock.  So there's no
problem just assuming we'd won the race, got existing superblock and
change (if any) of ->subsys_bits simply happened just after that.

AFAICS, that's perfectly sane - you are talking about the race between
mount picking fs instance with the same options and remount changing
said instance.  Other callers of rebind_subsystems() do not apply -
one in your ->get_sb() won't change the field anyway and one in
->kill_sb() is irrelevant since the superblock will be rejected by
grab_super().

So no exclusion is needed there at all.  If you don't want later remount
of the first mount to affect these flags of second one you shouldn't share
the superblock at all, obviously...
