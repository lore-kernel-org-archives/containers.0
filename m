From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v5][PATCH 0/9] Kernel based checkpoint/restart
Date: Thu, 25 Sep 2008 14:58:14 +0200
Message-ID: <48DB8AE6.2080607__28183.2801214934$1222347832$gmane$org@fr.ibm.com>
References: <1221347167-9956-1-git-send-email-orenl@cs.columbia.edu>
	<20080924214242.GA27875@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080924214242.GA27875-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Serge E. Hallyn wrote:
> Quoting Oren Laadan (orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org):
>> These patches implement basic checkpoint-restart [CR]. This version (v5)
>> supports basic tasks with simple private memory, and open files (regular
>> files and directories only). The main changes include rework of memory
>> restart code and response to feedback. See original announcements below.
>>
>> Oren.
> 
> Playing around a bit, all seems to work as advertised.
> 
> Has anyone playing with this run into any oopses with the latest
> version?
> 
> Cedric, could you send out your patch (or a pointer to them) to make
> ckpt/restart on another task work, so we can pound the core code a bit
> harder with liblxc?

sure. the user tools are in CVS for the moment :

	http://lxc.cvs.sourceforge.net/lxc/

but Daniel will probably release something soon. the lxc-checkpoint and 
lxc-restart tools are a bit too optimistic on the availability of the 
checkpoint and restart syscalls, a cleanup might be needed.

the patchset is here :

	http://legoater.free.fr/patches/2.6.27/2.6.27-rc7-lxc2/

it's based on top of current mainline and includes :

	. sysfs patches for net namespace
	. freezer subsystem
	. oren's V5 checkpoint and restart patches
	. a personal hack to do external checkpoint and restart using
	  the lxc-checkpoint and lxc-restart tools
	. some fixes
	
and also

	an old mq namespace implementation (being reworked currently)

restart is still bogus because some state is not well captured at
checkpoint time. 

I'm working on it right now !

Thanks,

C.
