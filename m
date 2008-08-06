From: "Robert P. J. Day" <rpjday-L09J2beyid0N/H6P543EQg@public.gmane.org>
Subject: Re: [PATCH] CGROUPS:  Group the CGROUPS Kconfig entries to be
	consecutive.
Date: Wed, 6 Aug 2008 07:10:51 -0400 (EDT)
Message-ID: <alpine.LFD.1.10.0808060708450.25391@localhost.localdomain>
References: <alpine.LFD.1.10.0808041213540.2600@localhost.localdomain>
	<20080806130112.82c04664.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080806130112.82c04664.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, "balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org" <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 6 Aug 2008, KAMEZAWA Hiroyuki wrote:

> On Mon, 4 Aug 2008 12:16:05 -0400 (EDT)
> "Robert P. J. Day" <rpjday-L09J2beyid0N/H6P543EQg@public.gmane.org> wrote:
>
> >
> > Move a few CGROUPS-related Kconfig entries so that they appear
> > consecutively when running "make menuconfig."  This shouldn't affect
> > the functionality.
> >
> > Signed-off-by: Robert P. J. Day <rpjday-L09J2beyid0N/H6P543EQg@public.gmane.org>
> >
> Seems nice look. (Below is an menuconfig image, I modified a bit for -mm)
>
>     lqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk x
>   x x    --- Control Group support                                        x x
>   x x    [ ]   Example debug cgroup subsystem                             x x
>   x x    [*]   Namespace cgroup subsystem                                 x x
>   x x    [ ]   Device controller for cgroups                              x x
>   x x    [*]   Cpuset support                                             x x
>   x x    [*]   Simple CPU accounting cgroup subsystem                     x x
>   x x    [*]   Resource counters                                          x x
>   x x    [*]     Memory Resource Controller for Control Groups            x x
>   x x    [ ]   Memory resource limit controls for cgroups                 x x
>
> How do you think Paul ?
>
> Off-topic: to Balbir.
>
> How about "Aggregated Memory rlimit controls for cgroup" instead of
> "Memory resource limit controls for cgroups" ?

  ok, i'll leave this with you and you can tweak and apply whatever
suits you.

rday
--

========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry:
    Have classroom, will lecture.

http://crashcourse.ca                          Waterloo, Ontario, CANADA
========================================================================
