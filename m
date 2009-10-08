From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: pidns memory leak
Date: Wed, 7 Oct 2009 20:08:28 -0700
Message-ID: <20091008030828.GA18973@us.ibm.com>
References: <4AC5F198.2070407@fr.ibm.com> <20091006040526.GA22923@us.ibm.com>
	<4ACAFD6A.3060008@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4ACAFD6A.3060008-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Pavel Emelianov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Still digging through some traces, but below I have some questions that 
I am still trying to answer.

>
> I am not sure what you mean by 'struct pids' but what I observed is:

Ok, I see that too. If pids leak, then pid-namespace will leak too.
Do you see any leaks in proc_inode_cache ?

>
> pid_2 and pid_namespace (as they are named in /proc/slabinfo) are never  
> decremented.
>
>> And the pid_namespace does not seem to reproduce for me, with out the
>> 'ls -al /proc/...' above, or with the simpler 'ns_exec' approach to
>> creating pid namespace.
>
> I tried to write a simpler program but I failed to reproduce it.
>
>> I am going through the code for lxc-execute, but does it remount /proc  
>> in the container ?
>
> Right, the parent does a clone(NEWMNT|NEWPID|NEWIPC|NEWUTS), wait for  
> the child while this one (pid 1) 'execs' the lxc-init process. This  
> program mounts /proc and fork-exec the command passed as parameter (here  
> 'sleep 3600').
>
> Without this intermediate process, the leak *seems* not happening.
>
> If you don't access /proc/<pid>/<file>, the leak is not happening.

I could not see the code for that.  Does lxc-stop unmount /proc too ?
Or is the umount expected to happen automatically after all processes
in the container are killed ?

Sukadev
