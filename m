From: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] netns: Delete virtual interfaces during namespace cleanup
Date: Tue, 07 Oct 2008 12:16:28 +0200
Message-ID: <48EB36FC.4000008@fr.ibm.com>
References: <m18wt6v7eb.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m18wt6v7eb.fsf-B27657KtZYmhTnVgQlOflh2eb7JE58TQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Id: containers.vger.kernel.org

Eric W. Biederman wrote:
> When physical devices are inside of network namespace and that
> network namespace terminates we can not make them go away.  We
> have to keep them and moving them to the initial network namespace
> is the best we can do.
> 
> For virtual devices left in a network namespace that is exiting
> we have no need to preserve them and we now have the infrastructure
> that allows us to delete them.  So delete virtual devices when we
> exit a network namespace.  Keeping the necessary user space clean up
> after a network namespace exits much more tractable.
> 
> This patch removes much of the need for user space clean up code to
> run after a network namespace exits.

I agree that will make the life easier for user space developer :)

I have a few questions about this new behaviour.

After discussing with Benjamin, this patch means an user can no longer 
manage a pool of virtual devices because they will be automatically 
destroyed when the namespace exits. I don't think it is a big concern, 
but just in case I am asking :)

Another point, at present, the virtual devices go back to the initial 
network namespace when the namespace dies, and this behaviour is used to 
track the namespace life cycle. With this patch we have no way to know 
when the network namespace has exited. So we can have the last process 
exiting the network namespace, but the network namespace can stay alive 
(eg. some sockets still have buffer to send) ?

AFAIR, Pavel told us about a patch extending the "wait" semantic and 
pass namespace options to wait for. Is that right Pavel ? Shouldn't we 
apply this path before deleting the virtual network devices ?

Thanks.
   -- Daniel

> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  net/core/dev.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 7091040..f3476d4 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4844,6 +4844,12 @@ static void __net_exit default_device_exit(struct net *net)
>  		if (dev->features & NETIF_F_NETNS_LOCAL)
>  			continue;
> 
> +		/* Delete virtual devices */
> +		if (dev->rtnl_link_ops && dev->rtnl_link_ops->dellink) {
> +			dev->rtnl_link_ops->dellink(dev);
> +			continue;
> +		}
> +
>  		/* Push remaing network devices to init_net */
>  		snprintf(fb_name, IFNAMSIZ, "dev%d", dev->ifindex);
>  		err = dev_change_net_namespace(dev, &init_net, fb_name);
