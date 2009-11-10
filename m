From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/3] Record and restore skb header marks (v2)
Date: Tue, 10 Nov 2009 10:18:57 -0800
Message-ID: <873a4mkzu6.fsf@caffeine.danplanet.com>
References: <1256666008-8231-1-git-send-email-danms@us.ibm.com>
	<1256666008-8231-2-git-send-email-danms@us.ibm.com>
	<4AE9F6BA.8050601@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4AE9F6BA.8050601-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org> (Oren Laadan's message of "Thu\,
	29 Oct 2009 16\:10\:34 -0400")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Eesh, I just realized I never replied to this mail.  Sorry about
that.

OL> I wonder if the sanity test for mac_len and hdr_len are
OL> sufficient, or whether a more constrained test is required.

Yep, I have it changed now, along with some of the other checks.

OL> The skb->cb holds can be used by any layer to put private
OL> variables.

OL> Can the user mangle the data in there to create a disaster of some
OL> sort ?

OL> If the answer is "it's possible", and because this is per protocol
OL> data, I suggest to add a per-protocol callback to sanitize the
OL> data in this control buffer.

Okay, then my answer is "it could be possible later".  Right now, I
don't think there's anything in there that could be used to do more
harm than any of the other things we restore for TCP.  We don't
restore it for UNIX sockets.

OL> To not block this patchset infinitely, I guess you can put the
OL> details of the sanity check in a separate patch(set). But I prefer
OL> that the current set will at least mention and provision for such
OL> a mechanism.

Indeed.  I've added a lengthy comment to be included in the next
posting to cover it for now.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
