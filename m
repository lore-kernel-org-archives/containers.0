From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 4/5] Setup the control group
Date: Mon, 01 Oct 2007 19:18:28 +0530
Message-ID: <4700FAAC.2050004@linux.vnet.ibm.com>
References: <46F91841.9070708@openvz.org> <46F91A1E.2060303@openvz.org>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <46F91A1E.2060303-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Christoph Lameter <clameter-sJ/iWh9BUns@public.gmane.org>
List-Id: containers.vger.kernel.org

Pavel Emelyanov wrote:
> Attach the controller to the control groups. This will work
> with the SLUB allocator only. However, if we need I can
> port this on SLAB (and maybe SLOB ;) ).
> 
> This setup is simple and stupid.
> 

That makes it easier for me to review it:)

> +static struct cftype kmem_files[] = {
> +	{
> +		.name = "usage",
> +		.private = RES_USAGE,
> +		.read = kmem_container_read,
> +	},
> +	{
> +		.name = "limit",
> +		.private = RES_LIMIT,
> +		.write = kmem_container_write,
> +		.read = kmem_container_read,
> +	},
> +	{
> +		.name = "failcnt",
> +		.private = RES_FAILCNT,
> +		.read = kmem_container_read,
> +	},
> +};
> +

Could we make the user interface similar to the one in the memory
controller please! It would make it easier for users to configure
and control both.

> +static int kmem_populate(struct cgroup_subsys *ss, struct cgroup *cnt)
> +{
> +	return cgroup_add_files(cnt, ss, kmem_files, ARRAY_SIZE(kmem_files));
> +}
> +
> +struct cgroup_subsys kmem_subsys = {
> +	.name = "kmem",
> +	.create = kmem_create,
> +	.destroy  = kmem_destroy,
> +	.populate = kmem_populate,
> +	.subsys_id = kmem_subsys_id,
> +	.early_init = 1,
> +};
> 


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
