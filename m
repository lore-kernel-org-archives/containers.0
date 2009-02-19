From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 7/7][v8] SI_USER: Masquerade si_pid when crossing pid ns boundary
Date: Thu, 19 Feb 2009 08:11:06 -0800
Message-ID: <m1y6w21k6d.fsf@fess.ebiederm.org>
References: <20090219030207.GA18783@us.ibm.com>
	<20090219030743.GG18990@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753745AbZBSQLV@vger.kernel.org>
In-Reply-To: <20090219030743.GG18990@us.ibm.com> (Sukadev Bhattiprolu's message of "Wed\, 18 Feb 2009 19\:07\:43 -0800")
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, Oleg Nesterov <oleg@tv-sign.ru>, roland@redhat.com, daniel@hozac.com, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com> writes:

> From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
> Date: Wed, 24 Dec 2008 14:14:18 -0800
> Subject: [PATCH 7/7][v8] SI_USER: Masquerade si_pid when crossing pid ns
> boundary
>
> When sending a signal to a descendant namespace, set ->si_pid to 0 since
> the sender does not have a pid in the receiver's namespace.
>
> Note:
> 	- If rt_sigqueueinfo() sets si_code to SI_USER when sending a
> 	  signal across a pid namespace boundary, the value in ->si_pid
> 	  will be cleared to 0.
>
> Changelog[v5]:
> 	- (Oleg Nesterov) Address both sys_kill() and sys_tkill() cases
> 	  in send_signal() to simplify code (this drops patch 7/7 from
> 	  earlier version of patchset).
>
> Signed-off-by: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
> ---
>  kernel/signal.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>
> diff --git a/kernel/signal.c b/kernel/signal.c
> index c94355b..a416d77 100644
> --- a/kernel/signal.c
> +++ b/kernel/signal.c
> @@ -883,6 +883,8 @@ static int __send_signal(int sig, struct siginfo *info,
> struct task_struct *t,
>  			break;
>  		default:
>  			copy_siginfo(&q->info, info);
> +			if (from_ancestor_ns)
> +				q->info.si_pid = 0;

This is wrong.  siginfo is a union and you need to inspect
code to see if si_pid is present in the current union.


Eric
