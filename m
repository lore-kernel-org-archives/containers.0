From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 8/8] check files for checkpointability
Date: Mon, 2 Mar 2009 12:35:22 -0600
Message-ID: <20090302183522.GA13447__46986.0309073285$1236019160$gmane$org@us.ibm.com>
References: <20090227203425.F3B51176@kernel> <20090227203435.98735E54@kernel>
	<20090302133754.GA8033@us.ibm.com>
	<20090302095917.6cfeda55@thinkcentre.lan>
	<1236011251.26788.450.camel@nimitz>
	<20090302112247.76bb3662@thinkcentre.lan>
	<1236015052.26788.471.camel@nimitz>
	<20090302174433.GA12708@us.ibm.com>
	<1236017600.26788.488.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1236017600.26788.488.camel@nimitz>
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
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Dave Hansen (dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> On Mon, 2009-03-02 at 11:44 -0600, Serge E. Hallyn wrote:
> > Quoting Dave Hansen (dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> > > On Mon, 2009-03-02 at 11:22 -0600, Nathan Lynch wrote:
> > > > No.. I mean what if a process 1234 does
> > > > 
> > > > f = fopen("/proc/1234/stat", "r");
> > > > 
> > > > and is then checkpointed.  Can that path be resolved during restart,
> > > > before pid 1234 is alive?
> > > 
> > > Heh, that's a good one.
> > > 
> > > It does mean that we can't do restore like this:
> > > 
> > > 	for_each_cr_task()
> > > 		restore_task_struct()
> > > 		restore_files()
> > > 		...
> > > 
> > > We have to do:
> > > 
> > > 	for_each_cr_task()
> > > 		restore_task_struct()
> > > 	for_each_cr_task()
> > > 		restore_files()
> > >
> > Which is what we actually do, right?
> 
> OK, I have a really evil one.
> 
> What if task 1234 does:
> 
> 	open(O_RDONLY, "/proc/5678/fdinfo/44");
> 
> and task 5678 does:
> 
> 	open(O_RDONLY, "/proc/5678/fdinfo/55");

Nice one.  Let's make fdinfo files uncheckpointable for now :)

-serge
