From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [PATCH] Introduce ActivePid: in /proc/self/status (v2, was	Vpid:)
Date: Thu, 16 Jun 2011 16:25:49 +0200
Message-ID: <4DFA126D.9060102@fr.ibm.com>
References: <20110615145527.4016.70157.stgit@bahia.local> <20110615190302.GA16440@redhat.com> <1308223158.8230.66.camel@bahia.local> <4DF9F657.7030605@fr.ibm.com> <20110616130613.GC19312@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110616130613.GC19312@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Greg Kurz <gkurz@fr.ibm.com>, linux-kernel@vger.kernel.org, ebiederm@xmission.com, containers@lists.osdl.org, akpm@linux-foundation.org, xemul@openvz.org
List-Id: containers.vger.kernel.org

On 06/16/2011 03:06 PM, Oleg Nesterov wrote:
> On 06/16, Cedric Le Goater wrote:
>>
>> We have a case where a task in a parent pid namespace needs to kill
>> another task in a sub pid namespace only knowing its internal pid.
>> the latter has been communicated to the parent task through a file or
>> a unix socket.
> 
> OK, thanks, this partly answers my question... But if they communicate
> anyway, it is not clear why the signal is needed.

Well, user space always finds ways to challenge the kernel.

Our case is related to HPC. The batch manager runs jobs inside lxc 
containers (using namespaces) and signals are sent to the application 
for different reasons. First, to cleanly exit but also for other more 
specific actions related to the cluster interconnects. 

>> This 'ActivePid' information in /proc is not sufficient to identity
>> the task, you also need the list of the tasks which are living in
>> the pid namespace.
> 
> Yes, I see.
> 
>> a new kill syscall could be the solution:
>>
>>     int pidns_kill(pid_t init_pid, pid_t some_pid);
>>
>> where 'init_pid' identifies the namespace and 'some_pid' identifies
>> a task in this namespace. this is very specific but why not.
> 
> Yes, I also thought about this. Should be trivial.
> 
> Or int sys_tell_me_its_pid(pid_t init_pid, pid_t some_pid).

why not. it's even better because more general.

> Just in case.... This is hack, yes, but in fact you do not need the
> kernel changes to send a signal inside the namespace. You could
> ptrace sub_init, and execute the necessary code "inside" the namespace.

hmm, I look at that.

Thanks,

C.
