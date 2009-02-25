From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/3] c/r: Add CR_COPY() macro (v2)
Date: Wed, 25 Feb 2009 14:23:35 -0800
Message-ID: <87eixmtau0.fsf@caffeine.danplanet.com>
References: <1235585529-806-1-git-send-email-danms@us.ibm.com>
	<1235585529-806-3-git-send-email-danms@us.ibm.com>
	<20090225160841.4d727144@thinkcentre.lan>
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
To: Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

NL> No typechecking. 

I think I can make this a little better by doing what Serge suggested:

  sizeof(typeof(a)) != sizeof(typeof(b));

I was focused on the CR_COPY_BIT() variant at the time, so I didn't
think to apply it to CR_COPY.

NL> Generates a memcpy where, depending on the arguments, simple
NL> assignment would be sufficient and preferred.

The implementation that uses these in a common function to copy in
either direction could certainly apply them only where appropriate.
Further, we could have a CR_COPY() and CR_COPY_MULTI() which would use
assignment and memcpy() respectively.

NL> Anyway, checkpoint and restart should not be "symmetric" -- the
NL> restart code has to validate certain values, such as privileged
NL> registers, in the image before committing them.

As Serge (just) said, I think that it makes it pretty clear where the
special cases are.  There's no reason (that I can think of) why you
can't check all of your values before you call the symmetric copy
function during restore.  You've got to check and then copy anyway.

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
