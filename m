From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC v14][PATCH 53/54] Detect resource leaks for
	whole-container checkpoint
Date: Fri, 01 May 2009 10:26:49 -0700
Message-ID: <1241198809.29485.194.camel@nimitz>
References: <1240961064-13991-1-git-send-email-orenl@cs.columbia.edu>
	<1240961064-13991-54-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1240961064-13991-54-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, 2009-04-28 at 19:24 -0400, Oren Laadan wrote:
>  /*
>   * helper grab/drop functions:
> - *   obj_no_{drop,grab}: for objects ignored/skipped
> - *   obj_file_{drop,grab}: for file objects
> - *   obj_inode_{drop,grab}: for inode objects
> - *   obj_mm_{drop,grab}: for mm_struct objects
> - *   obj_ns_{drop,grab}: for nsproxy objects
> - *   obj_uts_ns_{drop,grab}: for uts_namespace objects
> - *   obj_ipc_ns_{drop,grab}: for ipc_namespace objects
> + *   obj_no_{drop,grab,users}: for objects ignored/skipped
> + *   obj_file_{drop,grab,users}: for file objects
> + *   obj_inode_{drop,grab,users}: for inode objects
> + *   obj_mm_{drop,grab,users}: for mm_struct objects
> + *   obj_ns_{drop,grab,users}: for nsproxy objects
> + *   obj_uts_ns_{drop,grab,users}: for uts_namespace objects
> + *   obj_ipc_ns_{drop,grab,users}: for ipc_namespace objects
>   */

I think some of this stuff is over-commented.  This is a perfect
example.  It doesn't buy us *anything* except for comments that get
easily stale.  These are away from the function declarations and they
won't even show up in greps or cscope searches for the functions.  If
anyone reads this:

+static void obj_file_drop(void *ptr)
+{
+       fput((struct file *) ptr);
+}

and can't tell that this is 'for file objects' well...  maybe they
should consider a new career in politics or something.

-- Dave
