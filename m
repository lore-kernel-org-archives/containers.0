From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHv3 2/2] /proc/PID/status: show all sets of pid according
	to ns
Date: Tue, 30 Sep 2014 18:05:49 +0200
Message-ID: <20140930160549.GA6838@mail.hallyn.com>
References: <1411552827-31056-1-git-send-email-chenhanxiao@cn.fujitsu.com>
	<1411552827-31056-3-git-send-email-chenhanxiao@cn.fujitsu.com>
	<5871495633F38949900D2BF2DC04883E5C7377@G08CNEXMBPEKD02.g08.fujitsu.local>
	<20140929140010.GA20069@mail.hallyn.com>
	<5871495633F38949900D2BF2DC04883E5CF0D5@G08CNEXMBPEKD02.g08.fujitsu.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5871495633F38949900D2BF2DC04883E5CF0D5-ZEd+hNNJ6a5ZYpXjqAkB5jz3u5zwRJJDAzI0kPv9QBlmR6Xm/wNWPw@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Chen, Hanxiao" <chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Richard Weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Mateusz Guzik <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Chen, Hanxiao (chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
> Hi,
> 
> > -----Original Message-----
> > From: Serge E. Hallyn [mailto:serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org]
> > Sent: Monday, September 29, 2014 10:00 PM
> > Subject: Re: [PATCHv3 2/2] /proc/PID/status: show all sets of pid according to
> > ns
> [snip]
> > > >
> > > > This patch adds four fields: NStgid, NSpid, NSpgid and NSsid:
> > > > a) In init_pid_ns, nothing changed;
> > > >
> > > > b) In one pidns, will tell the pid inside containers:
> > > > NStgid:	21776   5       1
> > > > NSpid:  21776   5       1
> > > > NSpgid:	21776   5       1
> > > > NSsid:  21729   1       0
> > > > ** Process id is 21776 in level 0, 5 in level 1, 1 in level 2.
> > > >
> > > > c) If pidns is nested, it depends on which pidns are you in.
> > > > NStgid: 5       1
> > > > NSpid:  5       1
> > > > NSpgid: 5       1
> > > > NSsid:  1       0
> > > > ** Views from level 1
> > > >
> > >
> > > This patch is simple, useful and safe.
> > > But currently there is not any feedbacks.
> > >
> > > Any comments or ideas?
> > 
> > Thanks, Chen.  The code looks fine.  My concern is that you are
> > exposing information which cannot be checkpointed and restarted.
> > In particular, if I'm inside a nested container, so I'm in pidns
> > level 3, then my own NSpid info, when I read it, will show the
> > pids at parent namespaces.  If I'm restarted at the third pidns
> > level, only the one pid can be restored.
> 
> If you're in level 3, read your own proc, only level 3's NSpid info
> will be shown. No parent namesapces info could be seen.

D'oh!  Sorry, I see, you're starting at ns->level.  And ns is the ns
of the proc mount, not the caller.  that looks good.

So

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

> Only if not providing a procfs mount point for the new container,
> and without a proper pivot_root,
> we could see some NSpid info of parent ns.
> 
> If each new container got their own procfs mount point,
> only its and its child's NSpid info could be seen.
> 
> > 
> > Now it may be fair to say "this is proc, and proc and sys show
> > host info which is not containerized and cannot be checkpointed
> > and restarted, deal with it."  But I'm not sure.
> > 
> > There are two ways you could deal with this.  One would be to
> > show the nspids only to the level of the reader of the file - but
> > I don't think you need to do that.  I think you're better off
> > simply showing the pids up to the level of the struct pid for
> > the mounter of the procfs.  So if I'm inside container c2 which
> > is inside container c1, my own /proc will only show pids which
> > are valid in c2 (and any child namespaces), while the /proc
> > mounted in c1 will show pids valid in c1 and c2 (and any children),
> > but not those in the init_pid_ns.  It's then just up to the
> > container administrators to make sure that c2 cannot see c1's
> > /proc to confuse itself and confuddle checkpoint-restart
> 
> IIUC, this patch already deal with this scenario:
> 
> +	for (g = ns->level; g <= pid->level; g++)
> +		seq_printf(m, "\t%d ",
> +			task_tgid_nr_ns(p, pid->numbers[g].ns));
> 
> With this patch, it did like
> a) in init_pid_ns, check /proc/21776/status
> NStgid:	21776   5       1
> 
> b) in c1, check /proc/5/status:
> NStgid:	5       1
> 
> c) in c2, check /proc/1/status:
> NStgid:	1
> 
> Thanks,
> - Chen
