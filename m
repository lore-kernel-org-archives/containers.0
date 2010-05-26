From: steve-TMeXKDtMCpxBDgjK7y7TUQ@public.gmane.org
Subject: Re: [PATCH 9/9][cr][v2]: Restore file-locks
Date: Wed, 26 May 2010 08:48:11 +0100
Message-ID: <20100526074811.GA19011__25833.5905884907$1274864148$gmane$org@fogou.chygwyn.com>
References: <1274238452-15382-1-git-send-email-sukadev@linux.vnet.ibm.com>
	<1274238452-15382-10-git-send-email-sukadev@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1274238452-15382-10-git-send-email-sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: matthew-Ztpu424NOJ8@public.gmane.org, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

On Tue, May 18, 2010 at 08:07:32PM -0700, Sukadev Bhattiprolu wrote:
> Restore POSIX file-locks of an application from its checkpoint image.
> 
> Read the saved file-locks from the checkpoint image and for each POSIX
> lock, call flock_set() to set the lock on the file.
> 
> As pointed out by Matt Helsley, no special handling is necessary for a
> process P2 in the checkpointed container that is blocked on a lock, L1
> held by another process P1.  Since processes in the restarted container
> begin execution only after all processes have restored. If the blocked
> process P2 is restored first, first, it will prepare to return an
> -ERESTARTSYS from the fcntl() system call, but wait for P1 to be
> restored. When P1 is restored, it will re-acquire the lock L1 before P1
> and P2 begin actual execution. This ensures that even if P2 is scheduled
> to run before P1, P2 will go back to waiting for the lock L1.
>
Does that imply certain conditions wrt checkpointed processes and
NFS exports? I'm not sure I exactly undertstand the use case which
this is intended to address.

I was hoping to figure out whether it would also still be safe on
a cluster filesystem as well,

Steve.
