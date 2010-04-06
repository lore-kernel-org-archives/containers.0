From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/3] C/R: Support for IPv6 addresses on network devices
	(v2)
Date: Tue, 06 Apr 2010 09:19:20 -0700
Message-ID: <87eiisblkn.fsf@caffeine.danplanet.com>
References: <1270563183-9351-1-git-send-email-danms@us.ibm.com>
	<1270563183-9351-2-git-send-email-danms@us.ibm.com>
	<4BBB58FF.1090908@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4BBB58FF.1090908-VXdhtT5mjnY@public.gmane.org> (Brian Haley's message of "Tue\,
	06 Apr 2010 11\:53\:35 -0400")
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

BH> This will prevent the loopback address (::1) from getting
BH> checkpointed since it's host-local.  The ipv6 module will add it
BH> anyways so it's probably not a big deal.

Yep, and it does.

Thanks!

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
