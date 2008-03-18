From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 2/4] Block I/O tracking
Date: Tue, 18 Mar 2008 20:55:01 +0900
Message-ID: <20080318205501.59877972.kamezawa.hiroyu__14087.4542682015$1205841162$gmane$org@jp.fujitsu.com>
References: <20080318.182251.93858044.taka@valinux.co.jp>
	<20080318.182906.104806991.taka@valinux.co.jp>
	<20080318192233.89c5cc3e.kamezawa.hiroyu@jp.fujitsu.com>
	<20080318.203422.45236787.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080318.203422.45236787.taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 18 Mar 2008 20:34:22 +0900 (JST)
Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org> wrote:

>
> > And, blist seems to be just used for force_empty.
> > Do you really need this ? no alternative ?
> 
> I selected this approach because it was the simplest way for the
> first implementation.
> 
> I've been also thinking about what you pointed.
> If you don't mind taking a long time to remove a bio cgroup, it will be
> the easiest way that you can scan all pages to find the pages which
> belong to the cgroup and delete them. It may be enough since you may
> say it will rarely happen. But it might cause some trouble on machines
> with huge memory.
> 
Hmm, force_empty itself is necessary ?

Thanks,
-Kame
