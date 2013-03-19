From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/4] fs: allow dev accesses in userns in controlled
	situations
Date: Tue, 19 Mar 2013 10:37:40 -0500
Message-ID: <20130319153740.GA21908@sergelap>
References: <1363338823-25292-1-git-send-email-glommer@parallels.com>
	<1363338823-25292-3-git-send-email-glommer@parallels.com>
	<20130315142045.GD3782@sergelap>
	<CAE=Ncradvs_twWT8b6NQz85dm-Y8ayTH7NFv=i0vjYXpRBW9sg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAE=Ncradvs_twWT8b6NQz85dm-Y8ayTH7NFv=i0vjYXpRBW9sg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Janne Karhunen <janne.karhunen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Janne Karhunen (janne.karhunen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> On Fri, Mar 15, 2013 at 4:20 PM, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> wrote:
> 
> >> We will do that by marking the mount as MNT_NODEV_NS instead of
> >> MNT_NODEV. This is because if the mount operation explicitly asked for
> >> nodev, we ought to respect it. MNT_NODEV_NS will forbid accesses if the
> >> task is not on a device cgroup. If it is, we will rely on the control
> >> rules in devcg to intermediate the access an tell us what those tasks
> >> can or cannot do.
> >
> > Well the devcg was meant to be a temporary stopgap solution until we
> > have device namespaces, and this seems to entrench them further, but
> > it does make sense.
> 
> Just out of interest, what would such device namespace actually
> do other than switch the device access on/off according to callers
> namespace?

It could also support mapping of <type>:maj:min inside namespace to
a different device on host.  In most cases we probably don't actually
want that, but it's an interesting enough thing to be worth thinking
through.

> 'Device namespace' Cells whitepaper [1]  talks about seems to be
> saying they also implemented a callback for some drivers (only

oh, thanks, haven't read that one, will have to.

> init_ns accessible ioctl?) to support their 'foreground/background'
> use case. While this is certainly one use case, it's certainly nothing
> generic.
> 
> 1. http://www.cs.columbia.edu/~nieh/pubs/sosp2011_cells.pdf
> 
> 
> --
> Janne
