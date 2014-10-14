From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCHv4] procfs: show hierarchy of pid namespace
Date: Tue, 14 Oct 2014 19:42:29 +0200
Message-ID: <20141014174229.GA31533@redhat.com>
References: <1412762198-21825-1-git-send-email-chenhanxiao@cn.fujitsu.com>
	<20141008151328.GB4835@redhat.com>
	<5871495633F38949900D2BF2DC04883E5E1649@G08CNEXMBPEKD02.g08.fujitsu.local>
	<20141009213414.GA10705@redhat.com>
	<5871495633F38949900D2BF2DC04883E5E864C@G08CNEXMBPEKD02.g08.fujitsu.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5871495633F38949900D2BF2DC04883E5E864C-ZEd+hNNJ6a5ZYpXjqAkB5jz3u5zwRJJDAzI0kPv9QBlmR6Xm/wNWPw@public.gmane.org>
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
Cc: Richard Weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Mateusz Guzik <mguzik-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On 10/13, Chen, Hanxiao wrote:
>
> > At the same time, for_each_process() in the global namespace can be
> > faster if there are a lot of sub-threads.
> >
> > > Perhaps that's not a good way.
> >
> > OK, I won't insist.
> >
> > although it would be nice to know why do you think this is bad.
> >
> I worried about it may slower in global namespace.
> But it will provide a great convenient way when query pid hierarchy
> when not in init_pid_ns.

Yes, it is not clear what is actually better, so ...

> I'll post a new patch using find_ge_pid + get_pid

Only if you think this makes more sense. I do not have a strong opinion.

And we can change the implementation at any time. The real problem is
the API this patch adds. I leave this to you and other reviewers who
understand the problem space better ;) Just I think that the changelog
could say a bit more, to explain why do we need this patch. IOW, explain
the problem and how/why this patch helps.

Oleg.
