From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] namespaces: introduce sys_hijack (v4)
Date: Wed, 10 Oct 2007 19:06:23 +0200
Message-ID: <470D068F.8050405@fr.ibm.com>
References: <20071009200928.GA21846@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071009200928.GA21846-6s5zFf/epYLPQpwDFJZrxKsjOiXwFzmk@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
>>From 945fe66259cd0cfdc2fe846287b7821e329a558c Mon Sep 17 00:00:00 2001
> From: sergeh-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org <hallyn@kernel.(none)>
> Date: Tue, 9 Oct 2007 08:30:30 -0700
> Subject: [PATCH] namespaces: introduce sys_hijack (v4)
> 
> Move most of do_fork() into a new do_fork_task() which acts on
> a new argument, task, rather than on current.  do_fork() becomes
> a call to do_fork_task(current, ...).
> 
> Introduce sys_hijack (for x86 only so far).  It is like clone, but
>  in place of a stack pointer (which is assumed null) it accepts a
> pid.  The process identified by that pid is the one which is
> actually cloned.  Some state - include the file table, the signals
> and sighand (and hence tty), and the ->parent are taken from the
> calling process.

hmm, I'm wondering how this is going to work for a process which 
would have unshared its device (pts) namespace. How are we going 
to link the pts living in different namespaces if the stdios of the
hijacked process is using them ? like in the case of a shell, which
is certainly something we would like to hijacked.

it looks like a challenge for me. maybe I'm wrong.

C.

> The effect is a sort of namespace enter.  The following program
> uses sys_hijack to 'enter' all namespaces of the specified pid.
> For instance in one terminal, do
> 
> 	mount -t cgroup -ons /cgroup
> 	hostname
> 	  qemu
> 	ns_exec -u /bin/sh
> 	  hostname serge
>           echo $$
>             1073
> 	  cat /proc/$$/cgroup
> 	    ns:/node_1073

Is there a reason to have the 'node_' prefix ? couldn't we just
use $pid ? 

> In another terminal then do
> 
> 	hostname
> 	  qemu
> 	cat /proc/$$/cgroup
> 	  ns:/
> 	hijack 1073
> 	  hostname
> 	    serge
> 	  cat /proc/$$/cgroup
> 	    ns:/node_1073
> 
> sys_hijack is arch-dependent and is only implemented for i386 so far.

and worked on my qemu.

Thanks !

C.
