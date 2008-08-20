From: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: RFC: Attaching threads to cgroups is OK?
Date: Wed, 20 Aug 2008 20:48:32 +0900 (JST)
Message-ID: <20080820.204832.131207708.taka@valinux.co.jp>
References: <48AAA296.8050802@oss.ntt.co.jp>
	<20080819202237.edd75933.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080819202237.edd75933.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org
Cc: fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

> > Tsuruta-san, how about your bio-cgroup's tracking concerning this?
> > If we want to use your tracking functions for each threads seperately, 
> > there seems to be a problem.
> > ===cf. mm_get_bio_cgroup()===================
> >            owner
> > mm_struct ----> task_struct ----> bio_cgroup
> > =============================================
> > In my understanding, the mm_struct of a thread is same as its parent's.
> > So, even if we attach the TIDs of some threads to different cgroups the 
> > tracking always returns the same bio_cgroup -- its parent's group.
> > Do you have some policy about in which case we can use your tracking?
> > 
> It's will be resitriction when io-controller reuse information of the owner
> of memory. But if it's very clear who issues I/O (by tracking read/write
> syscall), we may have chance to record the issuer of I/O to page_cgroup
> struct. 

This might be slightly different topic though,
I've been thinking where we should add hooks to track I/O reqeust.
I think the following set of hooks is enough whether we are going to
support thread based cgroup or not.

  Hook-1: called when allocating a page, where the memory controller
	  already have a hoook.
  Hook-2: called when making a page in page-cache dirty.

For anonymous pages, Hook-1 is enough to track any type of I/O request.
For pages in page-cache, Hook-1 is also enough for read I/O because
the I/O is issued just once right after allocting the page.
For write I/O requests to pages in page-cache, Hook-1 will be okay
in most cases but sometimes process in another cgroup may write
the pages. In this case, Hook-2 is needed to keep accurate to track
I/O requests.

So, it won't be hard to make bio-cgroup accurate for I/O request
tracking.

I'm off untill 28th, thank you,
Hirokazu Takahashi.
