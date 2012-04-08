From: richard -rw- weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [REVIEW][PATCH 0/43] Completing the user namespace
Date: Mon, 9 Apr 2012 00:04:56 +0200
Message-ID: <CAFLxGvwHtA028V2XudM-5HXmXCPw5ENL5E_nHKZh_gbrsRV69g@mail.gmail.com>
References: <m11unyn70b.fsf@fess.ebiederm.org>
	<CAFLxGvwyx6S6+eZtR=UNSQe_O+W7oZW=GosseL54HGpjtYGXjg@mail.gmail.com>
	<m1iph9ewsy.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1iph9ewsy.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

On Sun, Apr 8, 2012 at 11:30 PM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> richard -rw- weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>
>> On Sun, Apr 8, 2012 at 7:10 AM, Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org=
> wrote:
>>> - Capabilities are localized to the current user namespace making
>>> =A0it safe to give the initial user in a user namespace all capabilitie=
s.
>>>
>>
>> So, this makes LXC and friends ready for hostile environments?
>> IOW a root user (with all capabilities) sitting in his own namespace can=
 no
>> longer ham the host?
>
> The user namespace now restricts the root user in a container to being
> able to do no more harm than any other user can do. =A0Additionally suid
> executables can no longer lead to having all power on the system. =A0Which
> means that the only privilege escalation attacks available from a
> container require kernel bugs.
>
> With my version of user namespaces you no longer have to worry about the
> container root writing to files in /proc or /sys and changing the
> behavior of the system. =A0Nor do you have to worry about messages passed
> across unix domain sockets to d-bus having a trusted uid and being
> allowed to do something nasty.
>
> It allows for applications with no capabilities to use multiple
> uids and to implement privilege separation.
>
> I certainly see user namespaces like this as having the potential
> to make linux systems more secure.
>
> You will have to make your own threat assessment to decide if that is
> enough of an improvement to start deploying containers in what you
> consider hostile environments.
>
>
>
> For me the big potential I see is that it makes possible the creation of
> a container without privilege (today the uid mapping setup still
> requires privilege), and it allows a lot of things that the existence of
> suid root executables has prevented us from making unprivileged before.
>
> After the core is settled we can start looking at patches to allow
> unprivileged creation of other namespaces. =A0Unprivileged mounts.
> Unprivileged use of the networking stack. =A0Bringing many of the
> improvements that linux has seen over the years to unprivileged
> users.
>
> I also see great potential for April fools day jokes. =A0You log in and
> try to fix something and discover you are not the root you thought you
> were. =A0Does that count as a hostile environment?
>

Yep. Sounds great!
I'll give your patch set a try within the next few days on my LXC testbed. =
:-)

-- =

Thanks,
//richard
