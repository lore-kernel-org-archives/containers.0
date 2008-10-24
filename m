From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] 'kill sig -1' must only apply to caller's namespace
Date: Fri, 24 Oct 2008 13:06:46 +0200
Message-ID: <20081024110646.GA10521@redhat.com>
References: <20081023154928.GA1044@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755783AbYJXLGS@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081023154928.GA1044@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: sukadev@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@osdl.org>, "Eric W. Biederman" <ebiederm@xmission.com>, daniel@hozac.com, Pavel Emelyanov <xemul@openvz.org>, Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On 10/23, sukadev@linux.vnet.ibm.com wrote:
>
> --- a/kernel/signal.c
> +++ b/kernel/signal.c
> @@ -1144,7 +1144,8 @@ static int kill_something_info(int sig, struct siginfo *info, pid_t pid)
>  		struct task_struct * p;
>
>  		for_each_process(p) {
> -			if (p->pid > 1 && !same_thread_group(p, current)) {
> +			if (task_pid_vnr(p) > 1 &&
> +					!same_thread_group(p, current)) {

Thanks Sukadev!

Signed-off-by: Oleg Nesterov <oleg@redhat.com>

Oleg.
