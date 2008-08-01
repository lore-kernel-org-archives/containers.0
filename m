From: Bastian Blank <bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH 1/1] namespaces: introduce sys_hijack (v11)
Date: Fri, 1 Aug 2008 11:23:18 +0200
Message-ID: <20080801092318.GA2002@wavehammer.waldi.eu.org>
References: <20080731183213.GA12033@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080731183213.GA12033-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Jul 31, 2008 at 01:32:13PM -0500, Serge E. Hallyn wrote:
> Introduce sys_hijack (for i386 and s390 only so far).  An open
> fd for a cgroup 'tasks' file is specified.  The main purpose
> is to allow entering an empty cgroup without having to keep a
> task alive in the target cgroup.

What is the problem if no task is alive in the target?

> The effect is a sort of namespace enter.  The following program
> uses sys_hijack to 'enter' all namespaces of the specified
> cgroup.

I currently fail to see what the differences to a normal cgroup attach
is.

>         For instance in one terminal, do
> 
> 	mount -t cgroup -ons cgroup /cgroup
> 	hostname
> 	  qemu
> 	ns_exec -u /bin/sh
> 	  hostname serge
>           echo $$
>             2996
> 	  cat /proc/$$/cgroup
> 	    ns:/node_2996
> 
> In another terminal then do
> 
> 	hostname
> 	  qemu
> 	cat /proc/$$/cgroup
> 	  ns:/
> 	hijack /cgroup/node_2996/tasks

Why can't this be done by a echo $$ >> /cgroup/node_2996/attach?

> 	  hostname
> 	    serge
> 	  cat /proc/$$/cgroup
> 	    ns:/node_2996

Bastian

-- 
Star Trek Lives!
