From: Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Subject: Re: cgroup: status-quo and userland efforts
Date: Thu, 27 Jun 2013 13:14:57 -0500
Message-ID: <20130627181457.GB26334__13527.4461507381$1372356915$gmane$org@sergelap>
References: <CAAAKZwvh_R2Xz--bmSLiN33fsqKanOJMq_6+6hoFWFRx38O4gA@mail.gmail.com>
	<20130422214159.GG12543@htj.dyndns.org>
	<CAAAKZwuXJwwyj7KSqb7rZ+nrTwBWEaUCWfa7kWecTBnHL8koGw@mail.gmail.com>
	<CAAAKZwvP_7wBBYMmtFuiE2hZt=ByaLrnTyiR83CZr3OMip63Gg@mail.gmail.com>
	<20130625000118.GT1918@mtj.dyndns.org>
	<CAAAKZwt09k-qUwLCnMpAQeYJ-S0XtkjXe4=bJ-G_fcrkAqEzoA@mail.gmail.com>
	<20130626212047.GB4536@htj.dyndns.org>
	<1372311907.5871.78.camel@marge.simpson.net>
	<20130627132206.GE4003@sergelap>
	<20130627174850.GC5599@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130627174850.GC5599-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>, Mike Galbraith <bitbucket-BGeptl67XyCzQB+pC5nmwQ@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, lpoetter <lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, jpoimboe <jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "dhaval.giani" <dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, workman-devel <workman-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Tejun Heo (tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org):
> Hello, Serge.
> 
> On Thu, Jun 27, 2013 at 08:22:06AM -0500, Serge Hallyn wrote:
> > At some point (probably soon) we might want to talk about a standard API
> > for these things.  However I think it will have to come in the form of
> > a standard library, which knows to either send requests over dbus to
> > systemd, or over /dev/cgroup sock to the manager.
> 
> Yeah, eventually, I think we'll have a standardized way to configure
> resource distribution in the system.  Maybe we'll agree on a
> standardized dbus protocol or there will be library, I don't know;
> however, whatever form it may be in, it abstraction level should be
> way higher than that of direct cgroupfs access.  It's way too low
> level and very easy to end up in a complete nonsense configuration.
> 
> e.g. enabling "cpu" on a cgroup whlie leaving other cgroups alone
> wouldn't enable fair scheduling on that cgroup but drastically reduce
> the amount of cpu share it gets as it now gets treated as single
> entity competing with all tasks at the parent level.

Right.  I *think* this can be offered as a daemon which sits as the
sole consumer of my agent's API, and offers a higher level "do what I
want" API.  But designing that API is going to be interesting.

I should find a good, up-to-date summary of the current behaviors of
each controller so I can talk more intelligently about it.  (I'll
start by looking at the kernel Documentation/cgroups, but don't
feel too confident that they'll be uptodate :)

> At the moment, I'm not sure what the eventual abstraction would look
> like.  systemd is extending its basic constructs by adding slices and
> scopes and it does make sense to integrate the general organization of
> the system (services, user sessions, VMs and so on) with resource
> management.  Given some time, I'm hoping we'll be able to come up with
> and agree on some common constructs so that each workload can indicate
> its resource requirements in a unified way.
> 
> That said, I really think we should experiment for a while before
> trying to settle down on things.  We've now just started exploring how
> system-wide resource managment can be made widely available to systems
> without requiring extremely specialized hand-crafted configurations
> and I'm pretty sure we're getting and gonna get quite a few details
> wrong, so I don't think it'd be a good idea to try to agree on things
> right now.  As far as such integration goes, I think it's time to play
> with things and observe the results.

Right,  I'm not attached to my toy implementation at all - except for
the ability, in some fashion, to have nested agents which don't have
cgroupfs access but talk to another agent to get the job done.

-serge
