From: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Subject: Re: [RFC v6][PATCH 0/9] Kernel based checkpoint/restart
Date: Thu, 9 Oct 2008 15:17:01 +0200
Message-ID: <20081009131701.GA21112__8756.97074593536$1223558439$gmane$org@elte.hu>
References: <1223461197-11513-1-git-send-email-orenl@cs.columbia.edu>
	<20081009124658.GE2952@elte.hu> <1223557122.11830.14.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1223557122.11830.14.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


* Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:

> On Thu, 2008-10-09 at 14:46 +0200, Ingo Molnar wrote:
> > * Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> wrote:
> > 
> > > These patches implement basic checkpoint-restart [CR]. This version 
> > > (v6) supports basic tasks with simple private memory, and open files 
> > > (regular files and directories only). Changes mainly cleanups. See 
> > > original announcements below.
> > 
> > i'm wondering about the following productization aspect: it would be 
> > very useful to applications and users if they knew whether it is safe to 
> > checkpoint a given app. I.e. whether that app has any state that cannot 
> > be stored/restored yet.
> 
> Absolutely!
> 
> My first inclination was to do this at checkpoint time: detect and 
> tell users why an app or container can't actually be checkpointed.  
> But, if I get you right, you're talking about something that happens 
> more during the runtime of the app than during the checkpoint.  This 
> sounds like a wonderful approach to me, and much better than what I 
> was thinking of.
> 
> What kind of mechanism do you have in mind?
> 
> int sys_remap_file_pages(...)
> {
> 	...
> 	oh_crap_we_dont_support_this_yet(current);
> }
> 
> Then the oh_crap..() function sets a task flag or something?

yeah, something like that. A key aspect of it is that is has to be very 
low-key on the source code level - we dont want to sprinkle the kernel 
with anything ugly. Perhaps something pretty explicit:

  current->flags |= PF_NOCR;

as we do the same thing today for certain facilities:

  current->flags |= PF_NOFREEZE;

you probably want to hide it behind:

  set_current_nocr();

and have a set_task_nocr() as well, in case there's some proxy state 
installed by another task.

Via such wrappers there's no overhead at all in the 
!CONFIG_CHECKPOINT_RESTART case.

Plus you could drive the debug mechanism via it as well, by using a 
trivial extension of the facility:

  set_current_nocr("CR: sys_remap_file_pages not supported yet.");
  ...
  set_task_nocr(t, "CR: PI futexes not supported yet.");

	Ingo
