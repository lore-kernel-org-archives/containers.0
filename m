From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 00/17] Standardize c/r error reporting
Date: Thu, 29 Oct 2009 18:32:06 -0400
Message-ID: <4AEA17E6.6050609@librato.com>
References: <1256849682-858-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1256849682-858-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org



serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> 
> This patchset
> 	1. defines ckpt_error() 
> 	2. allows users to pass a logfd into sys_checkpoint and
> 	   sys_restart
> 	3. Switches ckpt_write_err() to accepting a single enhanced
> 	   format string, instead of two separate formats.
> 	4. Has ckpt_write_err() call ckpt_error() to also log the
> 	   error in the user-provided logfile and syslog.
> 
> Every ckpt_error() message is prefixed by current's global pid,
> current's virtual pid, number of bytes read/written, and the
> ctx->errno.

Hmmm... I thought that we'd have:

ckpt_error() will be used _only_ when there is an error.
(will always print ctx->errno, which is assumed to be set)

ckpt_debug() will be used to report "log-able" debugging info
(will not print ctx->errno, because there wasn't any error)

_ckpt_debug() will be used to throw debugging info that isn't
logged (only goes to dmesg) and will not be compiled unless
CONFIG_CHECKPOINT_DEBUG is selected. This is useful for those
debug messages that are a pain to add remove, but that we
don't want to spit to users' logs.

Maybe rename ckpt_debug() to ckpt_log() and then _ckpt_debug()
to ckpt_debug()...

I think it's confusing for ckpt_error() to be used everywhere.

Oren.

> 
> I'm sure we'll want another round if only to alter the format,
> but I'm finding it very useful as is.
> 
> (As more callers are added I expect we'll want to add %(A) to
> the format to indicate active_pid should be printed).
> 
> -serge
