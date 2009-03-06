From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 00/11] track files for checkpointability
Date: Fri, 6 Mar 2009 09:35:49 -0600
Message-ID: <20090306153549.GA898__40751.4399769299$1236353903$gmane$org@us.ibm.com>
References: <20090305163857.0C18F3FD@kernel>
	<20090305174037.GA2274@x200.localdomain>
	<1236280567.22399.99.camel@nimitz>
	<20090305210840.GA2499@x200.localdomain>
	<1236288427.22399.122.camel@nimitz>
	<20090305220044.GA2819@x200.localdomain>
	<1236352121.5732.80.camel@bahia>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1236352121.5732.80.camel@bahia>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg Kurz <gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Greg Kurz (gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
> On Fri, 2009-03-06 at 01:00 +0300, Alexey Dobriyan wrote:
> > On Thu, Mar 05, 2009 at 01:27:07PM -0800, Dave Hansen wrote:
> > > > Imagine, unsupported file is opened between userspace checks
> > > > for /proc/*/checkpointable and /proc/*/fdinfo/*/checkpointable
> > > > and whatever, you stil have to do all the checks inside checkpoint(2).
> > > 
> > > Alexey, we have two problems here.  I completely agree that we have to
> > > do complete and thorough checks of each file descriptor at
> > > sys_checkpoint().  Any checks made at other times should not be trusted.
> > > 
> > > The other side is what Ingo has been asking for.  How do we *know* when
> > > we are checkpointable *before* we call (and without calling)
> > 
> > This "without calling checkpoint(2)" results in much complications
> > as demonstrated.
> > 
> > task_struct and file are not like other structures because they are exposed
> > in /proc. For PROC_FS=n kernels, one can't even check.
> > 
> > You can do checkpoint(2) without actual dump. You pass, you're most
> > certainly checkpointable (with inevitable race condition in mind).
> > 
> 
> Ahhh thank you very much Alexey ! I wanted to explain this to Dave a few
> monthes ago but I failed... probably because of my poor English skills.
> 
> https://lists.linux-foundation.org/pipermail/containers/2008-October/013549.html
> 
> Why would we add checking all over the place when it MUST be done on the
> sys_checkpoint() path ? The checkpoint(2) dry-run is definitely the way
> to go.

I'm sure Dave understood that this was possible :)

But what you and Alexey are proposing does not and cannot fullfill
Ingo's requirement.

-serge
