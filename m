From: Phil Carmody <ext-phil.2.carmody-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/2] suck some poison out of cgroups' linked lists
Date: Tue, 15 Mar 2011 16:01:53 +0200
Message-ID: <20110315140153.GD18664__24319.0460060307$1300198191$gmane$org@esdhcp04044.research.nokia.com>
References: <1300194523-19325-1-git-send-email-ext-phil.2.carmody@nokia.com>
	<20110315135137.GA27545@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110315135137.GA27545-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: ext Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On 15/03/11 09:51 -0400, ext Christoph Hellwig wrote:
> On Tue, Mar 15, 2011 at 03:08:41PM +0200, Phil Carmody wrote:
> > Apparently, whether nodes are on a list is being checked with list_empty(),
> > and if they're on a list, they're list_del()ed. According to a subsequent 
> > list_empty() check, they're still on a list, as list_del() doesn't turn
> > the nodes into singleton lists, it simply poisons both its pointers, and
> > merry poison dereferencing may ensue. Oops.
> > 
> > There are at least 2 to address this matter, I've gone for the latter:
> > 
> > 1) Do not use list_empty() to check if a node is on a list or not. Have
> > an additional new function that checks to see whether the node is either
> > a singleton or is poisoned. Something like list_node_{on,off}_list()?
> > 
> > 2) Ensure that you never leave poison anywhere where you might want
> > to use list_empty().
> 
> The correct way is to use list_del_init() if you want to do list_empty
> checks later on.

I.e. (2). Glad I chose that one.

Phil
