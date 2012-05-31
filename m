From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 04/12] container quota: introduce container disk quota
	data header file.
Date: Thu, 31 May 2012 13:10:58 +0400
Message-ID: <4FC735A2.4040400__47700.713229324$1338455609$gmane$org@parallels.com>
References: <1338389946-13711-1-git-send-email-jeff.liu@oracle.com>
	<1338389946-13711-5-git-send-email-jeff.liu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1338389946-13711-5-git-send-email-jeff.liu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
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

> +
> +/* Operations for quota control */
> +struct ns_quotactl_ops {
> +	int (*quota_on)(struct mnt_namespace *, int);
> +	int (*quota_off)(struct mnt_namespace *, int);
> +	int (*get_info)(struct mnt_namespace *, int, struct if_dqinfo *);
> +	int (*set_info)(struct mnt_namespace *, int, struct if_dqinfo *);
> +	int (*get_dqblk)(struct mnt_namespace *, int, qid_t,
> +			 struct fs_disk_quota *);
> +	int (*set_dqblk)(struct mnt_namespace *, int, qid_t,
> +			 struct fs_disk_quota *);
> +};
> +

That is quite bad. Just have the same signature. Which namespace you 
belong to can *always* be derived from the calling process, you should 
never need to specify that in any interface. It is of course fine to do 
that in functions internal to the kernel, but not this.

You should rethink the whole ns_quota thing. Some of it I believe will 
have to stay, I doubt we'll be able to be completely transparent. But 
the core of your changes have to be making sure a hierarchical walk over 
the valid quotas work well, finding out what are those valid quotas, etc.

The interface should be kept as unchanged as possible, and this can be 
achieved by things like automatic discover of the current namespace, and 
pre-operational container setup for the relevant files.
