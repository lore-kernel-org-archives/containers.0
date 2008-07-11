From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: cryo and mm->arg_start
Date: Fri, 11 Jul 2008 09:38:30 -0700
Message-ID: <1215794310.9139.6.camel@nimitz>
References: <20080711131345.GA18870@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080711131345.GA18870-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, 2008-07-11 at 08:13 -0500, Serge E. Hallyn wrote:
> 
> One thing we could do here is to start extending the cryo approach
> with Eric's checkpoint-as-a-coredump (caac?).  We generate the
> tiniest of coredumps which, at first, contains nothing but
> mm->arg_start and maybe a process id.  It would be simplest if
> it also contained a filename for the real executable,

The exec model sounds reasonable to me.

But, I think the filename of the exe is going to have to be in the
checkpoint *already*.  It is mapped by at least one of the VMAs, and
will probably be dumped as a normal file-backed area.  

Now, since arg_start is already set up at exec time, it doesn't seem
unreasonable to have the theoretical fs/binfmt_cr.c set it as well.

-- Dave
