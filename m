From: "Jose R. Santos" <jrs-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] c/r: Initialize msg_msg security pointer at restart.
Date: Wed, 30 Mar 2011 23:24:35 -0500
Message-ID: <20110330232435.21bdafc8@gara>
References: <1301512246-32114-1-git-send-email-jrs@linux.vnet.ibm.com>
	<20110331032954.GA8747@peq.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20110331032954.GA8747-BtbdaCaBcfOTUehee3IRJA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 30 Mar 2011 22:29:54 -0500
"Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org> wrote:

> Quoting Jose R. Santos (jrs-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> > This small oversight was causing either crashes on free_msg() or
> > restart failures under some message queue workloads.
> > 
> > Signed-off-by: Jose R. Santos <jrs-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> 
> What kernel is this?

ckpt-v23-rc1

> Starting with the last line in your context, there is:
> 
> 	/* set default MAC attributes */
> 	ret = security_msg_msg_alloc(msg);
> 	if (ret < 0)
> 		goto out;
> 
> which should take care of that.  I don't know of an LSM which
> doesn't define msg_msg_alloc() but does define msg_msg_free().
> Do you have a stack trace to show where it was getting
> freed?

Sorry, should have put more details in the patch description.  The
problem here is that msg_msg_alloc() in not allocating anything and
thus the msg->security just happens to have what ever random data
that happens to be there after kmalloc was called for this msg. So the
way this usually manifested was during the a second checkpoint/restart.
For example:

run ./mq_test
checkpoint:
	Saving the msg with SECURITY_NONE
restart:
	Restores the msg content but with msg->security set to
	something random (or 0x5a pattern if using DEBUG_SLAB)
second checkpoint:
	msg->security not NULL so we proceed in
	security_checkpoint_obj() to call security_msg_msg_checkpoint()
second restart:
	All sorts of very weird, very different, hard to debug stuff
	happens afterwards. :)

Also, If you look at load_msg() in msgutil.c, the msg->security is also
initialized to NULL _before_ calling security_msg_msg_alloc().  Hope
this explains this fix better.

-JRS
