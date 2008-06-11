From: "Paul Menage" <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [-mm] CPU controller statistics (v5)
Date: Wed, 11 Jun 2008 01:32:30 -0700
Message-ID: <6599ad830806110132j1b3f899bx57fd3c894fd0c1c6@mail.gmail.com>
References: <20080603200515.GA25753@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080603200515.GA25753-SINUvgVNF2CyUtPGxGje5AC/G2K4zDHf@public.gmane.org>
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
To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Balaji Rao <balajirrao>
List-Id: containers.vger.kernel.org

On Tue, Jun 3, 2008 at 1:05 PM, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index e155aa7..60a25cb 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -293,6 +293,7 @@ int cgroup_is_descendant(const struct cgroup *cgrp);
>  struct cgroup_subsys {
>        struct cgroup_subsys_state *(*create)(struct cgroup_subsys *ss,
>                                                  struct cgroup *cgrp);
> +       void (*initialize)(int early);
>        void (*pre_destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
>        void (*destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
>        int (*can_attach)(struct cgroup_subsys *ss,
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 15ac0e1..77569d7 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -2553,6 +2553,9 @@ int __init cgroup_init_early(void)
>
>                if (ss->early_init)
>                        cgroup_init_subsys(ss);
> +
> +               if (ss->initialize)
> +                       ss->initialize(1);
>        }
>        return 0;
>  }
> @@ -2577,6 +2580,9 @@ int __init cgroup_init(void)
>                struct cgroup_subsys *ss = subsys[i];
>                if (!ss->early_init)
>                        cgroup_init_subsys(ss);
> +
> +               if (ss->initialize)
> +                       ss->initialize(0);
>        }

This seems a little weird - even if the subsystem didn't want early
initialization, we call its initialize() during early setup?

I assume the idea is to move away from the current model where the
subsystem is expected to initialize itself during the first call to
its create() method, when it gets passed a cgroup with a NULL parent?
I agree that was a bit icky. How about we call ss->initialize() from
cgroup_init_subsys()? Then we wouldn't need the "early" parameter,
since it would be implicit based on whether the subsystem wanted early
initialization or not.

Also, if you're adding a new subsystem method, you should document it
in Documentation/cgroups.txt

Paul
