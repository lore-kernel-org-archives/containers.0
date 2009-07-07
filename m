From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] c/r: Add AF_UNIX support (v3)
Date: Tue, 07 Jul 2009 09:04:54 -0700
Message-ID: <871vosscm1.fsf@caffeine.danplanet.com>
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
	<87ab3gsdwx.fsf@caffeine.danplanet.com>
	<4A536E44.6050601@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A536E44.6050601-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> (Oren Laadan's message of
	"Tue\, 07 Jul 2009 11\:48\:20 -0400")
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

OL> I don't recall such a conclusion.

Maybe this will lead you to a pointer in your IRC logs:

  Jun 11 13:51:53 *       orenl in favor of dansmith

OL> I argued that it it's kernel's job. I suppose we agree that such
OL> pathnames should always be unlinked - so it isn't policy based.
OL> Therefore, I don't see a good reason to have userspace scan the
OL> checkpoint image data just to find such sockets and make them
OL> disappear ...

I'm not really interested in arguing about it again, so I'll just put
it in and move on.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
