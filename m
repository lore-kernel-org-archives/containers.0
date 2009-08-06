From: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 6/6] Makes procs file writable to move all threads by tgid
	at once
Date: Wed, 5 Aug 2009 17:01:42 -0700
Message-ID: <2f86c2480908051701s57120404q475edbedb58cdca1__9082.15251188285$1249517038$gmane$org@mail.gmail.com>
References: <20090731015154.27908.9639.stgit@hastromil.mtv.corp.google.com>
	<2f86c2480908031113y525b6cbdhe418b8a0364c7760@mail.gmail.com>
	<20090803185556.GA8469@us.ibm.com> <20090803194555.GA10158@us.ibm.com>
	<6599ad830908041148h6d3f3e9bxfef9f3eedec0ab6d@mail.gmail.com>
	<2f86c2480908041214r1f23c1b7q9a25b04e26c92a1a@mail.gmail.com>
	<6599ad830908041228w67bc6f7fh57e28f244e1923b3@mail.gmail.com>
	<20090805102057.GT29252@hawkmoon.kerlabs.com>
	<6599ad830908050911t6f23f810i65fe8fe17f3ee698@mail.gmail.com>
	<20090805164218.GB26446@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090805164218.GB26446-Hu8+6S1rdjywhHL9vcZdMVaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, Peter
List-Id: containers.vger.kernel.org

On Wed, Aug 5, 2009 at 9:42 AM, Louis Rilling<Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org> wr=
ote:
> On 05/08/09 =A09:11 -0700, Paul Menage wrote:
>> On Wed, Aug 5, 2009 at 3:20 AM, Louis Rilling<Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>=
 wrote:
>> >
>> > The downside of this is teaching lockdep about this recursive locking.=
 Not that
>> > simple actually...
>>
>> Don't we just give each thread's lock its own lock class? That's what
>> we did for the cgroup hierarchy_mutex.
>
> Given that lock classes must be static and that lockdep only supports a l=
imited
> lock depth, this is an issue for processes having many threads.
>
>>
>> > so that such cases are currently handled using a higher-level
>> > lock that prevents races in locking the whole chain (there was one suc=
h example
>> > for locking all vmas with KVM). IIUC, the intent here is to avoid such
>> > higher-level lock.
>>
>> cgroup_mutex already fulfills the role of the higher-level lock.
>
> If so (that is, here cgroup_mutex is taken before write-locking all threa=
ds'
> rw_sem), then enhancing rwsem's interface in a similar way to the
> spin_lock_nest_lock() interface could do it. There will still be an issue=
 with
> many threads and lockdep limited lock depth though.

If we make the locks per-thread, then we can use plain mutexes instead
of rwsems since the only reader will ever be the owning thread itself,
and we can use mutex_lock_nested.

>
> Added Peter in CC.
>
> Louis
>
> --
> Dr Louis Rilling =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Kerlabs
> Skype: louis.rilling =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Batiment Germ=
anium
> Phone: (+33|0) 6 80 89 08 23 =A0 =A0 =A0 =A0 =A0 =A080 avenue des Buttes =
de Coesmes
> http://www.kerlabs.com/ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 35700 Rennes
>
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v1.4.9 (GNU/Linux)
>
> iEYEARECAAYFAkp5tmoACgkQVKcRuvQ9Q1TwdACeMwdKtGc3rU3PGXPgYvdj9Vxe
> xYIAmQFMW6Ri9JGuc7+A0WmGzXkzQ81A
> =3DWj3u
> -----END PGP SIGNATURE-----
>
>
