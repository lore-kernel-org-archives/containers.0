From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH RFC v2 4/4] memcg: implement memory thresholds
Date: Tue, 15 Dec 2009 20:09:27 +0900
Message-ID: <20091215200927.68126d96.kamezawa.hiroyu__1434.29487147859$1260875863$gmane$org@jp.fujitsu.com>
References: <cover.1260571675.git.kirill@shutemov.name>
	<ca59c422b495907678915db636f70a8d029cbf3a.1260571675.git.kirill@shutemov.name>
	<c1847dfb5c4fed1374b7add236d38e0db02eeef3.1260571675.git.kirill@shutemov.name>
	<747ea0ec22b9348208c80f86f7a813728bf8e50a.1260571675.git.kirill@shutemov.name>
	<9e6e8d687224c6cbc54281f7c3d07983f701f93d.1260571675.git.kirill@shutemov.name>
	<20091215105850.87203454.kamezawa.hiroyu@jp.fujitsu.com>
	<cc557aab0912150246k476aa85m6c1b61045fb0b26e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <cc557aab0912150246k476aa85m6c1b61045fb0b26e-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org>
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Dan Malek <dan-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vladislav Buzov <vbuzov-L1vi/lXTdtvkgf6YlCu6wwC/G2K4zDHf@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 15 Dec 2009 12:46:32 +0200
"Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org> wrote:

> On Tue, Dec 15, 2009 at 3:58 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> > On Sat, 12 Dec 2009 00:59:19 +0200
> > "Kirill A. Shutemov" <kirill-oKw7cIdHH8eLwutG50LtGA@public.gmane.org> wrote:

> > If you use have to use spinlock here, this is a system-wide spinlock,
> > threshold as "100" is too small, I think.
> 
> What is reasonable value for THRESHOLDS_EVENTS_THRESH for you?
> 
> In most cases spinlock taken only for two checks. Is it significant time?
> 
I tend to think about "bad case" when I see spinlock. 

And...I'm not sure but, recently, there are many VM users.
spinlock can be a big pitfall in some enviroment if not para-virtualized.
(I'm sorry I misunderstand somehing and VM handle this well...)

> Unfortunately, I can't test it on a big box. I have only dual-core system.
> It's not enough to test scalability.
> 

please leave it as 100 for now. But there is a chance to do simple optimization
for reducing the number of checks.

example)
static void mem_cgroup_threshold(struct mem_cgroup *memcg, bool swap)
{
	/* For handle memory allocation in rush, check jiffies */
	*/
	smp_rmb();
	if (memcg->last_checkpoint_jiffies == jiffies)
		return;   /* reset event to half value ..*/
	memcg->last_checkpoint_jiffies = jiffies;
	smp_wmb();
	.....

I think this kind of check is necessary for handle "Rushing" memory allocation
in scalable way. Above one is just an example, 1 tick may be too long.

Other simple plan is

	/* Allow only one thread to do scan the list at the same time. */
	if (atomic_inc_not_zero(&memcg->threahold_scan_count) {
		atomic_dec(&memcg->threshold_scan_count);
		return;
	}
	...
	atomic_dec(&memcg->threahold_scan_count)

Some easy logic (as above) for taking care of scalability and commenary for that
is enough at 1st stage. Then, if there seems to be a trouble/concern, someone
(me?) will do some work later.




Thanks,
-Kame
