From: Kamezawa Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH 4/8] cgroup: deactivate CSS's and mark cgroup dead before
	invoking ->pre_destroy()
Date: Fri, 02 Nov 2012 18:43:47 +0900
Message-ID: <509395D3.2070708@jp.fujitsu.com>
References: <1351657365-25055-1-git-send-email-tj@kernel.org>
	<1351657365-25055-5-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1351657365-25055-5-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mhocko-AlSwsSmVLrQ@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

(2012/10/31 13:22), Tejun Heo wrote:
> Because ->pre_destroy() could fail and can't be called under
> cgroup_mutex, cgroup destruction did something very ugly.
> 
>    1. Grab cgroup_mutex and verify it can be destroyed; fail otherwise.
> 
>    2. Release cgroup_mutex and call ->pre_destroy().
> 
>    3. Re-grab cgroup_mutex and verify it can still be destroyed; fail
>       otherwise.
> 
>    4. Continue destroying.
> 
> In addition to being ugly, it has been always broken in various ways.
> For example, memcg ->pre_destroy() expects the cgroup to be inactive
> after it's done but tasks can be attached and detached between #2 and
> #3 and the conditions that memcg verified in ->pre_destroy() might no
> longer hold by the time control reaches #3.
> 
> Now that ->pre_destroy() is no longer allowed to fail.  We can switch
> to the following.
> 
>    1. Grab cgroup_mutex and fail if it can't be destroyed; fail
>       otherwise.
> 
>    2. Deactivate CSS's and mark the cgroup removed thus preventing any
>       further operations which can invalidate the verification from #1.
> 
>    3. Release cgroup_mutex and call ->pre_destroy().
> 
>    4. Re-grab cgroup_mutex and continue destroying.
> 
> After this change, controllers can safely assume that ->pre_destroy()
> will only be called only once for a given cgroup and, once
> ->pre_destroy() is called, the cgroup will stay dormant till it's
> destroyed.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>


Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>

Ok, cgroup_lock_live_group() will work synchronously against attach_task().
I welcome this.
