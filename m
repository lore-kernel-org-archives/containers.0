From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: For review (v2): user_namespaces(7) man page
Date: Thu, 25 Apr 2013 17:54:29 -0700
Message-ID: <87mwsmqfga.fsf@xmission.com>
References: <CAKgNAkjgmTJ1BiHVbqVtz-g-=yfewMiYaroDJELJpa1aRrFAvQ@mail.gmail.com>
	<CAFLxGvy33QyJEMu_z47oyEEMY_awpT5rkoP4DYVjBQjsZysaGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAFLxGvy33QyJEMu_z47oyEEMY_awpT5rkoP4DYVjBQjsZysaGA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(richard's message of "Thu, 25 Apr 2013 09:48:00 +0200")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: richard -rw- weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-man <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, Michael Kerrisk-manpages <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

richard -rw- weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On Wed, Mar 27, 2013 at 10:26 PM, Michael Kerrisk (man-pages)
> <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>        Inside the user namespace, the shell has user and group  ID  0,
>>        and a full set of permitted and effective capabilities:
>>
>>            bash$ cat /proc/$$/status | egrep '^[UG]id'
>>            Uid: 0    0    0    0
>>            Gid: 0    0    0    0
>>            bash$ cat /proc/$$/status | egrep '^Cap(Prm|Inh|Eff)'
>>            CapInh:   0000000000000000
>>            CapPrm:   0000001fffffffff
>>            CapEff:   0000001fffffffff
>
> I've tried your demo program, but inside the new ns I'm automatically nobody.
> As Eric said, setuid(0)/setgid(0) are missing.

Is it the setuid/setgid or not setting up the uid/gid map?

> Eric, maybe you can help me. How can I drop capabilities within a user
> namespace?

> In childFunc() I did add prctl(PR_CAPBSET_DROP, CAP_NET_ADMIN) but it always
> returns ENOPERM.
> What that? I thought I get a completely fresh set of cap which I can modify.
> I don't want that uid 0 inside the container has all caps.

There are weird things that happen with exec and the user namespace.  If
you have exec'd as an unmapped user all of your capabilities have
already been droped.

> And why does /proc/*/loginuid always contain 4294967295 in a new user namespace?
> Writing to it also fails. (Noticed that because pam_loginuid.so does not work).

Almost certainly because the loginuid has already been set.  Yes. It
looks like I am simply using from_kuid instead of from_kuid_munged on
the read.  So an unmapped loginuid will be reported as 4294967295.

For some circumstances 65534 (nobody) is definitely better in some it is
a toss up, and most of the time no one really cares.  So I have tried to
do something but in this case I don't know which was the best policy.

> Final question, is it by design that uid 0 within a namespace in not
> allowed to write to
> /proc/*/oom_score_adj?

Essentially.  It is by design that uid 0 within a namespace be mapped to
some other uid outside the namespace, and that the permissions on writes
should use the permission needed outside of the user namespace.

Which means there are all kinds of things only uid 0 can write to, that
you can't touch in a user namespace.  Some of those things the policy
may need to be reconsidered.  A lot of those things the default policy
is good.  Regardless we are now defaulting to not letting root in a
container do risky things which is a good thing.

Eric
