From: Subrata Modak <subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [LTP] [PATCH 1/8] Scaling msgmni to the amount of lowmem
Date: Thu, 21 Feb 2008 19:09:38 +0530
Message-ID: <1203601178.4604.18.camel__32343.2453479201$1203601364$gmane$org@subratamodak.linux.ibm.com>
References: <20080211141646.948191000@bull.net>
	<20080211141813.354484000@bull.net>
	<20080215215916.8566d337.akpm@linux-foundation.org>
	<47B94D8C.8040605@bull.net>  <47B9835A.3060507@bull.net>
	<1203411055.4612.5.camel@subratamodak.linux.ibm.com>
	<47BB0EDC.5000002@bull.net>
	<1203459418.7408.39.camel@localhost.localdomain>
	<47BD705A.9020309@bull.net>  <47BD7648.5010309@bull.net>
Reply-To: subrata-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <47BD7648.5010309-6ktuUTfB/bM@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>
Cc: ltp-list-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, cmm-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

> Nadia Derbey wrote:
> > Matt Helsley wrote:
> > 
> >> On Tue, 2008-02-19 at 18:16 +0100, Nadia Derbey wrote:
> >>
> >> <snip>
> >>
> >>> +#define MAX_MSGQUEUES  16      /* MSGMNI as defined in linux/msg.h */
> >>> +
> >>
> >>
> >>
> >> It's not quite the maximum anymore, is it? More like the minumum
> >> maximum ;). A better name might better document what the test is
> >> actually trying to do.
> >>
> >> One question I have is whether the unpatched test is still valuable.
> >> Based on my limited knowledge of the test I suspect it's still a correct
> >> test of message queues. If so, perhaps renaming the old test (so it's
> >> not confused with a performance regression) and adding your patched
> >> version is best?
> >>
> > 
> > So, here's the new patch based on Matt's points.
> > 
> > Subrata, it has to be applied on top of the original ltp-full-20080131. 
> > Please tell me if you'd prefer one based on the merged version you've 
> > got (i.e. with my Tuesday patch applied).

Nadia, I would prefer Patch on the top of the already merged version (on
top of latest CVS snapshot as of today). Anyways, thanks for all these
effort :-)

--Subrata

> > 
> 
> Forgot the patch, sorry for that (thx Andrew).
> 
> Regards,
> Nadia
> 
