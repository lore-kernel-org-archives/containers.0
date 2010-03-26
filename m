From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] C/R: Support for IPv6 addresses on network devices
Date: Fri, 26 Mar 2010 08:35:49 -0700
Message-ID: <87634jf63u.fsf@caffeine.danplanet.com>
References: <1269459625-21033-1-git-send-email-danms@us.ibm.com>
	<1269459625-21033-2-git-send-email-danms@us.ibm.com>
	<4BABC967.5090908@hp.com> <87aatwf74u.fsf@caffeine.danplanet.com>
	<4BABD594.1020301@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4BABD594.1020301-VXdhtT5mjnY@public.gmane.org> (Brian Haley's message of "Thu\,
	25 Mar 2010 17\:28\:52 -0400")
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

BH> Ok, I don't remember Dave's email.

https://lists.linux-foundation.org/pipermail/containers/2010-February/023135.html

However, now that I've gone in and done some looking and replacing my
print statements with %pI6, I think it may actually be kept in memory
in network byte order, which means I don't need to switch it.  Does
that sound right? :)

BH> Well, what does an 'ip -6 a' show before and after a checkpoint?

Yeah, I end up with an extra address.  I think ignoring the
link-local ones sounds like a good plan, for now at least.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
