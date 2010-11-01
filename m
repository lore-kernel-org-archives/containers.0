From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Clear the objhash before completing restart,
	but delay free (v2)
Date: Mon, 01 Nov 2010 10:01:43 -0700
Message-ID: <87oca9vuyw.fsf@localhost6.localdomain6>
References: <1287496991-18207-1-git-send-email-danms@us.ibm.com>
	<4CCEE9AD.7010105@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4CCEE9AD.7010105-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> (Oren Laadan's message of
	"Mon\, 01 Nov 2010 12\:24\:13 -0400")
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, matthltc-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

OL> Does this patch solve the performance problem in freeing all
OL> the objhash entries upfront (e.g. before letting userspace
OL> resume) ?

OL> If so, is there still a performance hit for doing the 'clear'
OL> portion early before resuming the tasks ?   How much does it
OL> depend on the complexity of the hierarchy being checkpointed ?

I've actually been unable to detect any real different in performance
between this and the way it was before.  I've run it against several
different large checkpoints (multiple processes, with sockets, IPC,
many files open, etc).  I have another option for the functionality,
which is to mark only specific items as needing to be free()'d early,
but I can't discern a difference between that or this option either.
What I can discern is that this patch is more likely to prevent
similar issues in the future by making the behavior of the hash far
more generally correct, IMHO.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
