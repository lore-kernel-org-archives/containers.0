From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: add a few more ckpt_write_err()s
Date: Fri, 11 Sep 2009 17:15:45 -0400
Message-ID: <4AAABE01.1080807@librato.com>
References: <20090910223344.GA11718@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090910223344.GA11718-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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


I wonder if it can be useful to decide on a common "format", that
can be useful in the future for automatic error analysis. E.g:

"[PID %d ERR %d]: .....", for error with a specific task, and
"[PID %d ERR %d OBJ %d]: ......" for error with an object, and so on.

Or even a bit more fancy, like:

	ckpt_write_err("EO", "error message %p blah", err, obj, ptr);
			SPEC   FMT		      VARS...

Which ckpt_write_err() will translate to

	sprintf(s, "[PID %d ERR %d] FMT", VARS...);

So the SPEC "EO" (stands for ERR, OBJ) becomes "[PID %d ERR %d OBJ %d]: "
(pid is mandatory, the rest requested by the caller):
	E -> ERR %d
	O -> OBJ %d
	P -> PTR %p
	S -> SYM %pS
	etc...

?

Oren.


Serge E. Hallyn wrote:
> The main point is for new-comers to the checkpoint/restart tree to
> be able to help us debug their otherwise mysterious checkpoint failures.
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> ---
>  checkpoint/checkpoint.c |   28 +++++++++++++++++++++++-----
>  checkpoint/files.c      |   37 ++++++++++++++++++++++++++++++-------
>  checkpoint/memory.c     |   17 ++++++++++++++---
>  3 files changed, 67 insertions(+), 15 deletions(-)
> 

[...]
