From: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 00/12] Standardize c/r error reporting (v3)
Date: Tue, 03 Nov 2009 11:51:57 -0500
Message-ID: <4AF05FAD.7060007@librato.com>
References: <1257200620-15499-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1257200620-15499-1-git-send-email-serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> Here is a completely new approach, basically verbatim implementing
> Oren's recipe from last Friday.  It only implements the error part
> to replace ckpt_write_err.  The intent would be for ckpt_debug to
> also be replaced by ckpt_msg() which would be similar to ckpt_err()
> except adding a prefix to the message.
> 
> My goal is for users to be able to get real errors printed to a logfile
> for checkpoint and restart (not have to check dmesg) in ckpt-v19,
> especially for things like 'oh you're on a btrfs which is not supported'.
> Having to check dmesg seems to walk right into the 'toy implementation'
> argument.
> 
> Thanks Oren for the detailed explanation of what you want to see, and
> Matt for several excellent cleanup suggestions.
> 
> If there are no major objections then I'll add ckpt_err()s at restart
> on top of this patchset, but probably hold off on converting ckpt_debugs
> for a bit.  Note that the heavyweight semaphore means that for real
> debugging we're only increasing the chances of hiding bugs with the
> debugging, so I'm open to the idea of keeping ckpt_debug() as is.

"Heavyweight semaphore" ?

Maybe also mention that during checkpoint only one process uses this
interface - no contention;  During restart, for the most part, one
process runs at a time, except when transferring control to the the
next process in line - contention unlikely too.

Oren.
