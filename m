From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/6] cgroup: make CONFIG_NET_CLS_CGROUP and
	CONFIG_NETPRIO_CGROUP bool instead of tristate
Date: Fri, 17 Jan 2014 19:10:10 -0800 (PST)
Message-ID: <20140117.191010.934120940597677468.davem__29185.9106546783$1390014626$gmane$org@davemloft.net>
References: <1389982317-22225-1-git-send-email-tj@kernel.org>
	<1389982317-22225-2-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1389982317-22225-2-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Cc: nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tgraf-G/eBtMaohhA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Date: Fri, 17 Jan 2014 13:11:52 -0500

> net_cls and net_prio are the only cgroups which are allowed to be
> built as modules.  The savings from allowing the two controllers to be
> built as modules are tiny especially given that cgroup module support
> itself adds quite a bit of complexity.
> 
> The following are the sizes of vmlinux with both built as module and
> both built as part of the kernel image with cgroup module support
> removed.
> 
> 	text		data		bss		dec
> 	20292207	2411496		10784768	33488471
> 	20293421	2412568		10784768	33490757
> 
> The total difference is 2286 bytes.  Given that none of other
> controllers has much chance of being made a module and that we're
> unlikely to add new modular controllers, the added complexity is
> simply not justifiable.
> 
> As a first step to drop cgroup module support, this patch changes the
> two config options to bool from tristate and drops module related code
> from the two controllers.
> 
> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

Acked-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
