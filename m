From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/2] Add socket list helper functions
Date: Tue, 13 Oct 2009 08:14:33 -0700
Message-ID: <87d44re36u.fsf@caffeine.danplanet.com>
References: <1254932945-12578-1-git-send-email-danms@us.ibm.com>
	<1254932945-12578-2-git-send-email-danms@us.ibm.com>
	<4AD39F37.2000007@librato.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4AD39F37.2000007-RdfvBDnrOixBDgjK7y7TUQ@public.gmane.org> (Oren Laadan's message of "Mon\,
	12 Oct 2009 17\:27\:19 -0400")
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

OL> IMHO this is over-engineered. This way, you place net-related
OL> knowledge in ckpt_ctx_free(), instead of isolating that sort of
OL> smarts under net/ subdir. I'd rather see the clean-up logic near
OL> the "litter" logic, so to speak.

Well, I still need to clean up the list after the deferqueue has run,
so something has to go into ckpt_ctx_free() to do that.  I can make it
a specific call like ckpt_sock_cleanup_listening() or something, but
that will still need to go in checkpoint.h so I can call it from
ctx_free()...

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org
