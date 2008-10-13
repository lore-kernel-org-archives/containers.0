From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v6][PATCH 0/9] Kernel based checkpoint/restart
Date: Mon, 13 Oct 2008 10:13:09 +0200
Message-ID: <48F30315.1070909__45828.2499727376$1223885890$gmane$org@fr.ibm.com>
References: <1223461197-11513-1-git-send-email-orenl@cs.columbia.edu>	<20081009124658.GE2952@elte.hu>
	<1223557122.11830.14.camel@nimitz>	<20081009131701.GA21112@elte.hu>
	<1223559246.11830.23.camel@nimitz>	<20081009134415.GA12135@elte.hu>
	<1223571036.11830.32.camel@nimitz> <20081010153951.GD28977@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081010153951.GD28977-X9Un+BFzKDI@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Cc: jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>, Andrey Mirkin <major-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

Ingo Molnar wrote:
> * Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> 
>> On Thu, 2008-10-09 at 15:44 +0200, Ingo Molnar wrote:
>>> there might be races as well, especially with proxy state - and 
>>> current->flags updates are not serialized.
>>>
>>> So maybe it should be a completely separate flag after all? Stick it 
>>> into the end of task_struct perhaps.
>> What do you mean by proxy state?  nsproxy?
> 
> it's a concept: one task installing some state into another task (which 
> state must be restored after a checkpoint event), while that other task 
> is running. Such as a pi-futex state for example.
> 
> So a task can acquire state not just by its own doing, but via some 
> other task too.

thinking aloud,

hmm, that's rather complex, because we have to take into account the 
kernel stack, no ? This is what Andrey was trying to solve in his patchset 
back in September :

	http://lkml.org/lkml/2008/9/3/96

the restart phase simulates a clone and switch_to to (not) restore the kernel 
stack. right ? 

the self checkpoint and self restore syscalls, like Oren is proposing, are 
simpler but they require the process cooperation to be triggered. we could
image doing that in a special signal handler which would allow us to jump
in the right task context. 

I don't have any preference but looking at the code of the different patchsets
there are some tricky areas and I'm wondering which path is easier, safer, 
and portable. 

C.
