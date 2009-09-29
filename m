From: "Nikita V. Youshchenko" <yoush-/llMDZXAvAOHXe+LvDLADg@public.gmane.org>
Subject: Re: [PATCH v18 49/80] c/r: support for UTS namespace
Date: Tue, 29 Sep 2009 22:13:17 +0400
Message-ID: <200909292213.21266__24221.162175718$1254249108$gmane$org@blacky.localdomain>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
	<1253749920-18673-50-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1253749920-18673-50-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

> +static struct uts_namespace *do_restore_uts_ns(struct ckpt_ctx *ctx)
> ...
> +#ifdef CONFIG_UTS_NS
> +	uts_ns = create_uts_ns();
> +	if (!uts_ns) {
> +		uts_ns = ERR_PTR(-ENOMEM);
> +		goto out;
> +	}
> +	down_read(&uts_sem);
> +	name = &uts_ns->name;
> +	memcpy(name->sysname, h->sysname, sizeof(name->sysname));
> +	memcpy(name->nodename, h->nodename, sizeof(name->nodename));
> +	memcpy(name->release, h->release, sizeof(name->release));
> +	memcpy(name->version, h->version, sizeof(name->version));
> +	memcpy(name->machine, h->machine, sizeof(name->machine));
> +	memcpy(name->domainname, h->domainname, sizeof(name->domainname));
> +	up_read(&uts_sem);

Could you please explain what for is this down_read() / up_read() ?
You operate only on local objects: 'name' points to just-created 
uts_ns, 'h' is also local data.
