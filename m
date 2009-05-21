From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: css_id numbering
Date: Thu, 21 May 2009 19:36:06 +0900 (JST)
Message-ID: <20090521.193606.189724982.ryov@valinux.co.jp>
References: <20090521.162859.226800758.ryov@valinux.co.jp>
	<20090521163215.63E1.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090521163215.63E1.A69D9226-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org, kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Kamezawa-san and Kosaki-san,

> > I have a suggestion for css_id numbering. How about using the same
> > numbering scheme as process ID for css_id instead of idr? It prevents
> > the same ID from being reused quickly.
> 
> process ID is not "short"(2bytes).
> 
> > blkio-cgroup can benefit from it. If some pages still have an old ID,
> > it can somewhat prevents IOs associated with those pages from being
> > charged for a new cgroup which are reusing the old ID.
> 
> plz see memcg's code. no reuse if id is still used.

blkio-cgroup embeds css_id into page_cgroup->flags, and the ID in the
flags still remain even after the cgroup which marks up the page is
removed.

The current numbering scheme of css_id choose the lowest number from
available IDs. When a cgroup is created right after another cgroup is
removed (no one referes to the cgroup), the same number will be reused
for the new cgroup.

When an IO associated with the page is issued, an IO controller which
uses blkio-cgroup charges the new cgroup according to the ID in the
page_cgroup->flags, instead of the removed cgroup. If css_id is simply
incremented by one like process ID, I think we could avoid such wrong
charges in many cases.

> it seems bogus solusion.
> pid rule also can make conflict. I think blkio-cgroup should be fixed.

This solution is reasonable for accuracy, even conflicts occur.
I think keeping down the overhead of blkio-cgroup is more important.

Thanks,
Ryo Tsuruta
