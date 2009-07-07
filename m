From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] c/r: Add AF_UNIX support (v3)
Date: Tue, 07 Jul 2009 08:24:53 -0700
Message-ID: <87ljn0segq.fsf@caffeine.danplanet.com>
References: <1245167716-28906-1-git-send-email-danms@us.ibm.com>
	<4A42E163.1080700@cs.columbia.edu>
	<871vp3x81s.fsf@caffeine.danplanet.com>
	<4A4C7AC7.3090004@cs.columbia.edu>
	<87y6r1slxz.fsf@caffeine.danplanet.com>
	<4A524B40.4040600@cs.columbia.edu>
	<87tz1psbpq.fsf@caffeine.danplanet.com>
	<4A527EB8.4060201@cs.columbia.edu>
	<87prccsfyp.fsf@caffeine.danplanet.com>
	<Pine.LNX.4.64.0907071102341.24765@takamine.ncl.cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0907071102341.24765-CXF6herHY6ykSYb+qCZC/1i27PF6R63G9nwVQlTi/Pw@public.gmane.org>
	(Oren Laadan's message of "Tue\,
	7 Jul 2009 11\:15\:19 -0400 \(EDT\)")
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

OL> I'm ok with that. My only concern was CAP_NET_ADMIN - so the input
OL> should come from network people - is it ok with them to use
OL> CAP_SYS_ADMIN there "instead" ?

I meant CAP_NET_ADMIN of course :)

I'll merge that check in with the sysctl one and then see what they
have to say about the whole thing.  My guess would be that this
particular part will not be the most controversial bit :)

I'll post v5 here in a few and copy netdev.

Thanks!

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
