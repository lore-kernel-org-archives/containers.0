From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH] introduce task cgroup v2
Date: Wed, 11 Jun 2008 00:45:43 -0700
Message-ID: <6599ad830806110045n6aec52ddkfb4be91b685357fe@mail.gmail.com>
References: <20080607195733.9C77.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754509AbYFKHp6@vger.kernel.org>
In-Reply-To: <20080607195733.9C77.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: containers@lists.osdl.org, LKML <linux-kernel@vger.kernel.org>, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-Id: containers.vger.kernel.org

On Sat, Jun 7, 2008 at 4:00 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> +
> +#include <linux/cgroup.h>
> +#include <linux/err.h>
> +#include <linux/cgroup_task.h>
> +
> +struct task_cgroup {
> +       struct cgroup_subsys_state css;
> +       /*
> +        * the counter to account for number of thread.
> +        */
> +       int max_tasks;
> +       int nr_tasks;
> +
> +       spinlock_t lock;
> +};

This looks rather like a res_counter. Can you resuse that rather than
implementing your own read/write/charge/uncharge routines?

Paul
