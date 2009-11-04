From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC] Mount point suggestions for cgroup
Date: Wed, 4 Nov 2009 15:37:45 -0800
Message-ID: <20091104233745.GB3668__13868.2594792501$1257377913$gmane$org@count0.beaverton.ibm.com>
References: <20091104063005.GC3560@balbir.in.ibm.com>
	<20091104154024.0b8f6123.kamezawa.hiroyu@jp.fujitsu.com>
	<20091104173517.GA3668@count0.beaverton.ibm.com>
	<6599ad830911041325i9b309a7y4d912d6be7ddbdd9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6599ad830911041325i9b309a7y4d912d6be7ddbdd9-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, libcg-devel <libcg-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, Bharata B Rao <bharata.rao-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Jan-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Safranek <jsafrane-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Nov 04, 2009 at 01:25:46PM -0800, Paul Menage wrote:
> On Wed, Nov 4, 2009 at 9:35 AM, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> >
> > If anything, "standardizing" the mount point(s) will likely provide a false
> > sense of uniformity and we'll get some bad userspace scripts/tools that
> > break when "nonstandard" usage appears. Leaving the mount point undefined
> > forces anyone writing scripts or tools to consider whether they want to be
> > portable and, if so, the proper way to find the cgroup hierarchies they need
> > to manipulate.
> 
> Scanning /proc/mounts to find the relevant mount locations is pretty
> simple, for code that's just wanting to use existing cgroup mounts.
> But for the code that sets up mounts in the first place, its probably
> helpful to have recommendations of suitable locations.

If the tool set up the mounts in the first place then there's nothing
gained, as far as the code is concerned, by standardizing the location.
It could just as easily make a temporary directory and put it there.

If it's specified in an /etc file by the user then standardization
gets us nothing but inflexibility. The user knows where it is (they set it)
and the code knows where it is (via /proc OR /etc).

Recommending default locations seems helpful only so that users can inspect
what the code does. Blessing one location as the "standard, one, true location"
for code to use -- via FHS/LSB/whatnot -- seems like asking for trouble.

Cheers,
	-Matt
