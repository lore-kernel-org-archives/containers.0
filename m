From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: pid namespace bug ?
Date: Fri, 07 May 2010 10:51:57 +0200
Message-ID: <4BE3D4AD.1030705@free.fr>
References: <8739y6ikjr.fsf@tac.ki.iif.hu> <4BE178BC.4030201@free.fr>
	<87ljbyh1zv.fsf@tac.ki.iif.hu> <4BE18E01.3090103@free.fr>
	<87hbml2uf3.fsf@tac.ki.iif.hu> <4BE2A479.3060805@free.fr>
	<87ocgt12fb.fsf@tac.ki.iif.hu> <4BE322F1.5030500@free.fr>
	<20100506205233.GA23542@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100506205233.GA23542-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Ferenc Wagner <wferi-eEbw3PyuezQ@public.gmane.org>
List-Id: containers.vger.kernel.org

Sukadev Bhattiprolu wrote:
> Daniel Lezcano [daniel.lezcano-GANU6spQydw@public.gmane.org] wrote:
>   
>> Ferenc Wagner wrote:
>>
>>     
>>> I noticed something strange:
>>>
>>> # lxc-start -n jail -s lxc.mount.entry="/ /tmp/jail none bind 0 0" -s lxc.rootfs=/tmp/jail -s lxc.pivotdir=/mnt /bin/sleep 1000
>>> (in another terminal)
>>> # lxc-ps --lxc
>>> CONTAINER    PID TTY          TIME CMD
>>> jail        4173 pts/1    00:00:00 sleep
>>> # kill 4173
>>> (this does not kill the sleep!)
>>> # strace -p 4173
>>> Process 4173 attached - interrupt to quit
>>> restart_syscall(<... resuming interrupted call ...> = ? ERESTART_RESTARTBLOCK (To be restarted)
>>> --- SIGTERM (Terminated) @ 0 (0) ---
>>> Process 4173 detached
>>> # lxc-ps --lxc
>>> CONTAINER    PID TTY          TIME CMD
>>> jail        4173 pts/1    00:00:00 sleep
>>> # fgrep -i sig /proc/4173/status SigQ:	1/16382
>>> SigPnd:	0000000000000000
>>> SigBlk:	0000000000000000
>>> SigIgn:	0000000000000000
>>> SigCgt:	0000000000000000
>>> # kill -9 4173
>>>
>>> That is, the jailed sleep process could be killed by SIGKILL only, even
>>> though (according to strace) SIGTERM was delivered and it isn't handled
>>> specially.  Why does this happen?
>>>       
>
> Yes, SIGKILL is the only reliable way to terminate a container-init.
> container-init needs to be immune to signals from within the container
> but be open to receiving signals from parent container.  These requirements
> complicate the implementation of allowing SIGINIT/SIGTERM etc to
> container-init from parent container.
>
> Besides a realistic container-init would block such signals, in which case
> the complexity in the kernel could be viewed as unnecessary.
>   

I am not sure it is good to have the pid 1 immune against signals sent 
from outside of the container.
 From the POV of the parent process, the container init is like any 
other process and it may want to kill it with a signal (for notification 
or just terminate instead of killing it).

If the container init is a real init pid, these signals will be blocked 
but if we launch something different, eg a 'sleep', Ctrl+C won't work. 
eg: lxc-start -n foo sleep 3600 is not interruptible.

That's a bit annoying if we need to plug the container with batch 
managers or use them with HPC jobs.
