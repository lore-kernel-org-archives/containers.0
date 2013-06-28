From: =?UTF-8?B?VnJpamVuZHJhICjgpLXgpYPgpJzgpYfgpKjgpY3gpKbgpY3gpLApIEdva2hhbGU=?=
	<vrigo-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: cgroup: status-quo and userland efforts
Date: Fri, 28 Jun 2013 12:01:56 -0700
Message-ID: <CAEZzrd3EVWNkbZn4AcPn=vQ84s6JQGitjZorbhBRSf+ZL_Sd2Q@mail.gmail.com>
References: <CAAAKZwvP_7wBBYMmtFuiE2hZt=ByaLrnTyiR83CZr3OMip63Gg@mail.gmail.com>
	<20130625000118.GT1918@mtj.dyndns.org>
	<CAAAKZwt09k-qUwLCnMpAQeYJ-S0XtkjXe4=bJ-G_fcrkAqEzoA@mail.gmail.com>
	<20130626212047.GB4536@htj.dyndns.org>
	<1372311907.5871.78.camel@marge.simpson.net>
	<20130627180143.GD5599@mtj.dyndns.org>
	<1372391198.5989.110.camel@marge.simpson.net>
	<20130628040930.GC2500@htj.dyndns.org>
	<1372394950.5989.128.camel@marge.simpson.net>
	<20130628050138.GD2500@htj.dyndns.org>
	<20130628150513.GD5125@dhcp22.suse.cz>
	<CAAAKZwtqYe-c0bfkgHFbzsOKVHifjTwkqcpci=uS1JwqS9TJHQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAAAKZwtqYe-c0bfkgHFbzsOKVHifjTwkqcpci=uS1JwqS9TJHQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Mike Galbraith <bitbucket-BGeptl67XyCzQB+pC5nmwQ@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, lpoetter <lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, jpoimboe <jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "dhaval.giani" <dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Jun 28, 2013 at 11:53 AM, Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org> wrote:

> On Fri, Jun 28, 2013 at 8:05 AM, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org> wrote:
> > On Thu 27-06-13 22:01:38, Tejun Heo wrote:
>
> >> Oh, that in itself is not bad.  I mean, if you're root, it's pretty
> >> easy to play with and that part is fine.  But combined with the
> >> hierarchical nature of cgroup and file permissions, it encourages
> >> people to "deligate" subdirectories to less previledged domains,
> >
> > OK, this really depends on what you expose to non-root users. I have
> > seen use cases where admin prepares top-level which is root-only but
> > it allows creating sub-groups which are under _full_ control of the
> > subdomain. This worked nicely for memcg for example because hard limit,
> > oom handling and other knobs are hierarchical so the subdomain cannot
> > overwrite what admin has said.
>
> bingo
>
>
Note that we also use cpu and io hierarchies as user accessible hierarchies.

This makes delegation possible to google workloads for subset (sub-cgroups)
creation and monitoring.


> > And the systemd, with its history of eating projects and not caring much
> > about their previous users who are not willing to jump in to the systemd
> > car, doesn't sound like a good place where to place the new interface to
> > me.
>
> +1
>
> If systemd is the only upstream implementation of this single-agent
> idea, we will have to invent our own, and continue to diverge rather
> than converge.  I think that, if we are going to pursue this model of
> a single-agent, we should make a kick-ass implementation that is
> flexible and scalable, and full-featured enough to not require
> divergence at the lowest layer of the stack.  Then build systemd on
> top of that. Let systemd offer more features and policies and
> "semantic" APIs.
>
> We will build our own semantic APIs that are, necessarily, different
> from systemd.  But we can all use the same low-level mechanism.
>
> Tim
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linuxfoundation.org/mailman/listinfo/containers
>
