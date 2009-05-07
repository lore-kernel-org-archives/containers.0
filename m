From: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Subject: Re: [PATCH] x86: ptrace debugreg checks rewrite
Date: Thu, 7 May 2009 11:13:57 +0200
Message-ID: <20090507091357.GA26433__9497.21143483675$1241687847$gmane$org@elte.hu>
References: <20090504001601.GL16631@x200.localdomain>
	<20090504002431.GA17556@x200.localdomain>
	<20090506095629.GC15323@elte.hu>
	<20090506203852.D9AC9FC39E@magilla.sf.frob.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090506203852.D9AC9FC39E-nL1rrgvulkc2UH6IwYuUx0EOCMrvLtNR@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, "K.Prasad" <prasad-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org


* Roland McGrath <roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

> > > On Mon, May 04, 2009 at 04:16:01AM +0400, Alexey Dobriyan wrote:
> > > > +static int ptrace_check_debugreg(int _32bit,
> > > > +				 unsigned long dr0, unsigned long dr1,
> > > > +				 unsigned long dr2, unsigned long dr3,
> > > > +				 unsigned long dr6, unsigned long dr7)
> > > > +{
> > > > +	/* Breakpoint type: 00: --x, 01: -w-, 10: undefined, 11: rw- */
> > > > +	unsigned int rw[4];
> > > > +	/* Breakpoint length: 00: 1 byte, 01: 2 bytes, 10: 8 bytes, 11: bytes */
> > > 								        4 bytes, of course
> > 
> > Roland, Oleg, do you have any pending/planned changes in this area?
> 
> I don't.  I expect the only future work on this arch debugreg 
> stuff to be via the hw_breakpoint work, extending that and/or 
> building new things on it.

Yes. That work, despite being in its upteenth iteration, is taking a 
frustratingly long amount of time to get even to a minimal "review 
passed, lets commit and test this in a tree a bit" intermediate 
stage though.

I've Cc:-ed K.Prasad and Alan Stern. Roland, Oleg, would you be 
interested in having a look at that thread, to help drive it 
forward?

The last iteration was posted to lkml on Apr 24:

  [Patch 00/12] Hardware Breakpoint Interfaces

and it has a good deal of ptrace, signal handling and other impact 
as well.

	Ingo
