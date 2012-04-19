From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: Checking memory limit inside a container
Date: Thu, 19 Apr 2012 10:24:19 +0900
Message-ID: <4F8F6943.5020304@jp.fujitsu.com>
References: <CAPE4pjBNqeBXqUTpfnY1UyB13H0fKUiKaLW_HL0uWsrLTJ62mA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAPE4pjBNqeBXqUTpfnY1UyB13H0fKUiKaLW_HL0uWsrLTJ62mA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

(2012/04/19 8:13), Matt Chapman wrote:

> Hello,
> 
> I'm new to using LXC, but really impressed so far. I'm trying to set-up
> memory limits for a container, and have added these lines to my container
> config file:
> 
> lxc.cgroup.memory.limit_in_bytes = 15872M
> lxc.cgroup.memory.memsw.limit_in_bytes = 16896M
> 
> ...and I've stopped & restarted my container.
> 
> But from inside the container, using `free` or `top`,etc, still reports the
> total available memory as that of the host system, not what has been
> allocated to the container.
> 


Yes, now, usual commands see /proc/meminfo, it's not virtualized yet.
We have plans but...it's not implemented yet.

> Is this normal, or does it suggest I did something wrong? Is there a way to
> accurately check memory usage for a container from within that container?
> Or even from the host system?
> 


IIUC, the only way we have is

  # cat /path-to-cgroup/memory.usage_in_bytes
  # cat /path-to-cgroup/memory.stat

Or you can use some libcgroup commands as cgget...
I'm sorry if I don't know existing useful lxc memory checker.

Thanks,
-Kame
