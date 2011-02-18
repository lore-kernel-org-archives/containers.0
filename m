From: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/2] pidns: Support unsharing the pid namespace.
Date: Fri, 18 Feb 2011 15:40:19 +0100
Message-ID: <20110218144019.GA29600__16926.0398638018$1298040677$gmane$org@redhat.com>
References: <1297788824-20534-1-git-send-email-daniel.lezcano@free.fr>
	<1297788824-20534-2-git-send-email-daniel.lezcano@free.fr>
	<20110215190118.GA16707@redhat.com> <4D5C6219.8060207@free.fr>
	<20110217202959.GA16076@redhat.com> <4D5DA2CF.5010200@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4D5DA2CF.5010200-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg Kurz <gkurz-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
List-Id: containers.vger.kernel.org

On 02/17, Greg Kurz wrote:
>
> On 02/17/2011 09:29 PM, Oleg Nesterov wrote:
>> On 02/17, Daniel Lezcano wrote:
>>>
>>> On 02/15/2011 08:01 PM, Oleg Nesterov wrote:
>>>>
>>>> I have to admit, I can't say I like this very much. OK, if we need
>>>> this, can't we just put something into, say, signal->flags so that
>>>> copy_process can check and create the new namespace.
>>>>
>>>> Also. I remember, I already saw something like this and google found
>>>> my questions. I didn't actually read the new version, perhaps my
>>>> concerns were already answered...
>>>>
>>>> 	But what if the task T does unshare(CLONE_NEWPID) and then, say,
>>>> 	pthread_create() ? Unless I missed something, the new thread won't
>>>> 	be able to see T ?
>>>
>>> Right. Is it really a problem ? I mean it is a weird use case where we
>>> fall in a weird situation.
>>
>> But this is really weird! How it is possible that the parent can't see
>> its own child? No matter which thread did fork(), the new process is
>
> Hmmm... I guess you mean the opposite. The way pid namespaces are
> nested, parents always see their children.

Well, yes. But it can't see this child using the same pid number,
unless I missed something.

> But indeed, the child thread
> can't see its group leader and that's kind of unusual.

This too. And to me this is more "kind of buggy". But yes, I am
biased because I dislike this approach in general ;)

And, once again, this patch also lacks the necessary s/nsproxy/atcive_pid_ns/
changes.

Anyway. It is very possible I missed something. As I said, I didn't
actually read this version and I forgot all I knew about this change
before.

But afaics this patch is buggy in its current form.

Oleg.
