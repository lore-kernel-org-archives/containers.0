From: Mike Galbraith <bitbucket-BGeptl67XyCzQB+pC5nmwQ@public.gmane.org>
Subject: Re: cgroup: status-quo and userland efforts
Date: Thu, 27 Jun 2013 07:45:07 +0200
Message-ID: <1372311907.5871.78.camel__31551.7499846921$1372312740$gmane$org@marge.simpson.net>
References: <20130406012159.GA17159@mtj.dyndns.org>
	<CAAAKZwvh_R2Xz--bmSLiN33fsqKanOJMq_6+6hoFWFRx38O4gA@mail.gmail.com>
	<20130422214159.GG12543@htj.dyndns.org>
	<CAAAKZwuXJwwyj7KSqb7rZ+nrTwBWEaUCWfa7kWecTBnHL8koGw@mail.gmail.com>
	<CAAAKZwvP_7wBBYMmtFuiE2hZt=ByaLrnTyiR83CZr3OMip63Gg@mail.gmail.com>
	<20130625000118.GT1918@mtj.dyndns.org>
	<CAAAKZwt09k-qUwLCnMpAQeYJ-S0XtkjXe4=bJ-G_fcrkAqEzoA@mail.gmail.com>
	<20130626212047.GB4536@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130626212047.GB4536-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
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

On Wed, 2013-06-26 at 14:20 -0700, Tejun Heo wrote: 
> Hello, Tim.
> 
> On Mon, Jun 24, 2013 at 09:07:47PM -0700, Tim Hockin wrote:
> > I really want to understand why this is SO IMPORTANT that you have to
> > break userspace compatibility?  I mean, isn't Linux supposed to be the
> > OS with the stable kernel interface?  I've seen Linus rant time and
> > time again about this - why is it OK now?
> 
> What the hell are you talking about?  Nobody is breaking userland
> interface.  A new version of interface is being phased in and the old
> one will stay there for the foreseeable future.  It will be phased out
> eventually but that's gonna take a long time and it will have to be
> something hardly noticeable.  Of course new features will only be
> available with the new interface and there will be efforts to nudge
> people away from the old one but the existing interface will keep
> working it does.

I can understand some alarm.  When I saw the below I started frothing at
the face and howling at the moon, and I don't even use the things much.

http://lists.freedesktop.org/archives/systemd-devel/2013-June/011521.html

Hierarchy layout aside, that "private property" bit says that the folks
who currently own and use the cgroups interface will lose direct access
to it.  I can imagine folks who have become dependent upon an on the fly
management agents of their own design becoming a tad alarmed.

-Mike
