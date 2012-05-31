From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 02/12] container quota: lock/unlock mount namespace when
	performing quotactl.
Date: Thu, 31 May 2012 13:04:24 +0400
Message-ID: <4FC73418.1040402@parallels.com>
References: <1338389946-13711-1-git-send-email-jeff.liu@oracle.com>
	<1338389946-13711-3-git-send-email-jeff.liu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1338389946-13711-3-git-send-email-jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Cc: jack-AlSwsSmVLrQ@public.gmane.org, tytso-3s7WtUTddSA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, david-FqsqvQoI3Ljby3iVrkZq2A@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, bpm-sJ/iWh9BUns@public.gmane.org, christopher.jones-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tm-d1IQDZat3X0@public.gmane.org, linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chris.mason-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, tinguely-sJ/iWh9BUns@public.gmane.org
List-Id: containers.vger.kernel.org

On 05/30/2012 06:58 PM, jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org wrote:
> Introduce two functions to lock/unlock a particular mount namespace
> when container quota operations is performed.
>
> Signed-off-by: Jie Liu<jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> ---
>   fs/namespace.c                |   17 +++++++++++++++++
>   include/linux/mnt_namespace.h |   13 +++++++++++++
>   2 files changed, 30 insertions(+), 0 deletions(-)
>
> diff --git a/fs/namespace.c b/fs/namespace.c
> index e608199..8823ba8 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -2633,3 +2633,20 @@ bool our_mnt(struct vfsmount *mnt)
>   {
>   	return check_mnt(real_mount(mnt));
>   }
> +
> +/*
> + * Lock the mount namespace when performing a particular container
> + * disk quotactl operation, especially to protect removing it.
> + */
> +void lock_mnt_ns(struct mnt_namespace *ns)
> +{
> +	down_write(&namespace_sem);
> +}
> +
> +/*
> + * Unlock the mount namespace after quotactl on that was done.
> + */
> +void unlock_mnt_ns(struct mnt_namespace *ns)
> +{
> +	up_write(&namespace_sem);
> +}
> diff --git a/include/linux/mnt_namespace.h b/include/linux/mnt_namespace.h
> index 5a8e390..ff72ed5 100644
> --- a/include/linux/mnt_namespace.h
> +++ b/include/linux/mnt_namespace.h
> @@ -9,6 +9,19 @@ extern struct mnt_namespace *copy_mnt_ns(unsigned long, struct mnt_namespace *,
>   		struct fs_struct *);
>   extern void put_mnt_ns(struct mnt_namespace *ns);
>
> +#ifdef CONFIG_NS_QUOTA
> +extern void lock_mnt_ns(struct mnt_namespace *);
> +extern void unlock_mnt_ns(struct mnt_namespace *);
> +#else
> +void lock_mnt_ns(struct mnt_namespace *)
> +{
> +}
> +
> +void unlock_mnt_ns(struct mnt_namespace *)
> +{
> +}
> +#endif
> +

Seems weird. There is nothing ns-quota specific in locking a namespace.
Also, just grabbing a lock from an outer subsystem is quite ugly. If you 
are grabbing a namespace lock, this suggests you are tweaking namespace 
data. So you should have that file provide you with a function that does 
the full operation.

Of course there are exceptions to that, but it rings a bell.
