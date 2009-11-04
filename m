From: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC] Mount point suggestions for cgroup
Date: Thu, 5 Nov 2009 03:10:30 +0530
Message-ID: <20091104214030.GO5495__22247.3980546512$1257370973$gmane$org@linux.vnet.ibm.com>
References: <20091104063005.GC3560@balbir.in.ibm.com>
	<20091104154024.0b8f6123.kamezawa.hiroyu@jp.fujitsu.com>
	<20091104173517.GA3668@count0.beaverton.ibm.com>
	<6599ad830911041325i9b309a7y4d912d6be7ddbdd9@mail.gmail.com>
Reply-To: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, libcg-devel <libcg-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, Bharata B Rao <bharata.rao-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, Jan-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Safranek <jsafrane-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
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
> 

libcgroup uses a configuration file specified by the user to do this.

thanks,
-- 
regards,
Dhaval
