From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] Relax ns_can_attach checks to allow attaching
	to	grandchild cgroups
Date: Wed, 07 Jan 2009 09:58:43 +0800
Message-ID: <49640C53.7020403@cn.fujitsu.com>
References: <20090106222536.GA25228@eskarina.localdomain.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090106222536.GA25228-IaEwMO9oKu/77SC2UrCW1JJg/dWx8T/9@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

Grzegorz Nosek wrote:
> The ns_proxy cgroup allows moving processes to child cgroups only one
> level deep at a time. This commit relaxes this restriction and makes it
> possible to attach tasks directly to grandchild cgroups, e.g.:
> 
> ($pid is in the root cgroup)
> echo $pid > /cgroup/CG1/CG2/tasks
> 
> Previously this operation would fail with -EPERM and would have to be
> performed as two steps:
> echo $pid > /cgroup/CG1/tasks
> echo $pid > /cgroup/CG1/CG2/tasks
> 
> Also, the target cgroup no longer needs to be empty to move a task there.
> 
> Signed-off-by: Grzegorz Nosek <root-AfQBxy1nhrQ00sYp1HPQUA@public.gmane.org>

Reviewed-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

> ---
>  include/linux/cgroup.h |    4 ++--
>  kernel/cgroup.c        |   11 ++++++-----
>  kernel/ns_cgroup.c     |   14 ++++----------
>  3 files changed, 12 insertions(+), 17 deletions(-)
