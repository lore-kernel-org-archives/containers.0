From: Louis Rilling <Louis.Rilling@kerlabs.com>
Subject: Re: [PATCH] procfs: Do not release pid_ns->proc_mnt too early
Date: Mon, 21 Jun 2010 16:15:18 +0200
Message-ID: <20100621141518.GA3773@hawkmoon.kerlabs.com>
References: <1276706068-18567-1-git-send-email-louis.rilling@kerlabs.com> <4C19F0A3.2050707@parallels.com> <m1631hdbdu.fsf@fess.ebiederm.org> <20100617213638.GB4182@redhat.com> <20100618082738.GE16877@hawkmoon.kerlabs.com> <20100618162734.GB7404@redhat.com> <20100621111127.GI16877@hawkmoon.kerlabs.com> <m1vd9c4k67.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=_bohort-18980-1277129655-0001-2"
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m1vd9c4k67.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Linux Containers <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@openvz.org>, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>
List-Id: containers.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_bohort-18980-1277129655-0001-2
Content-Type: multipart/mixed; boundary="ew6BAiZeqk4r7MaW"
Content-Disposition: inline


--ew6BAiZeqk4r7MaW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 21/06/10  5:58 -0700, Eric W. Biederman wrote:
> Louis Rilling <Louis.Rilling@kerlabs.com> writes:
>=20
> > On 18/06/10 18:27 +0200, Oleg Nesterov wrote:
> >> On 06/18, Louis Rilling wrote:
> >> >
> >> > On 17/06/10 23:36 +0200, Oleg Nesterov wrote:
> >> > > On 06/17, Eric W. Biederman wrote:
> >> > > >
> >> > > > The task->children isn't changed until __unhash_process() which =
runs
> >> > > > after flush_proc_task().
> >> > >
> >> > > Yes. But this is only the current implementation detail.
> >> > > It would be nice to cleanup the code so that EXIT_DEAD tasks are
> >> > > never sit in ->children list.
> >> > >
> >> > > > So we should be able to come up with
> >> > > > a variant of do_wait() that zap_pid_ns_processes can use that do=
es
> >> > > > what we need.
> >> > >
> >> > > See above...
> >> > >
> >> > > Even if we modify do_wait() or add the new variant, how the caller
> >> > > can wait for EXIT_DEAD tasks? I don't think we want to modify
> >> > > release_task() to do __wake_up_parent() or something similar.
> >> >
> >> > Indeed, I was thinking about calling __wake_up_parent() from release=
_task()
> >> > once parent->children becomes empty.
> >> >
> >> > Not sure about the performance impact though. Maybe some WAIT_NO_CHI=
LDREN flag
> >> > in parent->signal could limit it. But if EXIT_DEAD children are remo=
ved from
> >> > ->children before release_task(), I'm afraid that this becomes impos=
sible.
> >>=20
> >> Thinking more, even the current do_wait() from zap_pid_ns_processes()
> >> is not really good. Suppose that some none-init thread is ptraced, then
> >> zap_pid_ns_processes() will hange until the tracer does do_wait() or
> >> exits.
> >
> > Is this really a bad thing? If somebody ptraces a task in a pid namespa=
ce, that
> > sounds reasonable to have this namespace (and it's init task) pinned.
>=20
> Louis.  Have you seen this problem hit without my setns patch?

Yes. I hit it with Kerrighed patches. I also have an ugly reproducer on
2.6.35-rc3 (see attachments). Ugly because I introduced artifical delays
in release_task(). I couldn't trigger the bug without it, probably because =
the
scheduler is too kind :)

I'm using memory poisoining (SLAB and DEBUG_SLAB) to make it easy to observ=
e the
bug.

Example:
# ./proc_flush_task-bug-reproducer 1

>=20
> I'm pretty certain that this hits because there are processes do_wait
> does not wait for, in particular processes in a disjoint process tree.

Indeed do_wait() misses EXIT_DEAD children.

>=20
> So at this point I am really favoring killing the do_wait and making
> this all asynchronous.

Any idea about how to do it?

Thanks,

Louis

--=20
Dr Louis Rilling			Kerlabs
Skype: louis.rilling			Batiment Germanium
Phone: (+33|0) 6 80 89 08 23		80 avenue des Buttes de Coesmes
http://www.kerlabs.com/			35700 Rennes

--ew6BAiZeqk4r7MaW
Content-Type: text/x-csrc; charset=us-ascii
Content-Disposition: attachment; filename="proc_flush_task-bug-reproducer.c"
Content-Transfer-Encoding: quoted-printable

#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/syscall.h>
#include <signal.h>
#include <linux/sched.h>

int pipefd[2];

int init(void *arg)
{
	int nr, i, err;
	sighandler_t sigret;
	char c;

	close(pipefd[0]);

	err =3D setsid();
	if (err < 0) {
		perror("setsid");
		abort();
	}

	sigret =3D signal(SIGCHLD, SIG_IGN);
	if (sigret =3D=3D SIG_ERR) {
		fprintf(stderr, "signal\n");
		abort();
	}
=09
	nr =3D atoi(arg);
	for (i =3D 0; i < nr; i++) {
		err =3D fork();
		if (err < 0) {
			perror("fork");
			abort();
		} else if (err =3D=3D 0) {
			printf("%d before\n", getpid());
			fflush(stdout);
			pause();
			printf("%d after\n", getpid());
			fflush(stdout);
			return 0;
		}
	}

	err =3D write(pipefd[1], &c, 1);
	if (err !=3D 1) {
		perror("write");
		abort();
	}

	pause();

	return 0;
}

int main(int argc, char *argv[])
{
	long stack_size =3D sysconf(_SC_PAGESIZE);
	void *stack =3D alloca(stack_size) + stack_size;
	pid_t pid;
	char c;
	int ret;

	ret =3D pipe(pipefd);
	if (ret) {
		perror("pipe");
		abort();
	}

	ret =3D clone(init, stack, CLONE_NEWPID | SIGCHLD, argv[1]);
	if (ret < 0) {
		perror("clone");
		abort();
	}
	pid =3D ret;
	printf("%d\n", pid);
	fflush(stdout);

	close(pipefd[1]);
	ret =3D read(pipefd[0], &c, 1);
	if (ret !=3D 1) {
		if (ret) {
			perror("read");
			abort();
		} else {
			sleep(5);
		}
	}

	printf("killing %d\n", pid);
	fflush(stdout);
	ret =3D kill(-pid, SIGKILL);
	if (ret) {
		perror("kill");
		abort();
	}

	return 0;
}

--ew6BAiZeqk4r7MaW
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="reproducer.patch"
Content-Transfer-Encoding: quoted-printable

commit 7b7cae6ae5c543b8e9cc84fc041d9bce36e7b674
Author: Louis Rilling <louis.rilling@kerlabs.com>
Date:   Wed Jun 16 16:20:02 2010 +0200

    proc_flush_task() debug

diff --git a/kernel/exit.c b/kernel/exit.c
index ceffc67..be8cdb0 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -169,6 +169,14 @@ repeat:
 	atomic_dec(&__task_cred(p)->user->processes);
 	rcu_read_unlock();
=20
+	if (task_pid(p)->level > 0) {
+		if (!thread_group_leader(p) || !is_container_init(p)) {
+			__set_current_state(TASK_UNINTERRUPTIBLE);
+			schedule_timeout(10 * HZ);
+		}
+		printk("release_task: %d/%d\n", p->pid, task_pid(p)->numbers[1].nr);
+	}
+
 	proc_flush_task(p);
=20
 	write_lock_irq(&tasklist_lock);

--ew6BAiZeqk4r7MaW--

--=_bohort-18980-1277129655-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkwfc/YACgkQVKcRuvQ9Q1TZFQCgm2hf3dqxF1puDH3oxVF0YNVp
Tn4AnjzdWRHF+n0+lrQunFYIgxHZLBWw
=2hR5
-----END PGP SIGNATURE-----

--=_bohort-18980-1277129655-0001-2--
