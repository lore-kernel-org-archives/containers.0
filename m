From: richard -rw- weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: For review (v2): user_namespaces(7) man page
Date: Thu, 25 Apr 2013 09:48:00 +0200
Message-ID: <CAFLxGvy33QyJEMu_z47oyEEMY_awpT5rkoP4DYVjBQjsZysaGA@mail.gmail.com>
References: <CAKgNAkjgmTJ1BiHVbqVtz-g-=yfewMiYaroDJELJpa1aRrFAvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAKgNAkjgmTJ1BiHVbqVtz-g-=yfewMiYaroDJELJpa1aRrFAvQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Michael Kerrisk-manpages <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-man <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Mar 27, 2013 at 10:26 PM, Michael Kerrisk (man-pages)
<mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>        Inside the user namespace, the shell has user and group  ID  0,
>        and a full set of permitted and effective capabilities:
>
>            bash$ cat /proc/$$/status | egrep '^[UG]id'
>            Uid: 0    0    0    0
>            Gid: 0    0    0    0
>            bash$ cat /proc/$$/status | egrep '^Cap(Prm|Inh|Eff)'
>            CapInh:   0000000000000000
>            CapPrm:   0000001fffffffff
>            CapEff:   0000001fffffffff

I've tried your demo program, but inside the new ns I'm automatically nobody.
As Eric said, setuid(0)/setgid(0) are missing.

Eric, maybe you can help me. How can I drop capabilities within a user
namespace?
In childFunc() I did add prctl(PR_CAPBSET_DROP, CAP_NET_ADMIN) but it always
returns ENOPERM.
What that? I thought I get a completely fresh set of cap which I can modify.
I don't want that uid 0 inside the container has all caps.

And why does /proc/*/loginuid always contain 4294967295 in a new user namespace?
Writing to it also fails. (Noticed that because pam_loginuid.so does not work).

Final question, is it by design that uid 0 within a namespace in not
allowed to write to
/proc/*/oom_score_adj?


Thanks,
//richard

P.s: I've used 3.9-rc8 for my tests...
