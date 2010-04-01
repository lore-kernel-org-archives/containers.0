From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: ckpt-v20-dev, ckpt-v21-rc1
Date: Thu, 1 Apr 2010 14:10:02 -0500
Message-ID: <20100401191001.GA8882@us.ibm.com>
References: <4BB1997B.1010901@cs.columbia.edu>
	<20100331173339.GA19371@us.ibm.com>
	<4BB42FBB.8030206@cs.columbia.edu>
	<20100401141740.GB22648@us.ibm.com>
	<1270145376.2461.12.camel@localhost>
	<1270148095.2461.14.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1270148095.2461.14.camel@localhost>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> On Thu, 2010-04-01 at 13:09 -0500, Nathan Lynch wrote:
> > On Thu, 2010-04-01 at 09:17 -0500, Serge E. Hallyn wrote:
> > > Alas after I sent this Nathan reported trouble on x86.  I haven't
> > > gotten a x86-32 partition running yet so can't reproduce.  Does
> > > anyone else have x86-32 with f12 they can test on?
> > 
> > More detail on this.  Seeing programs crash after restart on an i386 KVM
> > guest with Fedora 12 userspace, e.g.
> > 
> > bash-simple.sh[3627] general protection ip:b76d8197 sp:bfe73904 error:0
> > in libc-2.11.1.so[b760e000+16f000]
> > 
> > kernel: ckpt-v21-rc1 (v2.6.33-108-g9f4401c)
> > 
> > user-cr: ckpt-v20 ( 70a5c7630ce8dd933e60174aba6dc5cb08ea4b41) with
> > CHECKPOINT_NONETNS flag added to checkpoint calls
> 
> Confirmed that behavior is the same with user-cr ckpt-v20-dev
> (7bd883e17f25d36d66f9b550194c445df2f63e7e).
> 
> > 
> > cr_tests: master (7bd883e17f25d36d66f9b550194c445df2f63e7e) with
> > CHECKPOINT_NONETNS flag added to simple/ckpt.c.
> > 
> > The "simple" (self-checkpoint) testcase restarts successfully without
> > crashing.  Everything else seems to get crashes as above.  As far as I
> > can tell the memory map is restored correctly and from the kernel's POV
> > the restart is successful.
> > 
> > FWIW, I don't see these crashes on another KVM guest where the only
> > difference is that it is x86_64.
> 

I just (finally) finished install and setup of f12 x86 kvm container,
and it seems to be passing.  (well cloop_parallel seems to need more
than the 10 second timeout to check all tasks are restarted, but they
do restart - I do have kvm constrained with memory and cpu cgroups :).

-serge
