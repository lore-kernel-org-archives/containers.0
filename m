From: Greg Kurz <gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC v6][PATCH 0/9] Kernel based checkpoint/restart
Date: Thu, 09 Oct 2008 23:59:33 +0200
Message-ID: <1223589573.6117.66.camel__9488.10115592114$1223589762$gmane$org@localhost.localdomain>
References: <1223461197-11513-1-git-send-email-orenl@cs.columbia.edu>
	<20081009124658.GE2952@elte.hu> <1223557122.11830.14.camel@nimitz>
	<20081009131701.GA21112@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081009131701.GA21112-X9Un+BFzKDI@public.gmane.org>
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
Cc: jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2008-10-09 at 15:17 +0200, Ingo Molnar wrote:
> yeah, something like that. A key aspect of it is that is has to be very 
> low-key on the source code level - we dont want to sprinkle the kernel 
> with anything ugly. Perhaps something pretty explicit:
> 
>   current->flags |= PF_NOCR;
> 
> as we do the same thing today for certain facilities:
> 
>   current->flags |= PF_NOFREEZE;
> 
> you probably want to hide it behind:
> 
>   set_current_nocr();
> 

Being uncheckpointable is a transient and hopefully reversible state.
A set_current_cr() function is also needed and should be called at some
time to avoid abusive denials of checkpoint (DoC ?).

With the sys_remap_file_pages() example, set_current_cr() should be
called somewhere in sys_munmap() or even sys_remap_file_pages(). Some
code should be added to detect the mapping that lead the nocr state is
removed (a flag on the affected vma?) or fixed (checking the linearity
of mapping?). Would this code be low-key enough ?

> and have a set_task_nocr() as well, in case there's some proxy state 
> installed by another task.
> 
> Via such wrappers there's no overhead at all in the 
> !CONFIG_CHECKPOINT_RESTART case.
> 
> Plus you could drive the debug mechanism via it as well, by using a 
> trivial extension of the facility:
> 
>   set_current_nocr("CR: sys_remap_file_pages not supported yet.");
>   ...
>   set_task_nocr(t, "CR: PI futexes not supported yet.");
> 
> 	Ingo
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
-- 
Gregory Kurz                                     gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org
Software Engineer @ IBM/Meiosys                  http://www.ibm.com
Tel +33 (0)534 638 479                           Fax +33 (0)561 400 420

"Anarchy is about taking complete responsibility for yourself."
        Alan Moore.
