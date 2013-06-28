From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: cgroup: status-quo and userland efforts
Date: Thu, 27 Jun 2013 21:09:30 -0700
Message-ID: <20130628040930.GC2500__36781.0475211174$1372392588$gmane$org@htj.dyndns.org>
References: <CAAAKZwvh_R2Xz--bmSLiN33fsqKanOJMq_6+6hoFWFRx38O4gA@mail.gmail.com>
	<20130422214159.GG12543@htj.dyndns.org>
	<CAAAKZwuXJwwyj7KSqb7rZ+nrTwBWEaUCWfa7kWecTBnHL8koGw@mail.gmail.com>
	<CAAAKZwvP_7wBBYMmtFuiE2hZt=ByaLrnTyiR83CZr3OMip63Gg@mail.gmail.com>
	<20130625000118.GT1918@mtj.dyndns.org>
	<CAAAKZwt09k-qUwLCnMpAQeYJ-S0XtkjXe4=bJ-G_fcrkAqEzoA@mail.gmail.com>
	<20130626212047.GB4536@htj.dyndns.org>
	<1372311907.5871.78.camel@marge.simpson.net>
	<20130627180143.GD5599@mtj.dyndns.org>
	<1372391198.5989.110.camel@marge.simpson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1372391198.5989.110.camel-YqMYhexLQo31wTEvPJ5Q0F6hYfS7NtTn@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mike Galbraith <bitbucket-BGeptl67XyCzQB+pC5nmwQ@public.gmane.org>
Cc: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, lpoetter <lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, workman-devel <workman-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, jpoimboe <jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "dhaval.giani" <dhaval.giani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Mike.

On Fri, Jun 28, 2013 at 05:46:38AM +0200, Mike Galbraith wrote:
> Sure, because in private property and I mandatory agent, I see "gimme
> yer wallet bitch", an incredibly arrogant and brutal mugging.  That's
> not the way it's meant, I know that, but that's how it comes across.
> You asked, so you get the straight up answer.

I don't know.  It reads more like tungue-in-cheek thing to me rather
than being actually arrogant, and some part of the brutality is
necessary at this point.

> Offering to manage cgroups is one thing, very generous, forcefully
> placing itself between user and kernel quite another.  Perhaps I
> misread, but my interpretation was that the intent is to make systemd a
> mandatory agent, even saw reference to it taking up residence in the
> kernel tree (that bit made me chuckle, pull request would have to be
> very cleverly worded methinks).  I'm sure it will be quite capable, its
> authors are.  However, when I want to talk to my kernel, I expect to be
> able to tell anyone else using the phone to hang up.. now.

I don't know how to respond to this.  It feels more emotional than
technical.

> It's useful now, usable to the point that enterprise users exist who
> have integrated cgroups into their business model.  But then you know
> that.  Sure, there are problems, things could and no doubt will get a
> lot better.

No, it's completely messed up.  We're now starting to see users trying
to embed low level cgroup details into their binaries and cgroup is
exposing sysctl-level konbs which are directly tied to internal
implementation of core subsystems.  cgroup successfully bypassed the
usual kernel API policing with the help of hierarchical filesystem
interface which allows delegation on the surface.  We completely
fucked up.  This is a full scale disaster unrolling.

> However, wrt userspace agent, no agent is going to be the right answer
> for all, so that agent needs to have a step aside button so another
> agent can be tasked with the managerial duties, whether that be little
> ole /me or Aunt Tilly piddling with this and that because we damn well
> feel like it, or BigFoot company X going massively wild and crazy doing
> their business thing.

*ANY* agent is better than now.  We need to back the hell out of
direct usages as soon as possible.  cgroup is leaking kernel
implementation details into individual binaries.  The current
situation is dangerous and putting an agent inbetween is a good way of
gradually backing out of it.

> No, it's not at all crazy, _offering_ the user a managerial service is
> great, generous, way to go guys, pass out the white hats.  Use force,
> and those pretty white hats turn black as night, hero to villain.

No, it's completely crazy.  Full psycho crazy.  You just don't realize
it yet.

> systemd and no systemd is also a valid issue.  I'm sure it'll all get
> worked out, but that link, and others like it make me see bright red.

That red is nothing compared to the kernel implementation detail leak
going on right now.  The alarm for that has been blinking
psychedelically for some time now.

Thanks.

-- 
tejun
