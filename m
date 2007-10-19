From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [Devel] [RFC][PATCH] memory cgroup enhancements updated [7/10]
 RSS/CACHE failcnt
Date: Sat, 20 Oct 2007 07:33:38 +0900
Message-ID: <20071020073338.2cf41a34.kamezawa.hiroyu@jp.fujitsu.com>
References: <20071019182436.485e20cd.kamezawa.hiroyu@jp.fujitsu.com>
	<20071019183452.3b7057ca.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830710190954v276e8997l889be2b0ddfcaa61@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830710190954v276e8997l889be2b0ddfcaa61-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org, rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, 19 Oct 2007 09:54:23 -0700
"Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:

> On 10/19/07, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> > cgroup's resource has "failure" counter. But I think memory cgroup
> > has 2 types of failure
> >         - failure of cache
> >         - failure of RSS
> 
> Why do you think these are significantly different? Also, what kind of
> failure do we get when a task tries to fault on a mapping for a
> file-backed VMA? That's both RSS (since it's due to be mapped into the
> process' memory) and pagecache (assuming a cache-backed filesystem).
> 
One is for checking how memory cgroup works.
When memory reaches limit and amount of CACHE doesn't change but
CACHE.failure increases, maybe CACHE is rotating.

One is for debug, I'd like to check swapiness <-> RSS.failure:CACHE.failure
releationship. It's ok to turn these params to be DEBUG option.

File-backed VMA gets RSS.failure.

Thanks,
-Kame
