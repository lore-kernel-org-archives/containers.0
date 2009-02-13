From: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Subject: Re: [PATCH] User namespaces: Only put the userns when we unhash
	the uid
Date: Fri, 13 Feb 2009 15:21:14 +0100
Message-ID: <20090213142114.GA24047@elte.hu>
References: <20090213140421.5698.86876.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090213140421.5698.86876.stgit-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>, vegard.nossum-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, snakebyte-Mmb7MZpHnFY@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jmorris-JSZrJrUvVKb1P9xLtpHBDw@public.gmane.org, torvalds-3NddpPZAyC0@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org


* David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

> From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> uids in namespaces other than init don't get a sysfs entry.
> 
> For those in the init namespace, while we're waiting to remove
> the sysfs entry for the uid the uid is still hashed, and
> alloc_uid() may re-grab that uid without getting a new
> reference to the user_ns, which we've already put in free_user
> before scheduling remove_user_sysfs_dir().
> 
> Reported-by: KOSAKI Motohiro <kosaki.motohiro-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> Acked-by: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Tested-by: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>

beyond the crashes, this should resolve this slab corruption
regression too:

Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=12503
Subject         : [slab corruption] BUG key_jar: Poison overwritten
Submitter       : Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Date            : 2009-01-15 18:16 (25 days old)
References      : http://marc.info/?l=linux-kernel&m=123204353425825&w=4
Handled-By      : David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

	Ingo
