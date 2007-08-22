From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Use helpers to obtain task pid in printks
Date: Wed, 22 Aug 2007 15:16:10 -0700
Message-ID: <20070822151610.bcf60574.akpm@linux-foundation.org>
References: <46CC02E2.4020700@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933839AbXHVWQk@vger.kernel.org>
In-Reply-To: <46CC02E2.4020700@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Sukadev Bhattiprolu <sukadev@us.ibm.com>, Oleg Nesterov <oleg@tv-sign.ru>, Linux Containers <containers@lists.osdl.org>, devel@openvz.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

On Wed, 22 Aug 2007 13:33:22 +0400
Pavel Emelyanov <xemul@openvz.org> wrote:

> The task_struct->pid member is going to be deprecated, so start
> using the helpers (task_pid_nr/task_pid_vnr/task_pid_nr_ns) in 
> the kernel.
> 
> The first thing to start with is the pid, printed to dmesg - in 
> this case we may safely use task_pid_nr(). Besides, printks produce
> more (much more) than a half of all the explicit pid usage.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> ---
> 
> Andrew, this patch changes many code in drivers and file systems,
> so it may cause many conflicts with other fixes in -mm tree. Is
> there any way I can help with it, e.g. split it into pieces, wait
> till another -mm tree or something else?

I think we just slam it all into the tree as-is.  There will be a few
places which ended up getting missed, but we can pick those up on a second
round and then we rename task_struct.pid to
task_struct.dont_use_me_directly_pid so that any remaining, future or
out-of-tree usages of ->pid get reliably broken.
