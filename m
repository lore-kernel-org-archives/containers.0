From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Subject: Re: [net-next v3 0/2] eBPF seccomp filters
Date: Wed, 28 Feb 2018 00:10:12 +0100
Message-ID: <5323e010-09df-26d9-15f5-c723faa13224@digikod.net>
References: <20180226072651.GA27045@ircssh-2.c.rugged-nimbus-611.internal>
	<20180226230418.46nczgkh5csakyu7@ast-mbp>
	<CAGXu5jLdOcrn16q9pQ7JwTf88AVsL0o5LMJ=4P6vRN36u-_k_g@mail.gmail.com>
	<CALCETrXNODxWkcwF-LbXBn+Ju7QJEyi3JR+spsRX4ecg8d1iMQ@mail.gmail.com>
	<CAGXu5j+64WzxjBnpQxYCU50ak+VqVw1y0W+MWygFodxsDqEZRw@mail.gmail.com>
	<A20EA7DD-94E9-488A-B9FF-D8E2C9F26611@amacapital.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============6880802283718438483=="
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <A20EA7DD-94E9-488A-B9FF-D8E2C9F26611-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--===============6880802283718438483==
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="PmnjYZyxuO71Rs06l6Hz9CIhRqFt4lj6V"

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--PmnjYZyxuO71Rs06l6Hz9CIhRqFt4lj6V
Content-Type: multipart/mixed; boundary="rkv0HoI3wA8QdBvnAroLWkdV7ayF8bpKW";
 protected-headers="v1"
From: =?UTF-8?Q?Micka=c3=abl_Sala=c3=bcn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>,
 Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
 Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
 Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Jessica Frazelle <me-XvZkT8t+Da5Wk0Htik3J/w@public.gmane.org>,
 Brian Goff <cpuguy83-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Tom Hromatka <tom.hromatka-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
 James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>, Tycho Andersen <tycho-E0fblnxP3wo@public.gmane.org>
Message-ID: <5323e010-09df-26d9-15f5-c723faa13224-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Subject: Re: [net-next v3 0/2] eBPF seccomp filters
References: <20180226072651.GA27045-du9IEJ8oIxHXYT48pCVpJ3c7ZZ+wIVaZYkHkVr5ML8kVGlcevz2xqA@public.gmane.org>
 <20180226230418.46nczgkh5csakyu7@ast-mbp>
 <CAGXu5jLdOcrn16q9pQ7JwTf88AVsL0o5LMJ=4P6vRN36u-_k_g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
 <CALCETrXNODxWkcwF-LbXBn+Ju7QJEyi3JR+spsRX4ecg8d1iMQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
 <CAGXu5j+64WzxjBnpQxYCU50ak+VqVw1y0W+MWygFodxsDqEZRw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
 <A20EA7DD-94E9-488A-B9FF-D8E2C9F26611-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
In-Reply-To: <A20EA7DD-94E9-488A-B9FF-D8E2C9F26611-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>

--rkv0HoI3wA8QdBvnAroLWkdV7ayF8bpKW
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable


On 27/02/2018 05:54, Andy Lutomirski wrote:
>=20
>=20
>> On Feb 26, 2018, at 8:38 PM, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> wrote:
>>
>> On Mon, Feb 26, 2018 at 8:19 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>=
 wrote:
>>>> On Feb 26, 2018, at 3:20 PM, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> wrote=
:
>>>>
>>>> On Mon, Feb 26, 2018 at 3:04 PM, Alexei Starovoitov
>>>> <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>>>>> On Mon, Feb 26, 2018 at 07:26:54AM +0000, Sargun Dhillon wrote:
>>>>>> This patchset enables seccomp filters to be written in eBPF. Altho=
ugh, this
>>>>>> [...]
>>>>> The main statement I want to hear from seccomp maintainers before
>>>>> proceeding any further on this that enabling eBPF in seccomp won't =
lead
>>>>> to seccomp folks arguing against changes in bpf core (like verifier=
)
>>>>> just because it's used by seccomp.
>>>>> It must be spelled out in the commit log with explicit Ack.
>>>>
>>>> The primary thing I'm concerned about with eBPF and seccomp is
>>>> side-effects from eBPF programs running at syscall time. This is an
>>>> extremely sensitive area, and I want to be sure there won't be
>>>> feature-creep here that leads to seccomp getting into a bad state.
>>>>
>>>> As long as seccomp can continue have its own verifier, I *think* thi=
s
>>>> will be fine, though, again I remain concerned about maps, etc. I'm
>>>> still reviewing these patches and how they might provide overlap wit=
h
>>>> Tycho's needs too, etc.
>>>
>>> I'm not sure I see this as a huge problem.  As far as I can see, ther=
e
>>> are three ways that a verifier change could be problematic:
>>>
>>> 1. Addition of a new type of map.  But seccomp would just not allow
>>> new map types by default, right?
>>>
>>> 2. Addition of a new BPF_CALLable helper.  Seccomp wants a way to
>>> whitelist BPF_CALL targets.  That should be straightforward.
>>
>> Yup, agreed on 1 and 2.
>>
>>> 3. Straight-up bugs.  Those are exactly as problematic as verifier
>>> bugs in any other unprivileged eBPF program type, right?  I don't see=

>>> why seccomp is special here.
>>
>> My concern is more about unintended design mistakes or other feature
>> creep with side-effects, especially when it comes to privileges and
>> synchronization. Getting no-new-privs done correctly, for example,
>> took some careful thought and discussion, and I'm shy from how painful=

>> TSYNC was on the process locking side, and eBPF has had some rather
>> ugly flaws in the past (and recently: it was nice to be able to say
>> for Spectre that seccomp filters couldn't be constructed to make
>> attacks but eBPF could). Adding the complexity needs to be worth the
>> gain. I'm on board for doing it, I just want to be careful. :)
>>
>=20
> I agree.  I think that, if we do this right, we get a clean version of =
Tycho's notifiers.  We can also very easily build on that to send a non-b=
locking message to the notifier fd, which gets us a version of seccomp lo=
gging that works for things like Chromium and even strace.  I think this =
is worth it.
>=20
> I also think this sort of argument is why Micka=C3=ABl's privileged-fir=
st Landlock is the wrong approach.  By getting the unprivileged parts rig=
ht from day one, we can carefully extend the mechanism and keep it usable=
 by unprivileged apps.  But, if we'd started as root-only, fixing up ever=
ything needed to make it safe for unprivileged users after the fact would=
 have been quite messy.

We agreed (including Kees and you, at the Santa Fe LPC) to limit the use
of Landlock to CAP_SYS_ADMIN at first. It is an artificial limitation
that can be re-enabled by removing three explicit checks/lines. Landlock
was designed for unprivileged use from day one and it is still the goal.

>=20
> And the considerations for making eBPF safe for use by unprivileged tas=
ks to filter their descendents are more or less the same for seccomp and =
Landlock.  Can we please arrange things so we solve this problem only onc=
e?
>=20

Landlock is definitely focused on eBPF. It should not be hard to add a
new Landlock program type to mimic the seccomp filter checks (to use
eBPF features like maps), but I'm not sure to get the use case here.


--rkv0HoI3wA8QdBvnAroLWkdV7ayF8bpKW--

--PmnjYZyxuO71Rs06l6Hz9CIhRqFt4lj6V
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEEUysCyY8er9Axt7hqIt7+33O9apUFAlqV5VQACgkQIt7+33O9
apXM5Qf8DxiKDrwBF0Cewz76iQIMBh1BsBjFgINJEdrlAiD8rzAwLksjt+auXl55
qlw7o6/Fbazejf+2I/w8SMWnm5TBXJ3j6GgK8zM3nQthInQN8cvNy2KFve1UOjkD
Q8sLEFkkeKr58vXVu+cG6HaBd9JgC8XCNg7PsCq2nUkDMY2OxNDxHBm/S7MrJ0sg
Ge5M+B2l/wLFAFu93s6UnFnW8ATBxEu+lbu830qFN3qUulT0VQ5AuKgz7z0L3cuY
A8272eKaxMWjVifcdu5FwDayxrwb0YCbY0KrQmHg5wINNHISEkpf+7SA89/lpUOo
7Ih1fLGFrnYI5ceogLEbyQONiEjvtQ==
=b+40
-----END PGP SIGNATURE-----

--PmnjYZyxuO71Rs06l6Hz9CIhRqFt4lj6V--

--===============6880802283718438483==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--===============6880802283718438483==--
