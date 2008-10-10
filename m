From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 2/2] first callers of process_deny_checkpoint()
Date: Fri, 10 Oct 2008 10:28:27 -0700
Message-ID: <1223659707.11830.57.camel__6263.14347978241$1223659962$gmane$org@nimitz>
References: <20081009190405.13A253CB@kernel>
	<20081009190406.1B257119@kernel> <48EF2BAB.1010009@fr.ibm.com>
	<20081010140430.GA14640@us.ibm.com>
	<1223657132.10017.42.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1223657132.10017.42.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg Kurz <gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: arnd-r2nGTMty4D4@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 2008-10-10 at 18:45 +0200, Greg Kurz wrote:
> It's exactly what I meant before, the tracking facility would be awfully
> complicated. It cannot be done that way.
> But there's also something awkward with the flag thing : can you provide
> right now an exhaustive list of all the places where you must raise it ?

Greg, that's just pure FUD.  We don't say that spinlocks are a bad thing
because we can't come up with an exhaustive list of places where we need
locking.

We'll do plenty of checks at checkpoint time.

We'll do plenty of checks at runtime.

Neither will work completely on its own, and neither will be exhaustive.
The way this will work is just as Serge said: in true Linux style, we'll
add more places users of process_deny_checkpoint() incrementally as we
find them and as people complain.  We'll also be incrementally removing
them as we add functionality.

-- Dave
