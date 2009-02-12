From: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Subject: Re: [RFC v13][PATCH 00/14] Kernel based checkpoint/restart
Date: Thu, 12 Feb 2009 10:17:21 +0100
Message-ID: <20090212091721.GB1888__5053.26841162077$1234430400$gmane$org@elte.hu>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
	<1234285547.30155.6.camel@nimitz>
	<20090211141434.dfa1d079.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090211141434.dfa1d079.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org


* Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:

> On Tue, 10 Feb 2009 09:05:47 -0800
> Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> wrote:
> 
> > On Tue, 2009-01-27 at 12:07 -0500, Oren Laadan wrote:
> > > Checkpoint-restart (c/r): a couple of fixes in preparation for 64bit
> > > architectures, and a couple of fixes for bugss (comments from Serge
> > > Hallyn, Sudakvev Bhattiprolu and Nathan Lynch). Updated and tested
> > > against v2.6.28.
> > > 
> > > Aiming for -mm.
> > 
> > Is there anything that we're waiting on before these can go into -mm?  I
> > think the discussion on the first few patches has died down to almost
> > nothing.  They're pretty reviewed-out.  Do they need a run in -mm?  I
> > don't think linux-next is quite appropriate since they're not _quite_
> > aimed at mainline yet.
> > 
> 
> I raised an issue a few months ago and got inconclusively waffled at. 
> Let us revisit.
> 
> I am concerned that this implementation is a bit of a toy, and that we
> don't know what a sufficiently complete implementation will look like. 
> There is a risk that if we merge the toy we either:
> 
> a) end up having to merge unacceptably-expensive-to-maintain code to
>    make it a non-toy or
> 
> b) decide not to merge the unacceptably-expensive-to-maintain code,
>    leaving us with a toy or
> 
> c) simply cannot work out how to implement the missing functionality.
> 
> 
> So perhaps we can proceed by getting you guys to fill out the following
> paperwork:
> 
> - In bullet-point form, what features are present?

It would be nice to get an honest, critical-thinking answer on this.

What is it good for right now, and what are the known weaknesses and
quirks you can think of. Declaring them upfront is a bonus - not talking
about them and us discovering them later at the patch integration stage
is a sure receipe for upstream grumpiness.

This is an absolutely major featue, touching each and every subsystem in
a very fundamental way. It is also a cool capability worth a bit of a
maintenance pain, so we'd like to see the pros and cons nicely enumerated,
to the best of your knowledge. Most of us are just as feature-happy at
heart as you folks are, so if it can be done sanely we are on your side.

For example, one of the critical corner points: can an app programmatically 
determine whether it can support checkpoint/restart safely? Are there 
warnings/signals/helpers in place that make it a well-defined space, and
make the implementation of missing features directly actionable?

( instead of: 'silent breakage' and a wishy-washy boundary between the
  working and non-working space. Without clear boundaries there's no
  clear dynamics that extends the 'working' space beyond the demo stage. )

	Ingo
