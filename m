From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 7/7][v7] proc: Show SIG_DFL signals to init as
	"ignored" signals
Date: Tue, 20 Jan 2009 08:09:34 -0800
Message-ID: <20090120160933.GA25630@us.ibm.com>
References: <20090117202638.GA11825@us.ibm.com>
	<20090117203753.GH11825@us.ibm.com>
	<20090117221909.GB3962@redhat.com>
	<20090120010453.GA14612@us.ibm.com>
	<20090120073305.GA29130@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090120073305.GA29130-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

| 
| > | Imho, this patch can confuse the user-space. Why should we report that,
| > | say, SIGCONT is ignored by the global init?
| >
| > But it is ignored right ?
| 
| Following this logic, we can report that, say, SIG_DFL'ed SIGWINCH is always
| ignored by any task, not only by init?

Small difference with SIGWINCH though. SIGWINCH default action applies
to all processes. But the special behavior for SIGKILL only applies to
init. But yes, its an old oddity.

| I guess you already see that personally I dislike this patch ;) At least
| I'd ask you to not mix it with this series.

Ok.

| 
| But perhaps I am wrong, I can't "prove" this change is not good, I'd be
| ready to agree with majority.

I can't prove the opposite either. Will go with the majority...

Roland, Eric, Bastian. Any comments ? Should I send patches 1-6 to akpm ?

Sukadev
