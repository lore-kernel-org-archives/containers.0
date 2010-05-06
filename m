From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: pid namespace bug ?
Date: Thu, 06 May 2010 22:13:37 +0200
Message-ID: <4BE322F1.5030500@free.fr>
References: <8739y6ikjr.fsf@tac.ki.iif.hu>
	<4BE178BC.4030201@free.fr>	<87ljbyh1zv.fsf@tac.ki.iif.hu>
	<4BE18E01.3090103@free.fr>	<87hbml2uf3.fsf@tac.ki.iif.hu>
	<4BE2A479.3060805@free.fr> <87ocgt12fb.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87ocgt12fb.fsf-/U8DR9OPLL8grVaPS+uXcA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ferenc Wagner <wferi-eEbw3PyuezQ@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Ferenc Wagner wrote:

> I noticed something strange:
>
> # lxc-start -n jail -s lxc.mount.entry="/ /tmp/jail none bind 0 0" -s lxc.rootfs=/tmp/jail -s lxc.pivotdir=/mnt /bin/sleep 1000
> (in another terminal)
> # lxc-ps --lxc
> CONTAINER    PID TTY          TIME CMD
> jail        4173 pts/1    00:00:00 sleep
> # kill 4173
> (this does not kill the sleep!)
> # strace -p 4173
> Process 4173 attached - interrupt to quit
> restart_syscall(<... resuming interrupted call ...> = ? ERESTART_RESTARTBLOCK (To be restarted)
> --- SIGTERM (Terminated) @ 0 (0) ---
> Process 4173 detached
> # lxc-ps --lxc
> CONTAINER    PID TTY          TIME CMD
> jail        4173 pts/1    00:00:00 sleep
> # fgrep -i sig /proc/4173/status 
> SigQ:	1/16382
> SigPnd:	0000000000000000
> SigBlk:	0000000000000000
> SigIgn:	0000000000000000
> SigCgt:	0000000000000000
> # kill -9 4173
>
> That is, the jailed sleep process could be killed by SIGKILL only, even
> though (according to strace) SIGTERM was delivered and it isn't handled
> specially.  Why does this happen?
>   

Whow weird !

I tried with lxc-unshare -s PID sleep 3600, which does nothing more than 
unsharing a new pid namespace and I noticed the same.

I know the process 1 has some properties concerning the signals, it is 
immune against signals coming from the container maybe there is a 
problem in this area in the kernel.

Suka, does this behavior sound familiar to you ?

Happens on 2.6.31-20-generic (ubuntu) and 2.6.33 vanilla kernel.

Thanks
  -- Daniel
