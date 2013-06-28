From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: cgroup: status-quo and userland efforts
Date: Fri, 28 Jun 2013 17:05:13 +0200
Message-ID: <20130628150513.GD5125__22686.9235084907$1372431940$gmane$org@dhcp22.suse.cz>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130628050138.GD2500-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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
Cc: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>, Mike Galbraith <bitbucket-BGeptl67XyCzQB+pC5nmwQ@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, lpoetter <lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, workman-devel <workman-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, jpoimboe <jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "dhaval.giani" <dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu 27-06-13 22:01:38, Tejun Heo wrote:
> Hello, Mike.
> 
> On Fri, Jun 28, 2013 at 06:49:10AM +0200, Mike Galbraith wrote:
> > I always thought that was a very cool feature, mkdir+echo, poof done.
> > Now maybe that interface is suboptimal for serious usage, but it makes
> > the things usable via dirt simple scripts, very flexible, nice.
> 
> Oh, that in itself is not bad.  I mean, if you're root, it's pretty
> easy to play with and that part is fine.  But combined with the
> hierarchical nature of cgroup and file permissions, it encourages
> people to "deligate" subdirectories to less previledged domains,

OK, this really depends on what you expose to non-root users. I have
seen use cases where admin prepares top-level which is root-only but
it allows creating sub-groups which are under _full_ control of the
subdomain. This worked nicely for memcg for example because hard limit,
oom handling and other knobs are hierarchical so the subdomain cannot
overwrite what admin has said.

> which
> in turn leads to normal binaries to manipulate them directly, which is
> where the horror begins.  We end up exposing control knobs which are
> tightly coupled to kernel implementation details right into lay
> binaries and scripts directly used by end users.
>
> I think this is the first time this happened, which is probably why
> nobody really noticed the mess earlier.
> 
> Anyways, if you're root, you can keep doing whatever you want.

OK, so libcgroup's rules daemon will still work and place my tasks in
appropriate cgroups?

This is not quite in par with "libcgroup is dead and others have to
migrate to systemd as well" statements from the link posted earlier.
I really do not think that _any_ central agent will understand my
requirements and needs so I need a way to talk to cgroupfs somehow - I
have used libcgroups so far but touching cgroupfs is quite convinient
as well.

And the systemd, with its history of eating projects and not caring much
about their previous users who are not willing to jump in to the systemd
car, doesn't sound like a good place where to place the new interface to
me.

[...]
-- 
Michal Hocko
SUSE Labs
