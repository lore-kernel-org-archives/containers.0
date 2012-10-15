From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: [PATCH 1/1] dev_change_net_namespace: send a KOBJ_REMOVED/KOBJ_ADD
Date: Mon, 15 Oct 2012 22:14:17 +0200
Message-ID: <507C6E99.7090906__4132.344821892$1350332099$gmane$org@free.fr>
References: <20121015174726.GA15435@sergelap>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121015174726.GA15435@sergelap>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: Daniel Lezcano <dlezcano-GANU6spQydw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Stefan Bader <stefan.bader-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, =?ISO-8859-1?Q?St=E9phane_Graber?= <stephane.graber-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Dan Kegel <dank-XdDNpL9cdsoAvxtiuMwx3w@public.gmane.org>, lxc-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

On 10/15/2012 07:47 PM, Serge Hallyn wrote:
> When a new nic is created in namespace ns1, the kernel sends a KOBJ_ADD uevent
> to ns1.  When the nic is moved to ns2, we only send a KOBJ_MOVE to ns2, and
> nothing to ns1.
>
> This patch changes that behavior so that when moving a nic from ns1 to ns2, we
> send a KOBJ_REMOVED to ns1 and KOBJ_ADD to ns2.  (The KOBJ_MOVE is still
> sent to ns2).
>
> The effects of this can be seen when starting and stopping containers in
> an upstart based host.  Lxc will create a pair of veth nics, the kernel
> sends KOBJ_ADD, and upstart starts network-instance jobs for each.  When
> one nic is moved to the container, because no KOBJ_REMOVED event is
> received, the network-instance job for that veth never goes away.  This
> was reported at https://bugs.launchpad.net/ubuntu/+source/lxc/+bug/1065589
> With this patch the networ-instance jobs properly go away.
>
> The other oddness solved here is that if a nic is passed into a running
> upstart-based container, without this patch no network-instance job is
> started in the container.  But when the container creates a new nic
> itself (ip link add new type veth) then network-interface jobs are
> created.  With this patch, behavior comes in line with a regular host.
>
> v2: also send KOBJ_ADD to new netns.  There will then be a
> _MOVE event from the device_rename() call, but that should
> be innocuous.
>
> Signed-off-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> Acked-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>

Acked-by: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

> ---
>  net/core/dev.c |    6 ++++++
>  1 file changed, 6 insertions(+)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index e2215ee..2c43aaf 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -6172,6 +6172,9 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
>  	dev_uc_flush(dev);
>  	dev_mc_flush(dev);
>  
> +	/* Send a netdev-removed uevent to the old namespace */
> +	kobject_uevent(&dev->dev.kobj, KOBJ_REMOVE);
> +
>  	/* Actually switch the network namespace */
>  	dev_net_set(dev, net);
>  
> @@ -6183,6 +6186,9 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
>  			dev->iflink = dev->ifindex;
>  	}
>  
> +	/* Send a netdev-add uevent to the new namespace */
> +	kobject_uevent(&dev->dev.kobj, KOBJ_ADD);
> +
>  	/* Fixup kobjects */
>  	err = device_rename(&dev->dev, dev->name);
>  	WARN_ON(err);
