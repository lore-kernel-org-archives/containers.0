From: Andrea Righi <righi.andrea@gmail.com>
Subject: Re: [RFC PATCH 5/5] refresh VM committed space after a task migration
Date: Wed, 11 Jun 2008 12:37:57 +0200 (MEST)
Message-ID: <484FAB04.2010800@gmail.com>
References: <>  <1213054383-18137-6-git-send-email-righi.andrea@gmail.com> <1213119688.13882.13.camel@nimitz>
Reply-To: righi.andrea@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755167AbYFKKjA@vger.kernel.org>
In-Reply-To: <1213119688.13882.13.camel@nimitz>
Sender: linux-kernel-owner@vger.kernel.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: balbir@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, containers@lists.osdl.org, menage@google.com, xemul@openvz.org
List-Id: containers.vger.kernel.org

Dave Hansen wrote:
> On Tue, 2008-06-10 at 01:33 +0200, Andrea Righi wrote:
>> +       preempt_disable();
>> +       committed = atomic_long_read(&p->vm_committed_space);
>> +       atomic_long_sub(committed, &old_mem->vmacct.vm_committed_space);
>> +       atomic_long_add(committed, &mem->vmacct.vm_committed_space);
>> +       preempt_enable();
>>  out:
>>         mmput(mm);
>>  }
> 
> Why bother with the preempt stuff here?  What does the actually protect
> against?  I assume that you're trying to keep other tasks that might run
> on this CPU from seeing weird, inconsistent numbers in here.  Is there
> some other looks that keeps *other* cpus from seeing this?
> 
> In any case, I think it needs a big, fat comment.

Yes, true, mem_cgroup_move_task() is called after the task->cgroups
pointer has been changed. So, even if task changes its committed space
between the atomic_long_sub() and atomic_long_add() it will be correctly
accounted in the new cgroup.

-Andrea
