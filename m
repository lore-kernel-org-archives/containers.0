From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/4] Add IPv6 address checkpoint handler
Date: Fri, 16 Apr 2010 08:02:24 -0700
Message-ID: <87eiifv3sv.fsf@caffeine.danplanet.com>
References: <1270748932-26745-1-git-send-email-danms@us.ibm.com>
	<1270748932-26745-4-git-send-email-danms@us.ibm.com>
	<4BC76A65.7060909@hp.com> <87vdbs1oty.fsf@caffeine.danplanet.com>
	<4BC777C8.6050102@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4BC777C8.6050102-VXdhtT5mjnY@public.gmane.org> (Brian Haley's message of "Thu\,
	15 Apr 2010 16\:32\:08 -0400")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Brian Haley <brian.haley-VXdhtT5mjnY@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

BH> Yes, and I just realized something else.  This code:

BH> +	ret = inet6_addr_add(net, dev->ifindex, &addr->inet6_addr,
BH> +			     addr->inet6_prefix_len, IFA_F_PERMANENT,
BH> +			     INFINITY_LIFE_TIME, INFINITY_LIFE_TIME);

BH> isn't using the saved lifetimes either, so it won't ever go away.

I again have to plead ignorance here.  Do permanent addresses ever
have anything other than INFINITY_LIFE_TIME?  Assuming not, I think
it's reasonable (for now, at least) to stick to (correctly) saving and
restoring the permanent addresses.  What do you think?

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
