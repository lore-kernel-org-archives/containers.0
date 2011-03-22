From: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Subject: Re: [PATCH 1/2] list.h: add debug version of list_empty
Date: Tue, 22 Mar 2011 12:18:01 +0200
Message-ID: <20110322101801.GA1733__9237.9038841047$1300789208$gmane$org@shutemov.name>
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
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Phil Carmody <ext-phil.2.carmody-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Mar 21, 2011 at 04:52:06PM -0700, Andrew Morton wrote:
> On Tue, 15 Mar 2011 15:08:42 +0200
> Phil Carmody <ext-phil.2.carmody-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org> wrote:
> 
> > Heed the notice in list_del: "Note: list_empty() on entry does not
> > return true after this, the entry is in an undefined state.", and
> > check for precisely that condition.
> > 
> > There are currently a few instances in the code of this sequence:
> >     if(!list_empty(pnode))
> >         list_del(pnode);
> > which seems to be useless or dangerous if intended to protect from
> > repeated del's. And given that I've seen an oops pointing to a
> > dereference of poison in such a list_empty, I'm veering towards
> > dangerous. This patch would make such errors obvious.
> > 
> > Nothing is changed in the non-DEBUG_LIST build.
> > 
> > ...
> >
> > +
> > +/**
> > + * list_empty - tests whether a list is empty
> > + * @head: the list to test.
> > + */
> > +int list_empty(const struct list_head *head)
> > +{
> > +	if ((head->prev == LIST_POISON2) || (head->prev == LIST_POISON1))
> > +		WARN(1, "list_empty performed on a node "
> > +		     "at %p removed from a list.\n", head);
> > +	else
> > +		WARN((head->prev == head) != (head->next == head),
> > +		     "list_empty corruption. %p<-%p->%p is half-empty.\n",
> > +		     head->prev, head, head->next);
> > +
> > +	return head->next == head;
> > +}
> > +EXPORT_SYMBOL(list_empty);
> 
> The second warning here is triggering maybe a hundred times from all
> over the place just when booting the kernel.
> 
> Here's the first two:
> 
> 
> [   64.295941] WARNING: at lib/list_debug.c:89 list_empty+0x79/0x85()
> [   64.296129] list_empty corruption. ffff880255bcb788<-ffff880255bcb788->ffff88024c3a3c20 is half-empty.

It looks like a race between __list_del() and list_empty().

-- 
 Kirill A. Shutemov
