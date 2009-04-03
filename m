From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v14-rc2][PATCH 4/7] sysvipc-shm: restart
Date: Thu, 2 Apr 2009 20:42:58 -0700
Message-ID: <20090403034258.GH4083@us.ibm.com>
References: <1238477552-17083-1-git-send-email-orenl@cs.columbia.edu>
	<1238477552-17083-5-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1238477552-17083-5-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Mar 31, 2009 at 01:32:29AM -0400, Oren Laadan wrote:
> Like chekcpoint, restart of sysvipc shared memory is also performed in
> two steps: first, the entire ipc namespace is restored as a whole, by
> restoring each shm object read from the checkpoint image. The shmem's
> file pointer is registered in the objhash. Second, for each vma that
> refers to ipc shared memory, we use the objref to find the file in the
> objhash, and use that file in calling do_mmap_pgoff().
> 
> Handling of shm objects that have been deleted (via IPC_RMID) is left
> to a later patch in this series.
> 
> Handling of ipc shm mappings that are locked (via SHM_MLOCK) is also
> not restored at the moment.
> 
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
> ---
>  checkpoint/rstr_mem.c      |   23 ++++++
>  checkpoint/util_ipc.c      |    2 +-
>  include/linux/checkpoint.h |    3 +
>  ipc/ckpt_shm.c             |  167 +++++++++++++++++++++++++++++++++++++++++++-
>  4 files changed, 193 insertions(+), 2 deletions(-)

<snip>
 
> diff --git a/ipc/ckpt_shm.c b/ipc/ckpt_shm.c
> index 6a9382a..ee9b77a 100644
> --- a/ipc/ckpt_shm.c
> +++ b/ipc/ckpt_shm.c
> @@ -14,6 +14,7 @@
>  #include <linux/hugetlb.h>
>  #include <linux/rwsem.h>
>  #include <linux/sched.h>
> +#include <linux/file.h>
>  #include <linux/syscalls.h>
>  #include <linux/nsproxy.h>
>  #include <linux/ipc_namespace.h>
> @@ -45,7 +46,10 @@ static int cr_fill_ipc_shm_hdr(struct cr_ctx *ctx,
>  	hh->shm_cprid = shp->shm_cprid;
>  	hh->shm_lprid = shp->shm_lprid;
> 
> -	hh->mlock_uid = (shp->mlock_user ? shp->mlock_user->uid : UINT_MAX);
> +	if (shp->mlock_user)
> +		hh->mlock_uid = shp->mlock_user->uid;
> +	else
> +		hh->mlock_uid = (unsigned int) -1;

I think this hunk should be merged with the patch introducing the conditional
expression rather than appear in this patch.

Cheers,
	-Matt Helsley
