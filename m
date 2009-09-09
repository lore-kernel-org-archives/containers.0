From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Understanding CPU containers
Date: Wed, 9 Sep 2009 09:03:31 -0500
Message-ID: <20090909140331.GB21476@us.ibm.com>
References: <c7704c490909090330m494bc910n170f04c09cdeeeea@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <c7704c490909090330m494bc910n170f04c09cdeeeea-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Mukesh G <mukgbv-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Mukesh G (mukgbv-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> Hi,
>        I am trying to understand the behavior of CPU containers as I
> am unable to explain few things.

...

> Observations
> =

>         - Unless the cpu resources are overcommitted, there is no
> value in the allocating shares to the containers.

Right.  And that observation (which is correct - there is no throttling
if cpu is available) explains the rest.

>         - 2048 vs 1024 cpu containers, the scale is 2X, except for 16 byt=
es
>  =A0=A0=A0=A0=A0=A0=A0- 512 vs 1024 cpu containers, there is no differenc=
e at all,
> except for 16 bytes
>  =A0=A0=A0=A0=A0=A0=A0- 512 vs 1024 cpu containers, there is no differenc=
e for 8192
> bytes as the remaining 2 openssl runs are complete.
>  =A0=A0=A0=A0=A0=A0=A0- For CPU bound, there has to be an over commit on =
the CPUs
> otherwise the share allocation does not matter
>         - One cannot dynamically assign cpus to the container, by
> default, it runs on the no of cores available.
> =

> Any pointers are helpful

Hmm, there isn't a file under Documentation/cgroups?  That should
be fixed...  Meanwhile, the code is mainly in kernel/sched.c.  You
can start with the cgroup subsys definition at
	struct cgroup_subsys cpu_cgroup_subsys =3D { ...
(around line 10313) and fan out from there.

-serge
