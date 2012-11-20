From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/8] cgroup: add cgroup->id
Date: Mon, 19 Nov 2012 21:31:12 -0800
Message-ID: <20121120053112.GE25790__41699.1957616576$1353389497$gmane$org@mtj.dyndns.org>
References: <1353093624-22608-1-git-send-email-tj@kernel.org>
	<1353093624-22608-2-git-send-email-tj@kernel.org>
	<50AB086E.70901@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <50AB086E.70901-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, srivatsa.bhat-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Hello, Kamezawa.

On Tue, Nov 20, 2012 at 01:34:54PM +0900, Kamezawa Hiroyuki wrote:
> I'm sorry if I misunderstand ... current usage of css-id in memory/swap cgroup
> is for recording information of memory cgroup which may be destroyed. In some case,
> a memcg's cgroup is freed but a struct memcgroup and its css are available, swap_cgroup
> may contain id ot if.
> This patch puts cgroup's id at diput(), so, the id used in swap_cgroup can be
> reused while it's in use. Right ?

CSSes hold onto cgroups, so if memcg is around, its cgroup doesn't go
away, so the right thing to do would be holding onto CSS whlie there
are remaining references, which IMHO is the way it should have been
implemented from the beginning.  The only reason memcg currently has
its own refcnt nested inside css refcnt is because cgroup used to
require css refs to be completely drained for cgroup_rmdir() to
proceed.  Now that that weirdity is gone, we should go back to sane
css based reference counting, right?

Thanks.

-- 
tejun
