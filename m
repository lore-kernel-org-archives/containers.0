From: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>
Subject: Re: [PATCH v21 015/100] cgroup freezer: Update stale locking comments
Date: Mon, 10 May 2010 23:12:10 +0200
Message-ID: <201005102312.10190.rjw__46649.8724920259$1273525984$gmane$org@sisk.pl>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
	<201005102301.45729.rjw@sisk.pl>
	<20100510210724.GP31830@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100510210724.GP31830-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Cedric Le Goater <legoater-GANU6spQydw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Monday 10 May 2010, Matt Helsley wrote:
> On Mon, May 10, 2010 at 11:01:45PM +0200, Rafael J. Wysocki wrote:
> > On Thursday 06 May 2010, Oren Laadan wrote:
> > > 
> > > On 05/06/2010 03:40 PM, Rafael J. Wysocki wrote:
> > > > On Saturday 01 May 2010, Oren Laadan wrote:
> > > >> From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > > >>
> > > >> Update stale comments regarding locking order and add a little more detail
> > > >> so it's easier to follow the locking between the cgroup freezer and the
> > > >> power management freezer code.
> > > > 
> > > > I guess these three patches are for me.
> > > > 
> > > > Do you want me to handle them?
> > > 
> > > Yes, please, that would be great.
> > 
> > However, patches 16 and 17 seem to depend on checkpoint/restart and don't
> > appear to be margeable at this point.  Is this correct?
> 
> Strictly speaking they do not depend on checkpoint/restart. However, only
> checkpoint/restart uses the functionality introduced by those patches so I
> think you are correct that they aren't mergeable at this point.

OK, so I'm going to take patch 15 only for the upcoming merge window.

Thanks,
Rafael
