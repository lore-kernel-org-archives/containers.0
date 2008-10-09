From: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Subject: Re: [RFC v6][PATCH 0/9] Kernel based checkpoint/restart
Date: Thu, 9 Oct 2008 15:44:15 +0200
Message-ID: <20081009134415.GA12135@elte.hu>
References: <1223461197-11513-1-git-send-email-orenl@cs.columbia.edu>
	<20081009124658.GE2952@elte.hu> <1223557122.11830.14.camel@nimitz>
	<20081009131701.GA21112@elte.hu> <1223559246.11830.23.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1223559246.11830.23.camel@nimitz>
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

> On Thu, 2008-10-09 at 15:17 +0200, Ingo Molnar wrote:
> > * Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote
> > > On Thu, 2008-10-09 at 14:46 +0200, Ingo Molnar wrote:
> > > > i'm wondering about the following productization aspect: it would be 
> > > > very useful to applications and users if they knew whether it is safe to 
> > > > checkpoint a given app. I.e. whether that app has any state that cannot 
> > > > be stored/restored yet.
> > > 
> > > Absolutely!
> > > 
> > > My first inclination was to do this at checkpoint time: detect and 
> > > tell users why an app or container can't actually be checkpointed.  
> > > But, if I get you right, you're talking about something that happens 
> > > more during the runtime of the app than during the checkpoint.  This 
> > > sounds like a wonderful approach to me, and much better than what I 
> > > was thinking of.
> > > 
> > > What kind of mechanism do you have in mind?
> > > 
> > > int sys_remap_file_pages(...)
> > > {
> > >       ...
> > >       oh_crap_we_dont_support_this_yet(current);
> > > }
> > > 
> > > Then the oh_crap..() function sets a task flag or something?
> > 
> > yeah, something like that. A key aspect of it is that is has to be very 
> > low-key on the source code level - we dont want to sprinkle the kernel 
> > with anything ugly. Perhaps something pretty explicit:
> > 
> >   current->flags |= PF_NOCR;
> 
> Am I miscounting, or are we out of these suckers on 32-bit platforms?

We've still got a few holes: you can pick 0x00000020, 0x00000080, 
0x00004000, 0x08000000.

> > as we do the same thing today for certain facilities:
> > 
> >   current->flags |= PF_NOFREEZE;
> > 
> > you probably want to hide it behind:
> > 
> >   set_current_nocr();
> 
> Yeah, that all looks reasonable.  Letting this be a dynamic thing 
> where you can move back and forth between the two states would make a 
> lot of sense too.  But, for now, I guess it can be a one-way trip.

there might be races as well, especially with proxy state - and 
current->flags updates are not serialized.

So maybe it should be a completely separate flag after all? Stick it 
into the end of task_struct perhaps.

	Ingo
