From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] c/r: Take uts_sem during checkpoint and restart
Date: Thu, 16 Apr 2009 09:47:45 -0700
Message-ID: <87bpqwa6ku.fsf@caffeine.danplanet.com>
References: <1239897585-19246-1-git-send-email-danms@us.ibm.com>
	<20090416163340.GB20736@us.ibm.com>
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
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

SH> At checkpoint, you only need the uts_sem right around the reading
SH> (and length-checking) of uts_ns->name.  You're keeping it around
SH> writing into the checkpoint image (and cr_hbuf_get).

Right, okay.

SH> At restart, you shouldn't actually need uts_sem - the nsproxy is
SH> not yet available to anyone else, so there is no chance of a race,
SH> right?  Hmm, well maybe I'm being overly optimistic, since restart
SH> is coordinated by userspace which could mess up and somehow run
SH> sethostname(2) while it's supposed to be running sys_restart().
SH> But then sys_restart() wouldn't yet have hooked up the task to the
SH> new nsproxy.

Good, you passed the test.  Yeah, that's it... :)

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
