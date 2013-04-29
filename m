From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: For review (v2): user_namespaces(7) man page
Date: Mon, 29 Apr 2013 13:21:18 -0700
Message-ID: <CALCETrV=9Rebc3NNyQD3bLee_EL_222-oww45JXUasK=mq3dgA__34662.5926126309$1367266909$gmane$org@mail.gmail.com>
References: <CAKgNAkjgmTJ1BiHVbqVtz-g-=yfewMiYaroDJELJpa1aRrFAvQ@mail.gmail.com>
	<CAFLxGvy33QyJEMu_z47oyEEMY_awpT5rkoP4DYVjBQjsZysaGA@mail.gmail.com>
	<87mwsmqfga.fsf@xmission.com>
	<CAFLxGvw-d4jZniV=KHSDVCQtJEzhZB0bJAW-VyUKdAqDJi+_nA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAFLxGvw-d4jZniV=KHSDVCQtJEzhZB0bJAW-VyUKdAqDJi+_nA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: linux-man <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>, Michael Kerrisk-manpages <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Apr 25, 2013 at 10:48 PM, richard -rw- weinberger
<richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On Fri, Apr 26, 2013 at 2:54 AM, Eric W. Biederman
> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>> richard -rw- weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>>
>>> On Wed, Mar 27, 2013 at 10:26 PM, Michael Kerrisk (man-pages)
>>> <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>>>        Inside the user namespace, the shell has user and group  ID  0,
>>>>        and a full set of permitted and effective capabilities:
>>>>
>>>>            bash$ cat /proc/$$/status | egrep '^[UG]id'
>>>>            Uid: 0    0    0    0
>>>>            Gid: 0    0    0    0
>>>>            bash$ cat /proc/$$/status | egrep '^Cap(Prm|Inh|Eff)'
>>>>            CapInh:   0000000000000000
>>>>            CapPrm:   0000001fffffffff
>>>>            CapEff:   0000001fffffffff
>>>
>>> I've tried your demo program, but inside the new ns I'm automatically nobody.
>>> As Eric said, setuid(0)/setgid(0) are missing.
>>
>> Is it the setuid/setgid or not setting up the uid/gid map?
>
> uid/git mapping are set up.
>
>>> Eric, maybe you can help me. How can I drop capabilities within a user
>>> namespace?
>>
>>> In childFunc() I did add prctl(PR_CAPBSET_DROP, CAP_NET_ADMIN) but it always
>>> returns ENOPERM.
>>> What that? I thought I get a completely fresh set of cap which I can modify.
>>> I don't want that uid 0 inside the container has all caps.
>>
>> There are weird things that happen with exec and the user namespace.  If
>> you have exec'd as an unmapped user all of your capabilities have
>> already been droped.
>
> I've setup the mappings. If I look into /proc/*/status I see that my process has
> all caps.
> So, in general it is possible to drop cap within a user namespace?
> I really want to drop CAP_NET_ADMIN and some others.
> root within my container must not change any networking settings.

You may have the common issue that uid 0 tends to regain capabilities
on exec due to "legacy" capability emulation.  Try playing with
securebits and/or the bounding set.  (The setpriv command in very new
util-linux-ng makes this easy to play with.)

Note that you almost certainly want to set no_new_privs if anything
other than uid 0 is running with non-default securebits.

--Andy
