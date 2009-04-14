From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 00/30] C/R OpenVZ/Virtuozzo style
Date: Tue, 14 Apr 2009 20:53:25 +0400
Message-ID: <20090414165325.GA27923__36723.3690493324$1239728396$gmane$org@x200.localdomain>
References: <20090410023207.GA27788@x200.localdomain>
	<alpine.LFD.2.00.0904100758410.4583@localhost.localdomain>
	<20090413073925.GB7085@x200.localdomain>
	<alpine.LFD.2.00.0904131137520.26713@localhost.localdomain>
	<20090414122906.GA20201@x200.localdomain>
	<20090414134420.GC27163@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090414134420.GC27163-X9Un+BFzKDI@public.gmane.org>
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
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Apr 14, 2009 at 03:44:20PM +0200, Ingo Molnar wrote:
> 
> * Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> 
> > On Mon, Apr 13, 2009 at 11:39:51AM -0700, Linus Torvalds wrote:
> > > 
> > > 
> > > On Mon, 13 Apr 2009, Alexey Dobriyan wrote:
> > > > 
> > > > Well, in OpenVZ everything is in kernel/cpt/ and prefixed with "cpt_"
> > > > and "rst_".
> > > 
> > > So?
> > > 
> > > We're not merging OpenVZ code _either_.
> > 
> > This is to give example of other prefixes: cpt_ and rst_
> > Are they fine?
> 
> Not really. 'rst' can be easily mistaken for 'reset' and neither 
> really tells me at a glance what they do. They are also quite 
> tongue-twisters.
> 
> See my namespace analysis and suggestions from yesterday for a 
> proper naming scheme.
> 
> The key i believe is to move away from this singular 'the world is 
> all about checkpoint and restore', and move it to a IMHO clearer 
> state_*() type of naming which really isolates all these kernel 
> state save/restore management APIs from other kernel APIs. (See my 
> mail from yesterday for details.)
> 
> kstate_*() would be another, perhaps even clearer naming scheme. 
> I.e.:
> 
>   kstate_checkpoint_XYZ()
>   kstate_restore_XYZ()
>   kstate_collect_XYZ()
>   kstate_dump_XYZ()
>   kstate_image_XYZ()
>   ...
> 
> Just _look_ at them - they are expressive at a glance, and 
> reasonably short. That is the kind of first-time impression
> we need, not a 'wtf?' moment.
> 
> I just checked, there's zero hits on "git grep \<kstate_" in the 
> kernel, so it's a pristine namespace. IMHO, go wild ...

Need to try it for real.

One minor nit. This kstate_ doesn't include quite a noticable of
in-kernel state. For example, task readahead state isn't relevant
to C/R at all. It's state but irrelevant state.
