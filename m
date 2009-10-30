From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 00/17] Standardize c/r error reporting
Date: Thu, 29 Oct 2009 21:12:48 -0500
Message-ID: <20091030021248.GA10379@us.ibm.com>
References: <1256849682-858-1-git-send-email-serue@us.ibm.com>
	<4AEA17E6.6050609@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4AEA17E6.6050609-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
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
> 
> 
> serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org wrote:
> > From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
> > 
> > This patchset
> > 	1. defines ckpt_error() 
> > 	2. allows users to pass a logfd into sys_checkpoint and
> > 	   sys_restart
> > 	3. Switches ckpt_write_err() to accepting a single enhanced
> > 	   format string, instead of two separate formats.
> > 	4. Has ckpt_write_err() call ckpt_error() to also log the
> > 	   error in the user-provided logfile and syslog.
> > 
> > Every ckpt_error() message is prefixed by current's global pid,
> > current's virtual pid, number of bytes read/written, and the
> > ctx->errno.
> 
> Hmmm... I thought that we'd have:
> 
> ckpt_error() will be used _only_ when there is an error.
> (will always print ctx->errno, which is assumed to be set)
> 
> ckpt_debug() will be used to report "log-able" debugging info
> (will not print ctx->errno, because there wasn't any error)
> 
> _ckpt_debug() will be used to throw debugging info that isn't
> logged (only goes to dmesg) and will not be compiled unless
> CONFIG_CHECKPOINT_DEBUG is selected. This is useful for those
> debug messages that are a pain to add remove, but that we
> don't want to spit to users' logs.
> 
> Maybe rename ckpt_debug() to ckpt_log() and then _ckpt_debug()
> to ckpt_debug()...
> 
> I think it's confusing for ckpt_error() to be used everywhere.

Agreed, and I almost changed it today but didn't.  However note
that ckpt_error really is just for errors.  So I'll just rename
ckpt_log_error()->ckpt_log_msg() (and same with *_v).

-serge
