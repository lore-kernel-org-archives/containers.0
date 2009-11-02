From: serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
Subject: [PATCH 00/12] Standardize c/r error reporting (v3)
Date: Mon,  2 Nov 2009 16:23:28 -0600
Message-ID: <1257200620-15499-1-git-send-email-serue@us.ibm.com>
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

Here is a completely new approach, basically verbatim implementing
Oren's recipe from last Friday.  It only implements the error part
to replace ckpt_write_err.  The intent would be for ckpt_debug to
also be replaced by ckpt_msg() which would be similar to ckpt_err()
except adding a prefix to the message.

My goal is for users to be able to get real errors printed to a logfile
for checkpoint and restart (not have to check dmesg) in ckpt-v19,
especially for things like 'oh you're on a btrfs which is not supported'.
Having to check dmesg seems to walk right into the 'toy implementation'
argument.

Thanks Oren for the detailed explanation of what you want to see, and
Matt for several excellent cleanup suggestions.

If there are no major objections then I'll add ckpt_err()s at restart
on top of this patchset, but probably hold off on converting ckpt_debugs
for a bit.  Note that the heavyweight semaphore means that for real
debugging we're only increasing the chances of hiding bugs with the
debugging, so I'm open to the idea of keeping ckpt_debug() as is.

You can fetch this tree as branch nov2.6 of
git://git.kernel.org/pub/scm/linux/kernel/git/sergeh/linux-cr.git
or see gitweb at http://git.kernel.org/gitweb.cgi?p=linux/kernel/git/sergeh/linux-cr.git;a=shortlog;h=refs/heads/nov2.6

thanks,
-serge
