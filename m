From: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH 01/15] add Documentation/namespaces/user_namespace.txt (v3)
Date: Fri, 9 Sep 2011 08:10:45 -0500
Message-ID: <20110909131045.GB3476__33872.2695749768$1315573965$gmane$org@sergelap>
References: <1314993400-6910-1-git-send-email-serge@hallyn.com>
	<1314993400-6910-4-git-send-email-serge@hallyn.com>
	<20110907155024.42e3fe27.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110907155024.42e3fe27.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Andrew Morton (akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org):
> On Fri,  2 Sep 2011 19:56:26 +0000
> Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > +Note that this userid mapping for the VFS is not yet implemented, though the
> > +lkml and containers mailing list archives will show several previous
> > +prototypes.  In the end, those got hung up waiting on the concept of targeted
> > +capabilities to be developed, which, thanks to the insight of Eric Biederman,
> > +they finally did.
> 
> not-yet-implemented things worry me.  When can we expect this to
> happen, and how big and ugly will it be?

Hi Andrew,

We did a proof of concept of the simplest version of this in early August
(see git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/linux-userns-devel.git)
which actually was very un-scary.  So technically we could push it at the
same time as this set, but I thought that might just be too much for
review in one cycle.  That set (Eric's) is the very simplest approach
which tags an entire filesystem with a user namespace.

We would also want to pursue the more baroque approach, where filesystems
themselves are user-namespace aware.  I did an approach like that in
2008, see
https://lists.linux-foundation.org/pipermail/containers/2008-August/012679.html
It again is very do-able without being ugly, but, importantly, user
namespaces are usable for containers without that.  For starters, we only
need /proc and /sys to be user namespace aware (since they must allow
access from multiple namespaces), and that is simple as they are not
persistent.

So I believe that this is the last scary patchset, and that user
namespaces could actually be usable by the end of the year!

> I'm not seeing many (any) reviewed-by's on these patches.  I could get
> down and stare at them myself, but that wouldn't be very useful.  This
> work goes pretty deep and is quite security-affecting.  And network-afecting.
> Can you round up some suitable people and get the reviewing and testing happening
> please?

Will try.  Unfortunately I missed my chance to beg and bribe people in
person at plumbers :(

thanks,
-serge
