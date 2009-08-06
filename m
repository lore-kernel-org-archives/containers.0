From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][v4][PATCH 7/7]: Define clone_extended() syscall
Date: Thu, 6 Aug 2009 13:38:58 -0700
Message-ID: <20090806203858.GH18261@count0.beaverton.ibm.com>
References: <20090806061056.GA1044@us.ibm.com>
	<20090806062505.GG5619@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090806062505.GG5619-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Aug 05, 2009 at 11:25:05PM -0700, Sukadev Bhattiprolu wrote:
> 
> Subject: [RFC][v4][PATCH 7/7]: Define clone_extended() syscall
> 
> Container restart requires that a task have the same pid it had when it was
> checkpointed. When containers are nested the tasks within the containers
> exist in multiple pid namespaces and hence have multiple pids to specify
> during restart.
> 
> This patch defines, a new system call, clone_extended() which is like clone(),
> but takes a new 'pid_set' parameter.  This parameter lets caller choose
> specific pid numbers for the child process, in the process's active and
> ancestor pid namespaces. (Descendant pid namespaces in general don't matter
> since processes don't have pids in them anyway, but see comments in
> copy_target_pids() regarding CLONE_NEWPID).
> 
> Unlike clone(), however, clone_extended() needs CAP_SYS_ADMIN, at least for
> now, to prevent unprivileged processes from misusing this interface.

It might be good to describe how, without CAP_SYS_ADMIN, the interface
could be misused (I believe this was Linus' point):

In the status quo, a malicious task must fork rapidly in order to obtain
by trial-and-error the same pid as found in a stale /var/run/foo.pid
file. Without CAP_SYS_ADMIN clone_extended() would remove the
trial-and-error element that loosely protects the system from such
malicious attacks.


Cheers,
	-Matt
