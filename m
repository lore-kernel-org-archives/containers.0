From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: Unprivileged containers and co-ordinating user namespaces
Date: Fri, 29 Apr 2016 16:50:01 -0500
Message-ID: <20160429215001.GB13615__27436.5678582855$1461966618$gmane$org@mail.hallyn.com>
References: <1461880928.2307.48.camel@HansenPartnership.com>
	<20160428230045.GS22888@odin.tremily.us>
	<1461944328.2311.10.camel@HansenPartnership.com>
	<20160429155303.GA8900@mail.hallyn.com>
	<20160429183404.GE22888@odin.tremily.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160429183404.GE22888-q4NCUed9G3sTnwFZoN752g@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "W. Trevor King" <wking-vJI2gpByivqcqzYg7KEe8g@public.gmane.org>
Cc: James Bottomley <James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, systemd-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, util-linux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting W. Trevor King (wking-vJI2gpByivqcqzYg7KEe8g@public.gmane.org):
> On Fri, Apr 29, 2016 at 10:53:03AM -0500, Serge E. Hallyn wrote:
> > Quoting James Bottomley:
> > > I think that mostly works.  No-one's packaging it yet, which is why I
> > 
> > https://packages.debian.org/jessie/uidmap
> > https://launchpad.net/ubuntu/yakkety/+package/uidmap
> > http://rpm.pbone.net/index.php3/stat/45/idpl/28763248/numer/1/nazwa/newuidmap
> 
> On the other hand, Gentoo is waiting on a clean release tarball [1].
> It looks like 4.3-1 was missing a clean autoreconf [2]?  Has anything
> been pushed since?

Nope, I've not had time to push it and noone has offered a patch.

Maybe I'll find time next week.

> Cheers,
> Trevor
> 
> [1]: https://bugs.gentoo.org/show_bug.cgi?id=580432#c3
> [2]: https://lists.alioth.debian.org/pipermail/pkg-shadow-devel/2016-March/010924.html
>      Subject: [Pkg-shadow-devel] new shadow release candidate
>      Date: Tue Mar 22 18:58:55 UTC 2016
> 
> -- 
> This email may be signed or encrypted with GnuPG (http://www.gnupg.org).
> For more information, see http://en.wikipedia.org/wiki/Pretty_Good_Privacy
