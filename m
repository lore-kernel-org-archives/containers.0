From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 11/15] Signal semantics
Date: Mon, 30 Jul 2007 13:34:57 +0400
Message-ID: <46ADB0C1.4000807@openvz.org>
References: <46A8B37B.6050108@openvz.org> <46A8B5C7.9040407@openvz.org>
	<20070727123153.GA92@tv-sign.ru> <46A9F54B.5050000@openvz.org>
	<20070727184604.GB1072@us.ibm.com>
	<20070727195943.GA25878@sergelap.austin.ibm.com>
	<20070727202337.GC1072@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20070727202337.GC1072-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Oleg Nesterov <oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org>
List-Id: containers.vger.kernel.org

sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
> | Quoting sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org (sukadev-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> | > Pavel Emelianov [xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org] wrote:
> | > | Oleg Nesterov wrote:
> | > | >(What about ptrace_attach() btw? If it is possible to send a signal to init
> | > | > from the "parent" namespace, perhaps it makes sense to allow ptracing as
> | > | > well).
> | > | 
> | > | ptracing of tasks fro different namespaces is not possible at all, since
> | > | strace utility determines the fork()-ed child pid from the parent's eax
> | > | register, which would contain the pid value as this parent sees his child.
> | > | But if the strace is in different namespace - it won't be able to find
> | > | this child with the pid value from parent's eax.
> | > | 
> | > | Maybe it's worth disabling cross-namespaces ptracing...
> | > 
> | > I think so too. Its probably not a serious limitation ?
> | 
> | Several people think we will implement 'namespace entering' through a
> | ptrace hack, where maybe the admin ptraces the init in a child pidns,
> | makes it fork, and makes the child execute what it wants (i.e. ps -ef).
> | 
> | You're talking about killing that functionality?
> 
> No. I was only thinking in terms of debugging container init and missed
> the namespace entering part.
> 
> Pavel, I am not sure I understand your comment about being unable to
> ptrace() a child ns. 

Ok. We have a task with pid 100, which tries to clone the new namespace.
This task fork-s and we have a new task with a couple of pids (101, 1).
Then this "init" forks again and we have the third task with pids (102, 2).
The problem is that when the 3rd task appears the return value from fork(),
that is - the new task's pid as it is seen by it's parent (2nd task), will
go to eax register (for i386) and it will be 2! But the prtaces from the
initial namespace cannot address this task with pid 2.

> BTW, I am able to gdb a process (incl container-init) from parent ns now.

Debugging separate processes is possible, but when this task starts forking
with namespaces creation - this becomes impossible.

> | 
> | -serge
> 
