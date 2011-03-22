From: Phil Carmody <ext-phil.2.carmody-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/2] list.h: add debug version of list_empty
Date: Tue, 22 Mar 2011 12:11:21 +0200
Message-ID: <20110322101121.GB30552__6309.21934866837$1300789087$gmane$org@esdhcp04044.research.nokia.com>
References: <1300194523-19325-1-git-send-email-ext-phil.2.carmody@nokia.com>
	<1300194523-19325-2-git-send-email-ext-phil.2.carmody@nokia.com>
	<20110321165206.1deaf0ab.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110321165206.1deaf0ab.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ext Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 21/03/11 16:52 -0700, ext Andrew Morton wrote:
> On Tue, 15 Mar 2011 15:08:42 +0200
> Phil Carmody <ext-phil.2.carmody-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org> wrote:
> > +int list_empty(const struct list_head *head)
> > +{
> > +	if ((head->prev == LIST_POISON2) || (head->prev == LIST_POISON1))
> > +		WARN(1, "list_empty performed on a node "
> > +		     "at %p removed from a list.\n", head);
> > +	else
> > +		WARN((head->prev == head) != (head->next == head),
> > +		     "list_empty corruption. %p<-%p->%p is half-empty.\n",
> > +		     head->prev, head, head->next);
 
> The second warning here is triggering maybe a hundred times from all
> over the place just when booting the kernel.
> 
> Here's the first two:
> 
> [   64.295941] WARNING: at lib/list_debug.c:89 list_empty+0x79/0x85()
> [   64.296129] list_empty corruption. ffff880255bcb788<-ffff880255bcb788->ffff88024c3a3c20 is half-empty.


OK, so the patch is working as expected. Perhaps my expectations were wrong.

Looking at list.h I was sure that lists should always be either circular or
poisoned both ends. The above is a rho-shape, this == prev.

Traditional list_empty() returns false on such a node, so it should be
possible to list_del() it. But then next->prev will be set to this->prev 
which is this. So this will never be deleted from the list. That situation
rings warning bells in my head. Which I guess is what the patch was trying
to concretise.

I presume the above are x86_64, I'll see if I can get access to such a 
machine in the next few days, or reproduce it on one of the architectures
I do have here.

Phil
