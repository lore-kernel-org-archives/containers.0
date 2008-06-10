From: Dave Hansen <dave@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 5/5] refresh VM committed space after a task
	migration
Date: Tue, 10 Jun 2008 10:41:28 -0700
Message-ID: <1213119688.13882.13.camel@nimitz>
References: <>  <1213054383-18137-6-git-send-email-righi.andrea@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755295AbYFJRlm@vger.kernel.org>
In-Reply-To: <1213054383-18137-6-git-send-email-righi.andrea@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrea Righi <righi.andrea@gmail.com>
Cc: balbir@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, containers@lists.osdl.org, menage@google.com, xemul@openvz.org
List-Id: containers.vger.kernel.org

On Tue, 2008-06-10 at 01:33 +0200, Andrea Righi wrote:
> +       preempt_disable();
> +       committed = atomic_long_read(&p->vm_committed_space);
> +       atomic_long_sub(committed, &old_mem->vmacct.vm_committed_space);
> +       atomic_long_add(committed, &mem->vmacct.vm_committed_space);
> +       preempt_enable();
>  out:
>         mmput(mm);
>  }

Why bother with the preempt stuff here?  What does the actually protect
against?  I assume that you're trying to keep other tasks that might run
on this CPU from seeing weird, inconsistent numbers in here.  Is there
some other looks that keeps *other* cpus from seeing this?

In any case, I think it needs a big, fat comment.

-- Dave
