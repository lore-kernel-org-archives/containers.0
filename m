From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH 4/6][v3] Define siginfo_from_ancestor_ns()
Date: Mon, 22 Dec 2008 16:32:16 -0800
Message-ID: <m13agf68a7.fsf@frodo.ebiederm.org>
References: <20081221005106.GA4912@us.ibm.com>
	<20081221005424.GD5025@us.ibm.com> <20081222222604.GA1536@redhat.com>
	<20081222230133.GD1536@redhat.com> <20081222235837.GC13079@us.ibm.com>
	<20081223002215.GA7984@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081223002215.GA7984-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (Oleg Nesterov's message of
	"Tue, 23 Dec 2008 01:22:15 +0100")
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
Cc: bastian-yyjItF7Rl6lg9hUCZPvPmw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, roland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

>> I was going through the ->si_pid assignments to try and fix them at
>> source (like the mqueue patch I sent last week).
>
> OK.

Note.  When a signal goes to a process group (or similar) we can't fix
si_pid at the source.  We have to fix it when only a single destination
process is known.  It doesn't mean that fixing it at the source
is hopeless but...  

>> The two cases that don't fit the model are sys_kill() and sys_tkill().
>> For that I was hoping we could use siginfo_from_user() again. i.e
>>
>> 	if (siginfo_from_user())
>> 		masquerade_si_pid()
>>
>> in the default: case of send_signal(). To be safe, masquerade_si_pid()
>> could do it only iff si_code is either SI_USER or SI_TKILL.
>>
>> IOW, with some tweaks, I am trying to see if we can use siginfo_from_user()
>> in place of the SIG_FROM_USER.
>
> sys_rt_sigqueueinfo().
>
> But, perhaps we can just ignore the problems with sigqueueinfo() (and
> document them). 

Yes.  I don't think si_pid is valid in that case anyway.  It is the
kernel signals where si_pid is a reliable field that are important.

Eric
