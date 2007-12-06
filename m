From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: [PATCH] pid: sys_wait... fixes
Date: Thu, 6 Dec 2007 20:01:45 +0300
Message-ID: <20071206170145.GA10674@tv-sign.ru>
References: <m17ijsv7iu.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753882AbXLFRBN@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m17ijsv7iu.fsf@ebiederm.dsl.xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Linux Containers <containers@lists.osdl.org>, Pavel Emelyanov <xemul@openvz.org>, sukadev@us.ibm.com
List-Id: containers.vger.kernel.org

On 12/05, Eric W. Biederman wrote:
> 
> This modifies do_wait and eligible_child to take a pair of
> enum pid_type and struct pid *pid to precisely specify what
> set of processes are eligible to be waited for,  instead of the
> raw pid_t value from sys_wait4.

Personally, I like this patch very much. Not only it fixes the bug,
in my opinion it also makes the code more clean.

However at first glance it has a minor fixable problem,

> +	if (type < PIDTYPE_MAX) {
> +		if (p->pids[type].pid != pid)
>  			return 0;
>  	}

If type != PIDTYPE_PID we can't trust p->pids[type].pid unless p is a
group leader. This .pid could be just a "random value".

Oleg.

