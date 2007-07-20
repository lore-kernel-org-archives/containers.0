From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][-mm PATCH 2/8] Memory controller containers setup (v3)
Date: Fri, 20 Jul 2007 13:30:26 -0700
Message-ID: <6599ad830707201330t419458f2tba2d7a31d3b9701e@mail.gmail.com>
References: <20070720082352.20752.37209.sendpatchset@balbir-laptop>
	<20070720082416.20752.92946.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070720082416.20752.92946.sendpatchset@balbir-laptop>
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
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, YAMAMOTO Takashi <yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux MM Mailing List <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>, Eric W Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On 7/20/07, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
>
> +config CONTAINER_MEM_CONT
> +       bool "Memory controller for containers"
> +       select CONTAINERS

Andrew asked me to not use "select" in Kconfig files due to some
unspecified problems seen in the past, so my latest patchset makes the
subsystems depend on containers rather than selecting them; I prefer
the select approach over the dependency approach, but if select does
have problems then we should be consistent.

> +static struct cftype mem_container_usage = {
> +       .name = "mem_usage",
> +       .private = RES_USAGE,

For V11, the .name field should just be called something like 'usage';
the subsystem name is automatically prefixed.

> +
> +static int mem_container_create(struct container_subsys *ss,
> +                               struct container *cont)
> +{
> +       struct mem_container *mem;
> +
> +       mem = kzalloc(sizeof(struct mem_container), GFP_KERNEL);
> +       if (!mem)
> +               return -ENOMEM;
> +
> +       res_counter_init(&mem->res);
> +       cont->subsys[mem_container_subsys_id] = &mem->css;
> +       mem->css.container = cont;
> +       return 0;

For the V11 patchset, you'll want to replace these three lines with just

  return &mem->css;

> +static int mem_container_populate(struct container_subsys *ss,
> +                               struct container *cont)
> +{
> +       int rc = 0;
> +
> +       rc = container_add_file(cont, &mem_container_usage);
> +       if (rc < 0)
> +               goto err;
> +
> +       rc = container_add_file(cont, &mem_container_limit);
> +       if (rc < 0)
> +               goto err;
> +
> +       rc = container_add_file(cont, &mem_container_failcnt);
> +       if (rc < 0)
> +               goto err;

There's a container_add_files() API in V10 and above that lets you
register an array of files in one go.

> +
> +err:
> +       return rc;
> +}
> +
> +struct container_subsys mem_container_subsys = {
> +       .name = "mem_container",

Maybe just "memory" or "pages" for the container name?

Paul
