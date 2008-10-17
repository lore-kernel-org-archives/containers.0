From: David Newall <davidn-KzQzY1MbaKjAHznzqCTclw@public.gmane.org>
Subject: Re: [RFC v6][PATCH 0/9] Kernel based checkpoint/restart
Date: Fri, 17 Oct 2008 17:00:57 +1030
Message-ID: <48F83121.7070705__1622.51399965516$1224225205$gmane$org@davidnewall.com>
References: <1223461197-11513-1-git-send-email-orenl@cs.columbia.edu>	<20081009124658.GE2952@elte.hu>	<1223557122.11830.14.camel@nimitz>	<20081009131701.GA21112@elte.hu>	<1223559246.11830.23.camel@nimitz>	<20081009134415.GA12135@elte.hu>	<1223571036.11830.32.camel@nimitz>	<20081010153951.GD28977@elte.hu>	<48F30315.1070909@fr.ibm.com>	<1223916223.29877.14.camel@nimitz>	<48F6092D.6050400@fr.ibm.com>	<48F685A3.1060804@cs.columbia.edu>	<48F7352F.3020700@fr.ibm.com>	<48F74674.20202@cs.columbia.edu>
	<87r66g8875.wl%peter@chubb.wattle.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87r66g8875.wl%peter-LkDQP0DxSMGxwJ88Py/mJxCuuivNXqWP@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Chubb <peterc-M3ycANVxPotyL3EAZA59ERCuuivNXqWP@public.gmane.org>
Cc: jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Peter Chubb wrote:
>>>>>> "Oren" == Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> writes:
>>>>>>             
>
> Oren> Daniel Lezcano wrote:
>
>   
>>>> The one exception (and it is a tedious one !) are states in which
>>>> the task is already frozen by definition: any ptrace blocking
>>>> point where the tracee waits for the tracer to grant permission to
>>>> proceed with its execution. Another example is in vfork(), waiting
>>>> for completion.
>>>>         
>>> I would say these are perfect places for "may be
>>> non-checkpointable" :)
>>>       
>
> Oren> For now, yes. But we definitely want this capability in the long
> Oren> run; otherwise we won't be able to checkpoint a kernel compile
> Oren> ('make' uses vfork), or anything with 'gdb' running inside, or
> Oren> 'strace', and other goodies.
>
> The strace/gdb example is *really* hard; but for vfork, you just wait
> until it's over. The interval between vfork and exec/exit should be
> short enough not to affect the overall time for a checkpoint

A malicious user could trivially exploit that.
