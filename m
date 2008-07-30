From: Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org>
Subject: Re: memrlimit controller merge to mainline
Date: Wed, 30 Jul 2008 01:31:13 +0100 (BST)
Message-ID: <Pine.LNX.4.64.0807300117210.14699@blonde.site>
References: <6599ad830807250114h7ab0fdb1u98c0968961647642@mail.gmail.com>
	<Pine.LNX.4.64.0807251004570.31120@blonde.site>
	<6599ad830807250706t23e483b5j18d683c0470d1d22@mail.gmail.com>
	<Pine.LNX.4.64.0807251715070.12089@blonde.site>
	<6599ad830807251224g218e17faj5c8224ba398a51c8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830807251224g218e17faj5c8224ba398a51c8-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Rik van Riel <riel-ebMLmSuQjDVBDgjK7y7TUQ@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 25 Jul 2008, Paul Menage wrote:
> On Fri, Jul 25, 2008 at 12:46 PM, Hugh Dickins <hugh-DTz5qymZ9yRBDgjK7y7TUQ@public.gmane.org> wrote:
> > No, I'm trying to say something stronger than that.  I'm saying,
> > as I've said before, that I cannot imagine why anyone would want
> > to control swap itself - what they want to control is the total
> > of mem+swap.  Swap is a second-class citizen, nobody wants swap
> > if they can have mem, so why control it separately?
> 
> Scheduling jobs on to machines is much more straightforward when they
> request xGB of memory and yGB of swap rather than just (x+y)GB of
> (memory+swap). We want to be able to guarantee to jobs that they will
> be able to use xGB of real memory.

I don't see that I'm denying you a way to guarantee that (though I've
been thinking more of the limits than the guarantees): I'm not saying
that you cannot have a mem controller, I'm saying that you can also
have a mem+swap controller; but that a swap-by-itself controller
makes no sense to me.

> Actually my preferred approach to swap controlling would be something like:
> 
> - allow malloc to support mmaping pages from a temporary file rather
> than mmapping anonymous memory

I think that works until you get to fork: shared files and
private/anonymous/swap behave differently from then on.

Hugh
