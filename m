From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 09/11] check files for checkpointability
Date: Thu, 12 Mar 2009 12:14:29 -0700
Message-ID: <1236885269.30142.106.camel__30775.2035012983$1236885462$gmane$org@nimitz>
References: <20090309173837.GC7561@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090309173837.GC7561-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2009-03-09 at 10:38 -0700, Matt Helsley wrote:
> On Thu, Mar 05, 2009 at 08:39:10AM -0800, Dave Hansen wrote:
> > +static void __scan_files_for_cr(struct files_struct *files)
> > +{
> > +	int i;
> > +
> > +	for (i = 0; i < files->fdtab.max_fds; i++) {
> > +		struct file *f = fcheck_files(files, i);
> > +		if (!f)
> > +			continue;
> > +		if (cr_file_supported(f))
> > +			continue;
> > +		files_deny_checkpointing(files);
> 
> At this point couldn't we skip the rest of the loop iterations?

As it stands, yeah.  That makes sense.

> Might it also be useful to print a path to f here? So not only would
> the log show the location in the kernel source but we'd also get some
> idea of which file caused the problem? Of course "f" isn't always
> available everywhere we call files_deny_checkpointing()..

Also a good suggestion.  That would help the readability of the warning
a bunch.

-- Dave
