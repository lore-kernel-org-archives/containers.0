From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 0/7] Expand usage of ckpt_err
Date: Thu,  5 Nov 2009 18:00:12 -0600
Message-ID: <1257465619-1777-1-git-send-email-serue@us.ibm.com>
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

This patchset expands the usage of ckpt_err().  It moves the
setting of ckpt_err (and CKPT_CTX_ERROR kflag) into ckpt_err()
itself.  It puts cktp_err()s in useful places for restart, and
in some cases improves the information in the messages.  It
also splits the old 'restore_notify_error', which used to both
set ctx->errno and wake all restarting tasks.  Since we can pass
an error to ckpt_err(), and there might be several ckpt_err()s
along a failure path, we set ctx->errno only the first time, while
we explicitly call restore_wake_all_on_error() at the end (of
do_XYZ_task()) to actually wake the remaining tasks and notify
them of the error.

The intent of this patchset is to provide an end-user with
useful info when restart fails.

It is available as branch nov5.4 of
git://git.kernel.org/pub/scm/linux/kernel/git/sergeh/linux-cr.git (gitweb at
http://git.kernel.org/gitweb.cgi?p=linux/kernel/git/sergeh/linux-cr.git;a=shortlog;h=refs/heads/nov5.4
)

thanks,
-serge
