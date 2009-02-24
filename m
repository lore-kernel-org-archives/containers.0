From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 3/5] check files for checkpointability
Date: Tue, 24 Feb 2009 11:47:19 -0800
Message-ID: <1235504839.26788.300.camel__3059.35044675625$1235505286$gmane$org@nimitz>
References: <20090219182007.B4B47C1F@kernel>
	<20090219182009.1A3E8860@kernel> <20090223234911.GB2590@us.ibm.com>
	<1235435430.26788.212.camel@nimitz> <20090224011037.GB4797@us.ibm.com>
	<1235438459.26788.222.camel@nimitz> <20090224194329.GC24007@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090224194329.GC24007-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2009-02-24 at 13:43 -0600, Serge E. Hallyn wrote:
> Quoting Dave Hansen (dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> > On Mon, 2009-02-23 at 19:10 -0600, Serge E. Hallyn wrote:
> > > > This allows us to tell where and when we went wrong.  Take a process
> > > > that's been running for a month.  After 5 days it did something random
> > > > to keep it from being checkpointed.  You're going to have forgotten all
> > > > about it 25 days later.  This gives us an opportunity to spit into dmesg
> > > > or just plain log it.  It also gives the app some ability to reflect and
> > > > see what its uncheckpointable attributes are.  
> > > 
> > > Hmm.  In that case, rather than refuse checkpoint, I prefer that we make
> > > this a footnote in the /proc/$$/checkpointable output.
> > 
> > Yeah, that's cool.  If we were smart, we'd also get hooked into some of
> > the ftrace output so that we have a real chance of logging these things
> > and being able to go look at something about them down the line.
> 
> How exactly woudl that work?  Would that work as a *replacement* for
> filling up the logs as I was recommending?  If so I'm all for it...

I think it would be a replacement for dmesg, at least.  

-- Dave
