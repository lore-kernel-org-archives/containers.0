From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/4] Add IPv6 address checkpoint handler
Date: Thu, 15 Apr 2010 12:46:17 -0700
Message-ID: <87vdbs1oty.fsf@caffeine.danplanet.com>
References: <1270748932-26745-1-git-send-email-danms@us.ibm.com>
	<1270748932-26745-4-git-send-email-danms@us.ibm.com>
	<4BC76A65.7060909@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4BC76A65.7060909-VXdhtT5mjnY@public.gmane.org> (Brian Haley's message of "Thu\,
	15 Apr 2010 15\:35\:01 -0400")
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

BH> Is using IFA_F_PERMANENT correct here?  Should you save the flags
BH> from the address when checkpointing?  Permanent means it was added
BH> by the user, not by the kernel, so you could be changing things
BH> slightly.

Does the kernel create global scope addresses?  Maybe it does in some
more advanced IPv6 environments, but it seemed like excluding global
scope addresses in checkpoint meant that we only saved (and thus
restore) the permanent ones anyway.

I guess it's a better idea to just save the flags anyhow now that I
have a way to restore them.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
