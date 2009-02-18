From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: What can OpenVZ do?
Date: Tue, 17 Feb 2009 16:40:39 -0800
Message-ID: <1234917639.4816.12.camel__28529.0159787566$1234918067$gmane$org@nimitz>
References: <20090211141434.dfa1d079.akpm@linux-foundation.org>
	<1234462282.30155.171.camel@nimitz> <1234467035.3243.538.camel@calx>
	<20090212114207.e1c2de82.akpm@linux-foundation.org>
	<1234475483.30155.194.camel@nimitz>
	<20090212141014.2cd3d54d.akpm@linux-foundation.org>
	<20090213105302.GC4608@elte.hu> <1234817490.30155.287.camel@nimitz>
	<20090217222319.GA10546@elte.hu> <1234909849.4816.9.camel@nimitz>
	<20090218003217.GB25856@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090218003217.GB25856-X9Un+BFzKDI@public.gmane.org>
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
Cc: Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, mpm-VDJrAJ4Gl5ZBDgjK7y7TUQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org, hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 2009-02-18 at 01:32 +0100, Ingo Molnar wrote:
> > > Uncheckpointable should be a one-way flag anyway. We want this 
> > > to become usable, so uncheckpointable functionality should be as 
> > > painful as possible, to make sure it's getting fixed ...
> > 
> > Again, as these patches stand, we don't support checkpointing 
> > when non-simple files are opened.  Basically, if a 
> > open()/lseek() pair won't get you back where you were, we 
> > don't deal with them.
> > 
> > init does non-checkpointable things.  If the flag is a one-way 
> > trip, we'll never be able to checkpoint because we'll always 
> > inherit init's ! checkpointable flag.
> > 
> > To fix this, we could start working on making sure we can 
> > checkpoint init, but that's practically worthless.
> 
> i mean, it should be per process (per app) one-way flag of 
> course. If the app does something unsupported, it gets 
> non-checkpointable and that's it.

OK, we can definitely do that.  Do you think it is OK to run through a
set of checks at exec() time to check if the app currently has any
unsupported things going on?  If we don't directly inherit the parent's
status, then we need to have *some* time when we check it.

-- Dave
