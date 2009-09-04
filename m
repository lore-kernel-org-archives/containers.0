From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/6] c/r: [pty 1/2] allow allocation of desired pty slave
Date: Fri, 4 Sep 2009 10:26:44 -0500
Message-ID: <20090904152644.GA15253@us.ibm.com>
References: <1252074054-22241-1-git-send-email-orenl@librato.com>
	<1252074054-22241-3-git-send-email-orenl@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1252074054-22241-3-git-send-email-orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Oren Laadan (orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org):
> During restart, we need to allocate pty slaves with the same
> identifiers as recorded during checkpoint. Modify the allocation code
> to allow an in-kernel caller to request a specific slave identifier.
> 
> For this, add a new field to task_struct - 'required_id'. It will
> hold the desired identifier when restoring a (master) pty.
> 
> The code in ptmx_open() will use this value only for tasks that try to
> open /dev/ptmx that are restarting (PF_RESTARTING), and if the value
> isn't CKPT_REQUIRED_NONE (-1).

So noone has indicated any preference for this versus the ptmx_create()
approach...

I'm satisfied knowing we have a working fallback in case task->required_id
is deemed unacceptable.

However I'd like to not have linux-kernel folks think us morons for not
having considered that.  Can you add a message to the changelog saying
why we're going with this approach (namely, that it lets us re-use
filp_open() instead of having to do a custom alloc_file in a new code-path,
which introduces maintenance duplication for file permission checking
paths)?

thanks,
-serge
