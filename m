From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 2/2] signals: replace p->pid == 1 check with a check for
	task_child_reaper
Date: Thu, 17 Jul 2008 11:51:38 -0700
Message-ID: <m1fxq8tkcl.fsf__24741.401608526$1216321404$gmane$org@frodo.ebiederm.org>
References: <487F5DA1.6000107@hozac.com> <m14p6ov1j0.fsf@frodo.ebiederm.org>
	<49797.192.168.102.6.1216318897.squirrel@intranet>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <49797.192.168.102.6.1216318897.squirrel@intranet> (Daniel Hokka
	Zakrisson's message of "Thu, 17 Jul 2008 20:21:37 +0200 (CEST)")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Hokka Zakrisson <daniel-nym3zxDgnZcAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, oleg-6lXkIZvqkOAvJsYlp49lxw@public.gmane.org
List-Id: containers.vger.kernel.org

"Daniel Hokka Zakrisson" <daniel-nym3zxDgnZcAvxtiuMwx3w@public.gmane.org> writes:

> Eric W. Biederman wrote:
>> Daniel Hokka Zakrisson <daniel-nym3zxDgnZcAvxtiuMwx3w@public.gmane.org> writes:
>>
>>> p->pid == 1 is insufficient when there are multiple pid namespaces.
>>> Instead, check whether the task is in the current task's
>>> child reaper's thread group.
>>
>> We should just drop the check for init as it is redundant.

Sorry that was a half truth.  Outside of the context of pid namespaces it is true.

In the context of pid namespaces it is false because we haven't merged the patches
to drop signals from inside the pid namespace on the way to init.

So it is a check that _should_ be redundant.

Eric
