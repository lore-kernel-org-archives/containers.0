From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHv3 2/2] /proc/PID/status: show all sets of pid according
	to ns
Date: Tue, 30 Sep 2014 18:07:55 +0200
Message-ID: <20140930160755.GB6838@mail.hallyn.com>
References: <1411552827-31056-1-git-send-email-chenhanxiao@cn.fujitsu.com>
	<1411552827-31056-3-git-send-email-chenhanxiao@cn.fujitsu.com>
	<5871495633F38949900D2BF2DC04883E5C7377@G08CNEXMBPEKD02.g08.fujitsu.local>
	<20140929140010.GA20069@mail.hallyn.com>
	<5871495633F38949900D2BF2DC04883E5CF0D5@G08CNEXMBPEKD02.g08.fujitsu.local>
	<20140930160549.GA6838@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140930160549.GA6838-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Richard Weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Mateusz Guzik <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org):
> Quoting Chen, Hanxiao (chenhanxiao-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org):
> > Hi,
> > 
> > > -----Original Message-----
> > > From: Serge E. Hallyn [mailto:serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org]
> > > Sent: Monday, September 29, 2014 10:00 PM
> > > Subject: Re: [PATCHv3 2/2] /proc/PID/status: show all sets of pid according to
> > > ns
> > [snip]
> > > > >
> > > > > This patch adds four fields: NStgid, NSpid, NSpgid and NSsid:
> > > > > a) In init_pid_ns, nothing changed;
> > > > >
> > > > > b) In one pidns, will tell the pid inside containers:
> > > > > NStgid:	21776   5       1
> > > > > NSpid:  21776   5       1
> > > > > NSpgid:	21776   5       1
> > > > > NSsid:  21729   1       0
> > > > > ** Process id is 21776 in level 0, 5 in level 1, 1 in level 2.
> > > > >
> > > > > c) If pidns is nested, it depends on which pidns are you in.
> > > > > NStgid: 5       1
> > > > > NSpid:  5       1
> > > > > NSpgid: 5       1
> > > > > NSsid:  1       0
> > > > > ** Views from level 1
> > > > >
> > > >
> > > > This patch is simple, useful and safe.
> > > > But currently there is not any feedbacks.
> > > >
> > > > Any comments or ideas?
> > > 
> > > Thanks, Chen.  The code looks fine.  My concern is that you are
> > > exposing information which cannot be checkpointed and restarted.
> > > In particular, if I'm inside a nested container, so I'm in pidns
> > > level 3, then my own NSpid info, when I read it, will show the
> > > pids at parent namespaces.  If I'm restarted at the third pidns
> > > level, only the one pid can be restored.
> > 
> > If you're in level 3, read your own proc, only level 3's NSpid info
> > will be shown. No parent namesapces info could be seen.
> 
> D'oh!  Sorry, I see, you're starting at ns->level.  And ns is the ns
> of the proc mount, not the caller.  that looks good.
> 
> So
> 
> Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

Also

Tested-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

as I've tested this between a few containers.
