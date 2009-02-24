From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 3/5] check files for checkpointability
Date: Mon, 23 Feb 2009 16:30:30 -0800
Message-ID: <1235435430.26788.212.camel__39293.4583513581$1235435711$gmane$org@nimitz>
References: <20090219182007.B4B47C1F@kernel>
	<20090219182009.1A3E8860@kernel>  <20090223234911.GB2590@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090223234911.GB2590-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2009-02-23 at 17:49 -0600, Serge E. Hallyn wrote:
> Quoting Dave Hansen (dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org): 
> > Introduce a files_struct counter to indicate whether a particular
> > file_struct has ever contained a file which can not be
> > checkpointed.  This flag is a one-way trip; once it is set, it may
> > not be unset.
> > 
> > We assume at allocation that a new files_struct is clean and may
> > be checkpointed.  However, as soon as it has had its files filled
> > from its parent's, we check it for real in __scan_files_for_cr().
> > At that point, we mark it if it contained any uncheckpointable
> > files.
> > 
> > We also check each 'struct file' when it is installed in a fd
> > slot.  This way, if anyone open()s or managed to dup() an
> > unsuppored file, we can catch it.
> 
> So what is the point of tagging the files_struct counter and
> making it a one-way trip?  Why not just check every file at
> checkpoint time?

We need both.

This allows us to tell where and when we went wrong.  Take a process
that's been running for a month.  After 5 days it did something random
to keep it from being checkpointed.  You're going to have forgotten all
about it 25 days later.  This gives us an opportunity to spit into dmesg
or just plain log it.  It also gives the app some ability to reflect and
see what its uncheckpointable attributes are.  

-- Dave
