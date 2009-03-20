From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] c/r: Add UTS support (v4)
Date: Fri, 20 Mar 2009 06:56:46 -0700
Message-ID: <87iqm4i9gh.fsf@caffeine.danplanet.com>
References: <1237402291-28812-1-git-send-email-danms@us.ibm.com>
	<49C2C686.2060806@cs.columbia.edu>
	<871vstdtn1.fsf@caffeine.danplanet.com>
	<49C2CDFA.4010907@cs.columbia.edu> <49C2D183.8040905@cs.columbia.edu>
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
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

OL> What got me confused was that you loop over all tasks, which is
OL> not needed because was assume they all share the name nsproxy; And
OL> in restart, you unshare() many times by the same task, so all but
OL> the last unshare() are useless.  In other words, I wonder what is
OL> the need for that loop over all processes.

You're exactly right, but this wasn't my intent.  It was left over
from the first iteration of the patch.

OL> Here is a suggestion for a simple change that is likely to be a step
OL> towards more generic solution in the future:

OL> The nsprox is a property of a task, and it is (possibly) shared. We
OL> can put the data either on the pids_arr or on the cr_hdr_task itself.
OL> For simplicity (and to work with your scheme) let's assume the former.

OL> We can extend the pids_arr to have a ns_objref field, that will hold
OL> the objref of the nxproxy. Of course, now, all pids_arr will have the
OL> same objref, or else ...  This data will follow the pids_arr data in
OL> the image.

OL> During checkpoint, we read the pids_arr from the image, and then for
OL> each objref of an nsproxy that is seen for the first time, we read
OL> the state of that nsproxy and restore a new one. (In our simple case,
OL> there will always be exactly one).

Storing an objref of the nsproxy for each task to track changes at
that level is what I did, and is the reason for the gratuitous
unshare() that is left there.  The idea was only to unshare() when I
encountered a new nsproxy objref.

However, Dave had some comments on this, which he made only on IRC.
Dave do you want to document them here for the benefit of the list?

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
