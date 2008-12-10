From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] devices cgroup: allow mkfifo
Date: Wed, 10 Dec 2008 11:39:22 +0100
Message-ID: <493F9C5A.6080807@fr.ibm.com>
References: <20081209210802.GA24549@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081209210802.GA24549-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> The devcgroup_inode_permission() hook in the devices whitelist
> cgroup has always bypassed access checks on fifos.  But the
> mknod hook did not.  The devices whitelist is only about block
> and char devices, and fifos can't even be added to the whitelist,
> so fifos can't be created at all except by tasks which have 'a'
> in their whitelist (meaning they have access to all devices).
> 
> Fix the behavior by bypassing access checks to mkfifo.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  security/device_cgroup.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/security/device_cgroup.c b/security/device_cgroup.c
> index 5ba7870..df9d491 100644
> --- a/security/device_cgroup.c
> +++ b/security/device_cgroup.c
> @@ -513,6 +513,9 @@ int devcgroup_inode_mknod(int mode, dev_t dev)
>  	struct dev_cgroup *dev_cgroup;
>  	struct dev_whitelist_item *wh;
> 
> +	if (!S_ISBLK(mode) && !S_ISCHR(mode))
> +		return 0;
> +
>  	rcu_read_lock();
> 
>  	dev_cgroup = task_devcgroup(current);

Cool thanks. I am able to create the initctl fifo now.

  -- Daniel
