From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 8/8] check files for checkpointability
Date: Mon, 02 Mar 2009 07:56:31 -0800
Message-ID: <1236009391.26788.447.camel__12492.4618904062$1236009541$gmane$org@nimitz>
References: <20090227203425.F3B51176@kernel>
	<20090227203435.98735E54@kernel>  <20090302133754.GA8033@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090302133754.GA8033-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2009-03-02 at 07:37 -0600, Serge E. Hallyn wrote:
> Quoting Dave Hansen (dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> > 
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
> > 
> > Signed-off-by: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> 
> So on a practical note, Ingo's scheme appears to be paying off.  In
> order for any program's files_struct to be checkpointable right now,
> it must be statically compiled, else ld.so (I assume) looks up
> /proc/$$/status.  So since proc is not checkpointable, the result
> is irreversibly non-checkpointable.
> 
> So...  does it make sense to mark proc as checkpointable?  Do we
> reasonably assume that the same procfile will be available at
> restart?

Can I kick and scream for a minute?  :)

dave@nimitz:~/lse/linux/2.5/linux-2.6.git$ grep -r 'struct file_operations.*{' fs/ | grep /proc/ | wc -l
51

I'll need to go actually look at (and mark) each of those.  But, the
upside is that I'll have to go look at each of those.

-- Dave
