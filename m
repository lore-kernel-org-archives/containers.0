From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 4/6][v3] Define siginfo_from_ancestor_ns()
Date: Tue, 23 Dec 2008 00:01:33 +0100
Message-ID: <20081222230133.GD1536@redhat.com>
References: <20081221005106.GA4912@us.ibm.com>
	<20081221005424.GD5025@us.ibm.com>
	<20081222222604.GA1536@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20081222222604.GA1536-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On 12/22, Oleg Nesterov wrote:
>
> On 12/20, Sukadev Bhattiprolu wrote:
> >
> > + * TODO:
> > + * 	  Making SI_ASYNCIO a kernel signal could make this less hacky.
> > + */
> > +#ifdef CONFIG_PID_NS
> > +static inline int siginfo_from_user(siginfo_t *info)
> > +{
> > +	if (!is_si_special(info) && SI_FROMUSER(info) &&
>
> OK, if we can trust SI_FROMUSER(), then it is better, i agree.

Aaah, forgot to mention...

But could you explain how are you going to fix another problem,
.si_pid mangling? This was another reason for (yes, ugly, agreed)
SIG_FROM_USER in .si_signo.

Oleg.
