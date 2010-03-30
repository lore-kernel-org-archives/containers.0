From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] C/R: Support for IPv6 addresses on network devices
Date: Tue, 30 Mar 2010 11:07:04 -0700
Message-ID: <87r5n1el9z.fsf@caffeine.danplanet.com>
References: <1269459625-21033-1-git-send-email-danms@us.ibm.com>
	<1269459625-21033-2-git-send-email-danms@us.ibm.com>
	<4BABC967.5090908@hp.com> <87aatwf74u.fsf@caffeine.danplanet.com>
	<4BABD594.1020301@hp.com> <87634jf63u.fsf@caffeine.danplanet.com>
	<4BB21A45.4050300@hp.com> <87zl1peqd4.fsf@caffeine.danplanet.com>
	<4BB22F73.60704@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4BB22F73.60704-VXdhtT5mjnY@public.gmane.org> (Brian Haley's message of "Tue\,
	30 Mar 2010 13\:05\:55 -0400")
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

BH> Well, in most cases you could ignore the global addresses as well,
BH> since if they were auto-configured they'll be generated again on
BH> the next Router Advertisement.  That's why they're removed on an
BH> ifdown, but the permanent ones aren't (any more).

So, I just checked... All of my link-local addresses have the
IFA_F_PERMANENT flag (0x80) set as well.  What am I missing?

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
