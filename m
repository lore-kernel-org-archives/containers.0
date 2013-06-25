From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.11 3/3] cgroup: always use RCU accessors
	for protected accesses
Date: Tue, 25 Jun 2013 10:04:51 +0800
Message-ID: <51C8FAC3.3080505@huawei.com>
References: <20130621225116.GC3949@htj.dyndns.org>
	<20130621225204.GD3949@htj.dyndns.org>
	<20130621225233.GE3949@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130621225233.GE3949-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <theo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On 2013/6/22 6:52, Tejun Heo wrote:
> kernel/cgroup.c still has places where a RCU pointer is set and
> accessed directly without going through RCU_INIT_POINTER() or
> rcu_dereference_protected().  They're all properly protected accesses
> so nothing is broken but it leads to spurious sparse RCU address space
> warnings.
> 
> Substitute direct accesses with RCU_INIT_POINTER() and
> rcu_dereference_protected().  Note that %true is specified as the
> extra condition for all derference updates.  This isn't ideal as all
> it does is suppressing warning without actually policing
> synchronization rules; however, most are scheduled to be removed
> pretty soon along with css_id itself, so no reason to be more
> elaborate.
> 
> Combined with the previous changes, this removes all RCU related
> sparse warnings from cgroup.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> Reported-by: Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> ---
>  kernel/cgroup.c |   21 ++++++++++++---------
>  1 file changed, 12 insertions(+), 9 deletions(-)
> 

Acked-by; Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
