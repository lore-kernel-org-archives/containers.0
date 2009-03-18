From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: C/R review
Date: Wed, 18 Mar 2009 09:00:08 -0700
Message-ID: <1237392008.8286.149.camel__49410.3351644755$1237393045$gmane$org@nimitz>
References: <20090317210110.GA3897@x200.localdomain>
	<49C0CAB9.3080500@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49C0CAB9.3080500-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 2009-03-18 at 06:19 -0400, Oren Laadan wrote:
> >> +The checkpoint image format is composed of records consisting of a
> >> +pre-header that identifies its contents, followed by a payload. (The
> >> +idea here is to enable parallel checkpointing in the future in which
> >> +multiple threads interleave data from multiple processes into a single
> >> +stream).
> > 
> > I have my doubts about parallel checkpoint especially how large container
> > should be to need this and how much more complex code will it results in.
> 
> Doubts about the need ?   if I recall correctly IBM expressed interest in
> checkpointing containers with hundreds/thousands of processes that are
> spread among tens and hundreds of CPUs (multi-processor machine).

At the same time, I'd throw this kind of feature out the window in a
second if it meant getting a smaller or more understandable patch.  It
certainly isn't needed now.

Alexey, I'm really just assuming here, but I'd guess that a normal VPS
has a memory footprint between hundreds of MB or a few GB, right?  We're
also talking completely about RAM contents being moved here because all
the other data is a very small portion of the whole.  Unless creating
the checkpoint is maxing out one CPU, the entire problem this is solving
has to do with I/O bandwidth and availability.

If we really have I/O bandwidth problems, we should probably solve that
at the I/O level and not the checkpoint level.

My only other concern would be on systems with really high NUMA ratios.
A parallel checkpoint there just makes sense because shipping everything
across an interconnect could get really expensive.  We could move the
checkpoint process around to each node as we checkpoint its stuff, but
it would be a little silly to do a serial checkpoint on 1000 NUMA nodes
like that.

Anyway, I do think we should just concentrate on a single-stream
checkpoint for now.  We have a lot of other problems to solve before we
get to 1000 node NUMA machines.

-- Dave
