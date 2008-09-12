From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v3][PATCH 5/9] Memory managemnet (restore)
Date: Fri, 12 Sep 2008 09:34:48 -0700
Message-ID: <1221237288.17910.26.camel__36250.9146136746$1221237477$gmane$org@nimitz>
References: <Pine.LNX.4.64.0809040354440.460@takamine.ncl.cs.columbia.edu>
	<Pine.LNX.4.64.0809040404060.5982@takamine.ncl.cs.columbia.edu>
	<1220551683.23386.32.camel@nimitz> <48C345D2.1020603@cs.columbia.edu>
	<1220892596.23386.166.camel@nimitz> <48C6113A.3080804@cs.columbia.edu>
	<1221082922.6781.62.camel@nimitz>  <48C8CAC6.3090209@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48C8CAC6.3090209-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 2008-09-11 at 03:37 -0400, Oren Laadan wrote:
> Let me start with the bottom line - since this creates too much confusion,
> I'll just switch to the alternative: will use get_user_pages() to bring
> pages in and copy the data directly. Hopefully this will end the discussion.
> 
> (Note, there there is a performance penalty in the form of extra data copy:
> instead of reading data directly to the page, we instead read into a buffer,
> kmap_atomic the page and copy into the page).

Yep but, as we discussed on IRC, this code needs some optimization for
pages in swap, anyway.  It isn't optimal for those, either.  So, for
this we'll leave it at a minimal amount of code rather than maximal
functionality. :)

> > I bugged Serge about this.  He said that this, at least, bypasses the SE
> > Linux checks that are normally done with an mprotect() system call.
> > That's a larger design problem that we need to keep in mind: we need to
> > be careful to keep existing checks in place.
> 
> I also discussed this with Serge, and I got the impression that he
> agreed that there was no security issue because it was all and only
> about private memory.

Yep, as long as there are some sanity checks to make sure that we're not
overriding permissions, I'm happy with this.

> If a task is ptraced, then the tracer can easily arrange for the tracee
> to call mprotect(), or to call sys_restart() with a tampered checkpoint
> file, or do other tricks. The call to mprotect_fix(), on a private vma,
> does not make this any worse. That is why I didn't bother implementing
> that bit.

I completely agree that it isn't an issue on a private VMA.  My only
concern is if this is done to any shared memory or could potentially be
abused in such a way that it gets applied to shared memory.

-- Dave
