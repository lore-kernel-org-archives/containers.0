From: KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC] Mount point suggestions for cgroup
Date: Thu,  5 Nov 2009 08:34:12 +0900 (JST)
Message-ID: <20091105082914.54D6.A69D9226__38873.0917162777$1257377750$gmane$org@jp.fujitsu.com>
References: <6599ad830911041325i9b309a7y4d912d6be7ddbdd9@mail.gmail.com>
	<20091104214030.GO5495@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091104214030.GO5495-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Jan-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, libcg-devel <libcg-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>, Bharata B Rao <bharata.rao-xthvdsQ13ZrQT0dZR+AlfA@public.gmane.org>, kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Safranek <jsafrane-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

> On Wed, Nov 04, 2009 at 01:25:46PM -0800, Paul Menage wrote:
> > On Wed, Nov 4, 2009 at 9:35 AM, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> > >
> > > If anything, "standardizing" the mount point(s) will likely provide a false
> > > sense of uniformity and we'll get some bad userspace scripts/tools that
> > > break when "nonstandard" usage appears. Leaving the mount point undefined
> > > forces anyone writing scripts or tools to consider whether they want to be
> > > portable and, if so, the proper way to find the cgroup hierarchies they need
> > > to manipulate.
> > 
> > Scanning /proc/mounts to find the relevant mount locations is pretty
> > simple, for code that's just wanting to use existing cgroup mounts.
> > But for the code that sets up mounts in the first place, its probably
> > helpful to have recommendations of suitable locations.
> 
> libcgroup uses a configuration file specified by the user to do this.

You are right.
But fixed mount point help to make quick cute script for sys-admin.
