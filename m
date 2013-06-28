From: Mike Galbraith <bitbucket-BGeptl67XyCzQB+pC5nmwQ@public.gmane.org>
Subject: Re: cgroup: status-quo and userland efforts
Date: Fri, 28 Jun 2013 05:46:38 +0200
Message-ID: <1372391198.5989.110.camel__32690.8859344714$1372391235$gmane$org@marge.simpson.net>
References: <20130406012159.GA17159@mtj.dyndns.org>
	<CAAAKZwvh_R2Xz--bmSLiN33fsqKanOJMq_6+6hoFWFRx38O4gA@mail.gmail.com>
	<20130422214159.GG12543@htj.dyndns.org>
	<CAAAKZwuXJwwyj7KSqb7rZ+nrTwBWEaUCWfa7kWecTBnHL8koGw@mail.gmail.com>
	<CAAAKZwvP_7wBBYMmtFuiE2hZt=ByaLrnTyiR83CZr3OMip63Gg@mail.gmail.com>
	<20130625000118.GT1918@mtj.dyndns.org>
	<CAAAKZwt09k-qUwLCnMpAQeYJ-S0XtkjXe4=bJ-G_fcrkAqEzoA@mail.gmail.com>
	<20130626212047.GB4536@htj.dyndns.org>
	<1372311907.5871.78.camel@marge.simpson.net>
	<20130627180143.GD5599@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130627180143.GD5599-9pTldWuhBndy/B6EtB590w@public.gmane.org>
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
Cc: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, lpoetter <lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, workman-devel <workman-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, jpoimboe <jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "dhaval.giani" <dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2013-06-27 at 11:01 -0700, Tejun Heo wrote: 
> Hello, Mike.
> 
> On Thu, Jun 27, 2013 at 07:45:07AM +0200, Mike Galbraith wrote:
> > I can understand some alarm.  When I saw the below I started frothing at
> > the face and howling at the moon, and I don't even use the things much.
> 
> Can I ask why?  The reasons are not apparent to me.

Sure, because in private property and I mandatory agent, I see "gimme
yer wallet bitch", an incredibly arrogant and brutal mugging.  That's
not the way it's meant, I know that, but that's how it comes across.
You asked, so you get the straight up answer.

Offering to manage cgroups is one thing, very generous, forcefully
placing itself between user and kernel quite another.  Perhaps I
misread, but my interpretation was that the intent is to make systemd a
mandatory agent, even saw reference to it taking up residence in the
kernel tree (that bit made me chuckle, pull request would have to be
very cleverly worded methinks).  I'm sure it will be quite capable, its
authors are.  However, when I want to talk to my kernel, I expect to be
able to tell anyone else using the phone to hang up.. now.

> > http://lists.freedesktop.org/archives/systemd-devel/2013-June/011521.html
> > 
> > Hierarchy layout aside, that "private property" bit says that the folks
> > who currently own and use the cgroups interface will lose direct access
> > to it.  I can imagine folks who have become dependent upon an on the fly
> > management agents of their own design becoming a tad alarmed.
> 
> They're gonna be able to do what they've been doing for the
> foreseeable future if they choose not to use systemd's unified

Those are the comforting words I wanted to hear, that the user chooses,
that the user will not find that this that or any other userspace agent
gains the right to insert itself between user and kernel.

> AFAICS, having a userland agent which has overall knowledge of the
> hierarchy and enforcesf structure and limiations is a requirement to
> make cgroup generally useable and useful.

It's useful now, usable to the point that enterprise users exist who
have integrated cgroups into their business model.  But then you know
that.  Sure, there are problems, things could and no doubt will get a
lot better.

However, wrt userspace agent, no agent is going to be the right answer
for all, so that agent needs to have a step aside button so another
agent can be tasked with the managerial duties, whether that be little
ole /me or Aunt Tilly piddling with this and that because we damn well
feel like it, or BigFoot company X going massively wild and crazy doing
their business thing.

>   For systemd based systems,
> systemd serving that role isn't too crazy.  It's sure gonna have
> teeting issues at the beginning but it has all the necessary
> information to manage workloads on the system.

No, it's not at all crazy, _offering_ the user a managerial service is
great, generous, way to go guys, pass out the white hats.  Use force,
and those pretty white hats turn black as night, hero to villain.

> A valid issue is interoperability between systemd and non-systemd
> systems.  I don't have an immediately good answer for that.  I wrote
> in another reply but making cgroup generally available is a pretty new
> effort and we're still in the process of figuring out what the right
> constructs and abstractions are.  Hopefully, we'll be able to reach a
> common set of abstractions to base things on top in itme.

systemd and no systemd is also a valid issue.  I'm sure it'll all get
worked out, but that link, and others like it make me see bright red.

-Mike
