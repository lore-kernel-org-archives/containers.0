From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 0/9] OpenVZ kernel based checkpointing/restart
Date: Tue, 21 Oct 2008 11:36:11 +0200
Message-ID: <48FDA28B.30204__31732.7800709338$1224592895$gmane$org@fr.ibm.com>
References: <1220439476-16465-1-git-send-email-major@openvz.org>	<1224286383.1848.65.camel@nimitz>	<20081020111002.GQ15171@hawkmoon.kerlabs.com>	<48FC86B2.8000606@fr.ibm.com>
	<48FCA97C.1040108@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <48FCA97C.1040108-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org, Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

>> IMHO we should look at Dmitry patchset and merge the external checkpoint 
>> code to Oren's patchset in order to checkpoint *one* process and have 
>> the process to restart itself. At this point, we can begin to talk about 
>> the restart itself, shall we have the kernel to fork the processes to be 
>> restarted ? shall we fork from userspace and implement some mechanism to 
>> have each processes to restart themselves ? etc...
>>
> 
> In both approaches, processes restart themselves, in the sense that a
> process to be restarted eventually calls "do_restart()" (or equivalent).
> 
> The only question is how processes are created. Andrew's patch creates
> everything inside the kernel. I would like to still give it a try outside
> the kernel. Everything is ready, except that we need a way to pre-select
> a PID for the new child... we never agreed on that one, did we ?

what do you mean ? like a clone_with_pid() routine ? 

> If we go ahead with the kernel-based process creation, it's easy to merge
> it to the current patch-set.

Both solution are valid. Nevertheless, I would choose the solution 
sharing existing code and being arch independent.

Now, we can start by duplicating code and see later how we could
share. But for mainline inclusion, I think that code reuse is a
faster path.

C.
