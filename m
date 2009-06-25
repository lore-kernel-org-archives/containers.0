From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH] c/r: tighten ptrace checking for checkpoint to
	PTRACE_MODE_ATTACH
Date: Thu, 25 Jun 2009 07:48:39 -0500
Message-ID: <20090625124839.GA29757@us.ibm.com>
References: <1245922467-9444-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1245922467-9444-1-git-send-email-orenl@cs.columbia.edu>
Sender: linux-security-module-owner@vger.kernel.org
To: Oren Laadan <orenl@cs.columbia.edu>
Cc: Linux Containers <containers@lists.osdl.org>, Stephen Smalley <sds@epoch.ncsc.mil>, Casey Schaufler <casey@schaufler-ca.com>, linux-security-module@vger.kernel.org, SELinux <selinux@tycho.nsa.gov>, Alexey Dobriyan <adobriyan@gmail.com>, Andrew Morgan <morgan@kernel.org>
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl@cs.columbia.edu):
> Security modules distinguish reading of process state (via proc) from
> full ptrace access using the access mode: PTRACE_MODE_{READ,ATTACH}.
> 
> Read access to /proc/pid/mem requires a full ptrace attach (for more
> details, see: http://lwn.net/Articles/282930/).
> 
> Checkpoint needs access to full process state, including memory, so
> we require PTRACE_MODE_ATTACH.
> 
> Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>

Acked-by: Serge Hallyn <serue@us.ibm.com>

thanks,
-serge

> ---
>  checkpoint/checkpoint.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
> index 325dfa3..7b141e3 100644
> --- a/checkpoint/checkpoint.c
> +++ b/checkpoint/checkpoint.c
> @@ -296,7 +296,7 @@ static int may_checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
>  		return -EAGAIN;
>  	}
> 
> -	if (!ptrace_may_access(t, PTRACE_MODE_READ)) {
> +	if (!ptrace_may_access(t, PTRACE_MODE_ATTACH)) {
>  		__ckpt_write_err(ctx, "access to task %d (%s) denied",
>  				 task_pid_vnr(t), t->comm);
>  		return -EPERM;
> -- 
> 1.6.0.4
