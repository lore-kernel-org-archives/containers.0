From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: [RFC, PATCH] handle the multi-threaded init's exit() properly
Date: Tue, 7 Aug 2007 00:33:26 +0400
Message-ID: <20070806203326.GA188@tv-sign.ru>
References: <20070802212009.GA516@tv-sign.ru> <20070806131345.3322c99e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933903AbXHFUda@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070806131345.3322c99e.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Sukadev Bhattiprolu <sukadev@us.ibm.com>, Roland McGrath <roland@redhat.com>, linux-kernel@vger.kernel.org, containers@lists.osdl.org, Pavel Emelyanov <xemul@openvz.org>
List-Id: containers.vger.kernel.org

On 08/06, Andrew Morton wrote:
>
> On Fri, 3 Aug 2007 01:20:09 +0400 Oleg Nesterov <oleg@tv-sign.ru> wrote:
> 
> > 2. We are playing games with ->nsproxy->pid_ns. This code is bogus today, and
> >    it has to be changed anyway when we really support pid namespaces, just
> >    remove it.
>
> This patch broke
> 
> pid-namespaces-define-and-use-task_active_pid_ns-wrapper.patch.  This hunk:
> 
> ***************
> *** 908,915 ****
>   	if (unlikely(!tsk->pid))
>   		panic("Attempted to kill the idle task!");
>   	if (unlikely(tsk == child_reaper(tsk))) {
> - 		if (tsk->nsproxy->pid_ns != &init_pid_ns)
> - 			tsk->nsproxy->pid_ns->child_reaper = init_pid_ns.child_reaper;
>   		else
>   			panic("Attempted to kill init!");
>   	}
> --- 908,916 ----
>   	if (unlikely(!tsk->pid))
>   		panic("Attempted to kill the idle task!");
>   	if (unlikely(tsk == child_reaper(tsk))) {
> + 		if (task_active_pid_ns(tsk) != &init_pid_ns)
> + 			task_active_pid_ns(tsk)->child_reaper =
> + 					init_pid_ns.child_reaper;
>   		else
>   			panic("Attempted to kill init!");
>   	}
> 
> has no place to live any more, so I just removed it.

Ah, thanks. I should have done this patch against -mm tree.

I hope it is OK to drop this chunk of
	pid-namespaces-define-and-use-task_active_pid_ns-wrapper.patch

Because it can't work right now anyway, and Sukadev+Pavel already have
new patches on top this one which make namespace switch actually work.

Oleg.
