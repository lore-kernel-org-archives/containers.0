From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] c/r: Add AF_UNIX support (v3)
Date: Tue, 07 Jul 2009 08:36:46 -0700
Message-ID: <87ab3gsdwx.fsf@caffeine.danplanet.com>
References: <1245167716-28906-1-git-send-email-danms@us.ibm.com>
	<4A42E163.1080700@cs.columbia.edu>
	<871vp3x81s.fsf@caffeine.danplanet.com>
	<4A4C7AC7.3090004@cs.columbia.edu>
	<87y6r1slxz.fsf@caffeine.danplanet.com>
	<4A524B40.4040600@cs.columbia.edu>
	<87tz1psbpq.fsf@caffeine.danplanet.com>
	<4A527EB8.4060201@cs.columbia.edu>
	<87prccsfyp.fsf@caffeine.danplanet.com>
	<4A536ABF.8060708@cs.columbia.edu>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

OL> Ahh.. and forgot to ask/mention: you do need to call
OL> sock_unix_unlink() before attempting bind(), for the reasons we
OL> had discussed earlier (consider same example as above,
OL> checkpoint/restart done before the unlink(), then restart will
OL> otherwise fail).

I thought we agreed that was userspace's job?  That's why I didn't
unlink() before bind() in this version (4) of the patch either.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
