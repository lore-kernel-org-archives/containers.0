From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH 00/10] cgroups: Task counter subsystem v6
Date: Fri, 28 Oct 2011 16:30:21 -0700
Message-ID: <20111028163021.1ce61f8a.akpm@linux-foundation.org>
References: <1317668832-10784-1-git-send-email-fweisbec@gmail.com>
	<20111004150111.e9337268.akpm00@gmail.com>
	<CAAAKZwu67VMiZgdpp=i5p7zyGbOHGHXwF_iprufGPzTLkkUF2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAAAKZwu67VMiZgdpp=i5p7zyGbOHGHXwF_iprufGPzTLkkUF2A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>
Cc: Aditya Kali <adityakali-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 25 Oct 2011 13:06:35 -0700
Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org> wrote:

> On Tue, Oct 4, 2011 at 3:01 PM, Andrew Morton <akpm00-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > On Mon, __3 Oct 2011 21:07:02 +0200
> > Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> >
> >> Hi Andrew,
> >>
> >> This contains minor changes, mostly documentation and changelog
> >> updates, off-case build fix, and a code optimization in
> >> res_counter_common_ancestor().
> >
> > I'd normally duck a patch series like this when we're at -rc8 and ask
> > for it to be resent late in -rc1. __But I was feeling frisky so I
> > grabbed this lot for a bit of testing and will sit on it until -rc1.
> >
> > I'm still not convinced that the kernel has a burning need for a "task
> > counter subsystem". __Someone convince me that we should merge this!
> 
> We have real (accidental) DoS situations which happen because we don't
> have this.  It usually takes the form of some library no re-joining
> threads.  We end up deploying a few apps linked against this library,
> and suddenly we're in trouble on a machine.  Except, this being
> Google, we're in trouble on a lot of machines.

This is a bit foggy.  I think you mean that machines are experiencing
accidental forkbombs?

> There may be other ways to cobble this sort of safety together, but
> they are less appealing for various reasons.  cgroups are how we
> control groups of related pids.
> 
> I'd really love to be able to use this.

Has it been confirmed that this implementation actually solves the
problem?  ie: tested a bit?

btw, Frederic told me that this version of the patchset had some
serious problem so it's on hold pending an upgrade, regardless of other
matters.
