From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 00/22] Standardize c/r error reporting (v2)
Date: Fri, 30 Oct 2009 18:00:22 -0500
Message-ID: <1256943629-4531-1-git-send-email-serue@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

From: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

This patchset does the following:
        1. defines ckpt_error()
        2. allows users to pass a logfd into sys_checkpoint and
           sys_restart
        3. Switches ckpt_write_err() to accepting a single enhanced
           format string, instead of two separate formats.
        4. Has ckpt_write_err() call ckpt_error() to also log the
           error in the user-provided logfile and syslog.

Every ckpt_error() message is prefixed by current's global pid, current's
virtual pid, number of bytes read/written, and the ctx->errno.

I'm sending just the meaningful patches this time:

	0001-Make-__ckpt_generate_fmt-public.patch
	0002-Add-format-and-message-buffers-to-ctx-and-make-err_s.patch
	0003-switch-ckpt_generate_err-to-use-ctx-fields.patch
	0004-Change-to-the-new-enhanced-error-string-format.patch
	0013-add-logfd-to-c-r-api.patch
	0014-define-ckpt_error-and-implement-ckpt_do_write_msg.patch
	0015-explain-locking-for-write_err_msg.patch

The full rebased, re-split patchset can be seen at:
	http://git.kernel.org/gitweb.cgi?p=linux/kernel/git/sergeh/linux-cr.git;a=shortlog;h=refs/heads/debuglog-clean
The patches which I am not sending are all just changing the the callers of
ckpt_write_err() or ckpt_debug().

You can see all the changes relative to the patchset I sent yesterday by
looking at the non-rebased branch at:
	http://git.kernel.org/gitweb.cgi?p=linux/kernel/git/sergeh/linux-cr.git;a=shortlog;h=refs/heads/debuglog-nonrebased

-serge
