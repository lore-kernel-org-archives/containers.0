From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v14-rc2][PATCH 6/7] sysvipc-shm: export interface from
	ipc/shm.c to delete ipc shm
Date: Thu, 2 Apr 2009 20:32:00 -0700
Message-ID: <20090403033200.GG4083@us.ibm.com>
References: <1238477552-17083-1-git-send-email-orenl@cs.columbia.edu>
	<1238477552-17083-7-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1238477552-17083-7-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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

On Tue, Mar 31, 2009 at 01:32:31AM -0400, Oren Laadan wrote:
> Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>

The description is empty and this patch is rather pointless without 7/7.
Any reason you kept it separate from 7/7? At the very least this patch
needs a brief description.

Cheers,
	-Matt Helsley

> ---
>  include/linux/shm.h |    4 ++++
>  ipc/shm.c           |    4 ++--
>  2 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/shm.h b/include/linux/shm.h
> index eca6235..ec36e99 100644
> --- a/include/linux/shm.h
> +++ b/include/linux/shm.h
> @@ -118,6 +118,10 @@ static inline int is_file_shm_hugepages(struct file *file)
>  }
>  #endif
> 
> +struct ipc_namespace;
> +extern int shmctl_down(struct ipc_namespace *ns, int shmid, int cmd,
> +		       struct shmid_ds __user *buf, int version);
> +
>  #endif /* __KERNEL__ */
> 
>  #endif /* _LINUX_SHM_H_ */
> diff --git a/ipc/shm.c b/ipc/shm.c
> index 5ac6aec..28a8b57 100644
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -605,8 +605,8 @@ static void shm_get_stat(struct ipc_namespace *ns, unsigned long *rss,
>   * to be held in write mode.
>   * NOTE: no locks must be held, the rw_mutex is taken inside this function.
>   */
> -static int shmctl_down(struct ipc_namespace *ns, int shmid, int cmd,
> -		       struct shmid_ds __user *buf, int version)
> +int shmctl_down(struct ipc_namespace *ns, int shmid, int cmd,
> +		struct shmid_ds __user *buf, int version)
>  {
>  	struct kern_ipc_perm *ipcp;
>  	struct shmid64_ds shmid64;
> -- 
> 1.5.4.3
> 
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
