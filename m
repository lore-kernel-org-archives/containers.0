From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/3] Add _ckpt_read_hdr_type() helper
Date: Wed, 01 Jul 2009 11:28:44 -0700
Message-ID: <87my7oxnoj.fsf@caffeine.danplanet.com>
References: <1246472414-23105-1-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1246472414-23105-1-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> (Dan Smith's
	message of "Wed\, 1 Jul 2009 11\:20\:12 -0700")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Ack, I meant to patchbomb these with some intro text.

This set of patches includes the helper that Oren suggested to make
reading in the socket buffers more efficient as well as updates to the
UNIX and INET patches as suggested by Oren and Matt.  There are a few
things not addressed which I asked for clarification on earlier.

I think these are getting close to the point where we can solicit some
"comments" from the netdev folks.  I'll let these fester here for the
rest of the week and then plan to post them to netdev for comments on
Monday.  I will plan to procure some flame-retardant clothing over the
weekend.

Thanks!

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
