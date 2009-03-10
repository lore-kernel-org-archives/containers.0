From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 00/11] track files for checkpointability
Date: Tue, 10 Mar 2009 12:45:17 -0500
Message-ID: <20090310174517.GA12101__5886.00626583702$1236707376$gmane$org@us.ibm.com>
References: <20090305163857.0C18F3FD@kernel>
	<20090310105702.43eb1402@thinkcentre.lan>
	<20090310162026.GA9354@us.ibm.com>
	<20090310122320.313491ce@thinkcentre.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090310122320.313491ce-4v5LP+xe+1byhTdZtsIeww@public.gmane.org>
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
Cc: containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
> > Quoting Nathan Lynch (ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org):
> > > Please consider this and a following patch.
> > > 
> > > >From a0fb96aa41c4d360559013cfd7f32f07f449c1c4 Mon Sep 17 00:00:00 2001
> > > From: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
> > > Date: Mon, 9 Mar 2009 22:23:02 -0500
> > > Subject: [PATCH] checkpoint: make files_deny_checkpointing print task name and pid
> > > 
> > > This lets the developer know *which* task performed an action that
> > > prevents checkpoint.
> > > 
> > > 
> > > Signed-off-by: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
> > > ---
> > >  fs/file.c                  |    2 +-
> > >  fs/open.c                  |    2 +-
> > >  include/linux/checkpoint.h |   13 +++++++------
> > >  3 files changed, 9 insertions(+), 8 deletions(-)
> > > 
> > > diff --git a/fs/file.c b/fs/file.c
> > > index 0501af6..fcb2803 100644
> > > --- a/fs/file.c
> > > +++ b/fs/file.c
> > > @@ -299,7 +299,7 @@ static void __scan_files_for_cr(struct files_struct *files)
> > >  			continue;
> > >  		if (cr_file_supported(f))
> > >  			continue;
> > > -		files_deny_checkpointing(files);
> > > +		files_deny_checkpointing(current, files);
> > 
> > Ah but you can't do this, because __scan_files_for_cr is called
> > from dupfd which is called during copy_files, right?
> 
> Are you saying that the message should identify the child instead of
> the parent as the uncheckpointable task?

Yes.  The parent may have opened the fd (or, importantly, may NOT have)
but the child is the one now getting that 'dirty' fd and being newly
marked uncheckpointable.

-serge
