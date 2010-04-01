From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: Re: [PATCH] Add --nonetns switch to user-cr checkpoint
Date: Thu, 01 Apr 2010 19:42:24 -0400
Message-ID: <4BB52F60.1050906@cs.columbia.edu>
References: <1270046482-16053-1-git-send-email-danms@us.ibm.com>	<4BB4240F.2030706@cs.columbia.edu>
	<87wrwrclv4.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87wrwrclv4.fsf-FLMGYpZoEPULwtHQx/6qkW3U47Q5hpJU@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org


Dan Smith wrote:
> OL> I think the default behavior of 'checkpoint' should be to not
> OL> chekcpoint net-ns, at the very least in the subtree-checkpoint
> OL> case.
> 
> OL> I prefer the container case to also not include it by default.
> 
> OL> These can be tuned in the 'checkpoint' utility, or (better ?)
> OL> by using CHECKPOINT_NETNS instead of CHECKPOINT_NONETNS...
> 
> Okay, so you want to change NONETNS to NETNS and then make user-cr
> have a positive flag instead of a negative one, yes?
> 

please ;)
