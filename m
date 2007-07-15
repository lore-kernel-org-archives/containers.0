From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: [PATCH 3/5] Use task_pid() to find leader's pid
Date: Sun, 15 Jul 2007 16:17:50 +0400
Message-ID: <20070715121750.GA173@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761650AbXGOMRV@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Cedric Le Goater <clg@fr.ibm.com>, Dave Hansen <haveblue@us.ibm.com>, Serge Hallyn <serue@us.ibm.com>, Herbert Poetzel <herbert@13thfloor.at>, Pavel Emelianov <xemul@openvz.org>, Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

Sukadev Bhattiprolu wrote:
>
> Use task_pid() to get leader's pid since find_pid() cannot be used
> after detach_pid(). See comments in the code below for more details.
>
> ...
>
> +		 * Note: With multiple pid namespaces, active pid namespace of
> +		 * 	 a process is stored in its struct pid. The detach_pid
> +		 * 	 below frees the struct pid, so we will have no notion
> +		 * 	 of an active pid namespace until we complete the
> +		 * 	 subsequent attach_pid(). Which means - calls like
> +		 * 	 find_pid()/pid_to_nr() return NULL and cannot be used
> +		 * 	 between the detach_pid() and attach_pid() calls.

I think both the changelog and the comment are confusing,

>  		detach_pid(tsk, PIDTYPE_PID);
>  		tsk->pid = leader->pid;
> -		attach_pid(tsk, PIDTYPE_PID,  find_pid(tsk->pid));
> +		attach_pid(tsk, PIDTYPE_PID,  task_pid(leader));

because the change itself looks like an obvious performance fix, even
we don't use multiple pid namespaces. I don't think it is good idea to
add a fat comment which doesn't match the current reality, and find_pid()
should be avoided anyway.

Stupid question: why do we need to put the pid namespace into the struct
pid? Isn't it better if the user of the struct pid should know its ns?
For example, if /proc does put_pid(), that pid should be from the active
namespace.

Sukadev, could you cc me if you do that kind of changes?

Oleg.
