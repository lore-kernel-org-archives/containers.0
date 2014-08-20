From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: For review: unshare(2) man page
Date: Wed, 20 Aug 2014 18:38:35 -0500
Message-ID: <53F5317B.6010808@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------050209000107050606050708"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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
Cc: "linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
List-Id: containers.vger.kernel.org

This is a multi-part message in MIME format.
--------------050209000107050606050708
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello Eric et al.

With the namespaces changes, a number of additions have been=20
made to the unshare(2) man page, so I will send out the entire page
for review at the same time as the various namespaces page.
The rendered version is below, and the source is attached.

Review comments/suggestions for improvements / bug fixes welcome.

Cheers,

Michael

=3D=3D

NAME
       unshare - disassociate parts of the process execution context

SYNOPSIS
       #include <sched.h>

       int unshare(int flags);

   Feature    Test    Macro    Requirements    for   glibc   (see   fea=E2=
=80=90
   ture_test_macros(7)):

       unshare():
           Since glibc 2.14:
               _GNU_SOURCE
           Before glibc 2.14:
               _BSD_SOURCE || _SVID_SOURCE
                   /* _GNU_SOURCE also suffices */

DESCRIPTION
       unshare() allows a process to disassociate parts of its execution
       context  that  are  currently  being shared with other processes.
       Part of the execution context, such as the  mount  namespace,  is
       shared  implicitly when a new process is created using fork(2) or
       vfork(2), while other parts,  such  as  virtual  memory,  may  be
       shared   by  explicit  request  when  creating  a  process  using
       clone(2).

       The main use of unshare() is to allow a process  to  control  its
       shared execution context without creating a new process.

       The  flags  argument  is a bit mask that specifies which parts of
       the execution context should be unshared.  This argument is spec=E2=
=80=90
       ified by ORing together zero or more of the following constants:

       CLONE_FILES
              Reverse  the  effect  of  the  clone(2)  CLONE_FILES flag.
              Unshare the file descriptor table,  so  that  the  calling
              process  no  longer  shares  its file descriptors with any
              other process.

       CLONE_FS
              Reverse the effect of the clone(2) CLONE_FS flag.  Unshare
              filesystem  attributes,  so  that  the  calling process no
              longer shares  its  root  directory  (chroot(2)),  current
              directory  (chdir(2)), or umask (umask(2)) attributes with
              any other process.

       CLONE_NEWIPC (since Linux 2.6.19)
              This flag has the same effect as the clone(2) CLONE_NEWIPC
              flag.   Unshare  the  System V  IPC namespace, so that the
              calling process has a private copy  of  the  System V  IPC
              namespace  which  is  not  shared  with any other process.
              Specifying this flag automatically  implies  CLONE_SYSVSEM
              as  well.   Use of CLONE_NEWIPC requires the CAP_SYS_ADMIN
              capability.

       CLONE_NEWNET (since Linux 2.6.24)
              This flag has the same effect as the clone(2) CLONE_NEWNET
              flag.   Unshare the network namespace, so that the calling
              process is moved into a new network namespace which is not
              shared  with  any  previously  existing  process.   Use of
              CLONE_NEWNET requires the CAP_SYS_ADMIN capability.

       CLONE_NEWNS
              This flag has the same effect as the clone(2)  CLONE_NEWNS
              flag.   Unshare  the  mount namespace, so that the calling
              process has a private copy of its namespace which  is  not
              shared with any other process.  Specifying this flag auto=E2=
=80=90
              matically implies CLONE_FS as well.   Use  of  CLONE_NEWNS
              requires the CAP_SYS_ADMIN capability.

       CLONE_NEWPID (since Linux 3.8)
              This flag has the same effect as the clone(2) CLONE_NEWPID
              flag.  Unshare the PID  namespace,  so  that  the  calling
              process  has a new PID namespace for its children which is
              not shared with  any  previously  existing  process.   The
              calling  process is not moved into the new namespace.  The
              first child created by the calling process will  have  the
              process  ID  1  and will assume the role of init(1) in the
              new   namespace.    CLONE_NEWPID   automatically   implies
              CLONE_THREAD  as  well.   Use of CLONE_NEWPID requires the
              CAP_SYS_ADMIN capability.  For  further  information,  see
              pid_namespaces(7).

       CLONE_NEWUSER (since Linux 3.8)
              This   flag   has   the   same   effect  as  the  clone(2)
              CLONE_NEWUSER flag.  Unshare the user namespace,  so  that
              the  calling  process  is  moved into a new user namespace
              which is not shared with any previously existing  process.
              As  with  the  child  process created by clone(2) with the
              CLONE_NEWUSER flag, the caller obtains a full set of capa=E2=
=80=90
              bilities in the new namespace.

              CLONE_NEWUSER  requires  that  the  calling process is not
              threaded; specifying CLONE_NEWUSER  automatically  implies
              CLONE_THREAD.   Since  Linux 3.9, CLONE_NEWUSER also auto=E2=
=80=90
              matically implies CLONE_FS.  CLONE_NEWUSER  requires  that
              the user ID and group ID of the calling process are mapped
              to user IDs and group IDs in the  user  namespace  of  the
              calling process at the time of the call.

              For   further   information   on   user   namespaces,  see
              user_namespaces(7).

       CLONE_NEWUTS (since Linux 2.6.19)
              This flag has the same effect as the clone(2) CLONE_NEWUTS
              flag.   Unshare the UTS IPC namespace, so that the calling
              process has a private copy of the UTS namespace  which  is
              not  shared  with  any other process.  Use of CLONE_NEWUTS
              requires the CAP_SYS_ADMIN capability.

       CLONE_SYSVSEM (since Linux 2.6.26)
              This  flag   reverses   the   effect   of   the   clone(2)
              CLONE_SYSVSEM flag.  Unshare System V semaphore adjustment
              (semadj) values, so that the calling  process  has  a  new
              empty  semadj  list  that  is  not  shared  with any other
              process.  If this is the last process that has a reference
              to the process's current semadj list, then the adjustments
              in that list are applied to the corresponding  semaphores,
              as described in semop(2).

       In  addition,  CLONE_THREAD,  CLONE_SIGHAND,  and CLONE_VM can be
       specified in flags if the caller is single threaded (i.e., it  is
       not  sharing  its  address space with another process or thread).
       In this case, these flags have no effect.  If the process is mul=E2=
=80=90
       tithreaded, then the use of these flags results in an error.

       If  flags  is  specified  as  zero, then unshare() is a no-op; no
       changes are made to the calling process's execution context.

RETURN VALUE
       On success, zero returned.  On failure, -1 is returned and  errno
       is set to indicate the error.

ERRORS
       EINVAL An invalid bit was specified in flags.

       EINVAL CLONE_THREAD,  CLONE_SIGHAND, or CLONE_VM was specified in
              flags, and the caller is multithreaded.

       ENOMEM Cannot allocate sufficient memory to copy parts  of  call=E2=
=80=90
              er's context that need to be unshared.

       EPERM  The  calling  process did not have the required privileges
              for this operation.

       EPERM  CLONE_NEWUSER was  specified  in  flags,  but  either  the
              effective  user ID or the effective group ID of the caller
              does not have a  mapping  in  the  parent  namespace  (see
              user_namespaces(7)).

       EPERM (since Linux 3.9)
              CLONE_NEWUSER  was specified in flags and the caller is in
              a chroot environment (i.e., the  caller's  root  directory
              does  not  match the root directory of the mount namespace
              in which it resides).

       EUSERS (since Linux 3.11)
              CLONE_NEWUSER was specified in flags, and the  call  would
              cause the limit on the number of nested user namespaces to
              be exceeded.  See user_namespaces(7).

VERSIONS
       The unshare() system call was added to Linux in kernel 2.6.16.

CONFORMING TO
       The unshare() system call is Linux-specific.

NOTES
       Not all of the process attributes that can be shared when  a  new
       process   is   created  using  clone(2)  can  be  unshared  using
       unshare().  In particular, as at kernel 3.8, unshare()  does  not
       implement  flags  that  reverse  the  effects  of  CLONE_SIGHAND,
       CLONE_THREAD, or CLONE_VM.  Such functionality may  be  added  in
       the future, if required.

EXAMPLE
       The  program  below  provides  a  simple  implementation  of  the
       unshare(1) command, which unshares one  or  more  namespaces  and
       executes  the  command  supplied  in  its command-line arguments.
       Here's an example of the use of this program, running a shell  in
       a  new mount namespace, and verifying that the original shell and
       the new shell are in separate mount namespaces:

           $ readlink /proc/$$/ns/mnt
           mnt:[4026531840]
           $ sudo ./unshare -m /bin/bash
           [sudo] password for cecilia:
           # readlink /proc/$$/ns/mnt
           mnt:[4026532325]

       The differing output of the two readlink(1) commands  shows  that
       the two shells are in different mount namespaces.

   Program source

       /* unshare.c

          A simple implementation of the unshare(1) command: unshare
          namespaces and execute a command.
       */
       #define _GNU_SOURCE
       #include <sched.h>
       #include <unistd.h>
       #include <stdlib.h>
       #include <stdio.h>

       /* A simple error-handling function: print an error message based
          on the value in 'errno' and terminate the calling process */

       #define errExit(msg)    do { perror(msg); exit(EXIT_FAILURE); \
                               } while (0)

       static void
       usage(char *pname)
       {
           fprintf(stderr, "Usage: %s [options] program [arg...]\n", pnam=
e);
           fprintf(stderr, "Options can be:\n");
           fprintf(stderr, "    -i   unshare IPC namespace\n");
           fprintf(stderr, "    -m   unshare mount namespace\n");
           fprintf(stderr, "    -n   unshare network namespace\n");
           fprintf(stderr, "    -p   unshare PID namespace\n");
           fprintf(stderr, "    -u   unshare UTS namespace\n");
           fprintf(stderr, "    -U   unshare user namespace\n");
           exit(EXIT_FAILURE);
       }

       int
       main(int argc, char *argv[])
       {
           int flags, opt;

           flags =3D 0;

           while ((opt =3D getopt(argc, argv, "imnpuU")) !=3D -1) {
               switch (opt) {
               case 'i': flags |=3D CLONE_NEWIPC;        break;
               case 'm': flags |=3D CLONE_NEWNS;         break;
               case 'n': flags |=3D CLONE_NEWNET;        break;
               case 'p': flags |=3D CLONE_NEWPID;        break;
               case 'u': flags |=3D CLONE_NEWUTS;        break;
               case 'U': flags |=3D CLONE_NEWUSER;       break;
               default:  usage(argv[0]);
               }
           }

           if (optind >=3D argc)
               usage(argv[0]);

           if (unshare(flags) =3D=3D -1)
               errExit("unshare");

           execvp(argv[optind], &argv[optind]);
           errExit("execvp");
       }

SEE ALSO
       unshare(1),   clone(2),  fork(2),  kcmp(2),  setns(2),  vfork(2),
       namespaces(7)

       Documentation/unshare.txt in the Linux kernel source tree


--=20
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--------------050209000107050606050708
Content-Type: application/x-troff-man;
 name="unshare.2"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="unshare.2"

.\" Copyright (C) 2006, Janak Desai <janak-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
.\" and Copyright (C) 2006, 2012 Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
.\"
.\" %%%LICENSE_START(GPL_NOVERSION_ONELINE)
.\" Licensed under the GPL
.\" %%%LICENSE_END
.\"
.\" Patch Justification:
.\" unshare system call is needed to implement, using PAM,
.\" per-security_context and/or per-user namespace to provide
.\" polyinstantiated directories. Using unshare and bind mounts, a
.\" PAM module can create private namespace with appropriate
.\" directories(based on user's security context) bind mounted on
.\" public directories such as /tmp, thus providing an instance of
.\" /tmp that is based on user's security context. Without the
.\" unshare system call, namespace separation can only be achieved
.\" by clone, which would require porting and maintaining all commands
.\" such as login, and su, that establish a user session.
.\"
.TH UNSHARE 2 2013-04-17 "Linux" "Linux Programmer's Manual"
.SH NAME
unshare \- disassociate parts of the process execution context
.SH SYNOPSIS
.nf
.B #include <sched.h>
.sp
.BI "int unshare(int " flags );
.fi
.sp
.in -4n
Feature Test Macro Requirements for glibc (see
.BR feature_test_macros (7)):
.in
.sp
.BR unshare ():
.ad l
.RS 4
.PD 0
.TP 4
Since glibc 2.14:
_GNU_SOURCE
.TP 4
.\" See http://sources.redhat.com/bugzilla/show_bug.cgi?id=4749
Before glibc 2.14:
_BSD_SOURCE || _SVID_SOURCE
    /* _GNU_SOURCE also suffices */
.PD
.RE
.ad b
.SH DESCRIPTION
.BR unshare ()
allows a process to disassociate parts of its execution
context that are currently being shared with other processes.
Part of the execution context, such as the mount namespace, is shared
implicitly when a new process is created using
.BR fork (2)
or
.BR vfork (2),
while other parts, such as virtual memory, may be
shared by explicit request when creating a process using
.BR clone (2).

The main use of
.BR unshare ()
is to allow a process to control its
shared execution context without creating a new process.

The
.I flags
argument is a bit mask that specifies which parts of
the execution context should be unshared.
This argument is specified by ORing together zero or more
of the following constants:
.TP
.B CLONE_FILES
Reverse the effect of the
.BR clone (2)
.B CLONE_FILES
flag.
Unshare the file descriptor table, so that the calling process
no longer shares its file descriptors with any other process.
.TP
.B CLONE_FS
Reverse the effect of the
.BR clone (2)
.B CLONE_FS
flag.
Unshare filesystem attributes, so that the calling process
no longer shares its root directory
.RB ( chroot (2)),
current directory
.RB ( chdir (2)),
or umask
.RB ( umask (2))
attributes with any other process.
.TP
.BR CLONE_NEWIPC " (since Linux 2.6.19)
This flag has the same effect as the
.BR clone (2)
.B CLONE_NEWIPC
flag.
Unshare the System\ V IPC namespace,
so that the calling process has a private copy of the
System\ V IPC namespace which is not shared with any other process.
Specifying this flag automatically implies
.BR CLONE_SYSVSEM
as well.
Use of
.BR CLONE_NEWIPC
requires the
.BR CAP_SYS_ADMIN
capability.
.TP
.BR CLONE_NEWNET " (since Linux 2.6.24)
This flag has the same effect as the
.BR clone (2)
.B CLONE_NEWNET
flag.
Unshare the network namespace,
so that the calling process is moved into a
new network namespace which is not shared
with any previously existing process.
Use of
.BR CLONE_NEWNET
requires the
.BR CAP_SYS_ADMIN
capability.
.TP
.B CLONE_NEWNS
.\" These flag name are inconsistent:
.\" CLONE_NEWNS does the same thing in clone(), but CLONE_VM,
.\" CLONE_FS, and CLONE_FILES reverse the action of the clone()
.\" flags of the same name.
This flag has the same effect as the
.BR clone (2)
.B CLONE_NEWNS
flag.
Unshare the mount namespace,
so that the calling process has a private copy of
its namespace which is not shared with any other process.
Specifying this flag automatically implies
.B CLONE_FS
as well.
Use of
.BR CLONE_NEWNS
requires the
.BR CAP_SYS_ADMIN
capability.
.TP
.BR CLONE_NEWPID " (since Linux 3.8)"
This flag has the same effect as the
.BR clone (2)
.B CLONE_NEWPID
flag.
Unshare the PID namespace,
so that the calling process has a new PID namespace for its children
which is not shared with any previously existing process.
The calling process is
.I not
moved into the new namespace.
The first child created by the calling process will have
the process ID 1 and will assume the role of
.BR init (1)
in the new namespace.
.BR CLONE_NEWPID
automatically implies
.BR CLONE_THREAD
as well.
Use of
.BR CLONE_NEWPID
requires the
.BR CAP_SYS_ADMIN
capability.
For further information, see
.BR pid_namespaces (7).
.TP
.BR CLONE_NEWUSER " (since Linux 3.8)"
This flag has the same effect as the
.BR clone (2)
.B CLONE_NEWUSER
flag.
Unshare the user namespace,
so that the calling process is moved into a new user namespace
which is not shared with any previously existing process.
As with the child process created by
.BR clone (2)
with the
.B CLONE_NEWUSER
flag, the caller obtains a full set of capabilities in the new namespace.
.IP
.BR CLONE_NEWUSER
requires that the calling process is not threaded; specifying
.BR CLONE_NEWUSER
automatically implies
.BR CLONE_THREAD .
Since Linux 3.9,
.\" commit e66eded8309ebf679d3d3c1f5820d1f2ca332c71
.\" https://lwn.net/Articles/543273/
.BR CLONE_NEWUSER
also automatically implies
.BR CLONE_FS .
.BR CLONE_NEWUSER
requires that the user ID and group ID
of the calling process are mapped to user IDs and group IDs in the
user namespace of the calling process at the time of the call.

For further information on user namespaces, see
.BR user_namespaces (7).
.TP
.BR CLONE_NEWUTS " (since Linux 2.6.19)"
This flag has the same effect as the
.BR clone (2)
.B CLONE_NEWUTS
flag.
Unshare the UTS IPC namespace,
so that the calling process has a private copy of the
UTS namespace which is not shared with any other process.
Use of
.BR CLONE_NEWUTS
requires the
.BR CAP_SYS_ADMIN
capability.
.TP
.BR CLONE_SYSVSEM " (since Linux 2.6.26)
.\" commit 9edff4ab1f8d82675277a04e359d0ed8bf14a7b7
This flag reverses the effect of the
.BR clone (2)
.B CLONE_SYSVSEM
flag.
Unshare System\ V semaphore adjustment
.RI ( semadj )
values,
so that the calling process has a new empty
.I semadj
list that is not shared with any other process.
If this is the last process that has a reference to the process's current
.I semadj
list, then the adjustments in that list are applied
to the corresponding semaphores, as described in
.BR semop (2).
.\" CLONE_NEWNS If CLONE_SIGHAND is set and signals are also being shared
.\" (i.e., current->signal->count > 1), force CLONE_THREAD.
.PP
In addition,
.BR CLONE_THREAD ,
.BR CLONE_SIGHAND ,
and
.BR CLONE_VM
can be specified in
.I flags
if the caller is single threaded (i.e., it is not sharing
its address space with another process or thread).
In this case, these flags have no effect.
.\" As at 3.9, the following forced implications also apply,
.\" although the relevant flags are not yet implemented.
.\" If CLONE_THREAD is set force CLONE_VM.
.\" If CLONE_VM is set, force CLONE_SIGHAND.
.\"
If the process is multithreaded, then
the use of these flags results in an error.
.\" See kernel/fork.c::check_unshare_flags()
.PP
If
.I flags
is specified as zero, then
.BR unshare ()
is a no-op;
no changes are made to the calling process's execution context.
.SH RETURN VALUE
On success, zero returned.
On failure, \-1 is returned and
.I errno
is set to indicate the error.
.SH ERRORS
.TP
.B EINVAL
An invalid bit was specified in
.IR flags .
.TP
.B EINVAL
.BR CLONE_THREAD ,
.BR CLONE_SIGHAND ,
or
.BR CLONE_VM
was specified in
.IR flags ,
and the caller is multithreaded.
.TP
.B ENOMEM
Cannot allocate sufficient memory to copy parts of caller's
context that need to be unshared.
.TP
.B EPERM
The calling process did not have the required privileges for this operation.
.TP
.B EPERM
.BR CLONE_NEWUSER
was specified in
.IR flags ,
but either the effective user ID or the effective group ID of the caller
does not have a mapping in the parent namespace (see
.BR user_namespaces (7)).
.TP
.BR EPERM " (since Linux 3.9)"
.\" commit 3151527ee007b73a0ebd296010f1c0454a919c7d
.B CLONE_NEWUSER was specified in
.I flags
and the caller is in a chroot environment
.\" FIXME What is the rationale for this restriction?
(i.e., the caller's root directory does not match the root directory
of the mount namespace in which it resides).
.TP
.BR EUSERS " (since Linux 3.11)"
.B CLONE_NEWUSER
was specified in
.IR flags ,
and the call would cause the limit on the number of
nested user namespaces to be exceeded.
See
.BR user_namespaces (7).
.SH VERSIONS
The
.BR unshare ()
system call was added to Linux in kernel 2.6.16.
.SH CONFORMING TO
The
.BR unshare ()
system call is Linux-specific.
.SH NOTES
Not all of the process attributes that can be shared when
a new process is created using
.BR clone (2)
can be unshared using
.BR unshare ().
In particular, as at kernel 3.8,
.\" FIXME all of the following needs to be reviewed for the current kernel
.BR unshare ()
does not implement flags that reverse the effects of
.BR CLONE_SIGHAND ,
.\" However, we can do unshare(CLONE_SIGHAND) if CLONE_SIGHAND
.\" was not specified when doing clone(); i.e., unsharing
.\" signal handlers is permitted if we are not actually
.\" sharing signal handlers.   mtk
.BR CLONE_THREAD ,
or
.BR CLONE_VM .
.\" However, we can do unshare(CLONE_VM) if CLONE_VM
.\" was not specified when doing clone(); i.e., unsharing
.\" virtual memory is permitted if we are not actually
.\" sharing virtual memory.   mtk
Such functionality may be added in the future, if required.
.\"
.\"9) Future Work
.\"--------------
.\"The current implementation of unshare does not allow unsharing of
.\"signals and signal handlers. Signals are complex to begin with and
.\"to unshare signals and/or signal handlers of a currently running
.\"process is even more complex. If in the future there is a specific
.\"need to allow unsharing of signals and/or signal handlers, it can
.\"be incrementally added to unshare without affecting legacy
.\"applications using unshare.
.\"
.SH EXAMPLE
The program below provides a simple implementation of the
.BR unshare (1)
command, which unshares one or more namespaces and executes the
command supplied in its command-line arguments.
Here's an example of the use of this program,
running a shell in a new mount namespace,
and verifying that the original shell and the
new shell are in separate mount namespaces:
.in +4n
.nf

$ \fBreadlink /proc/$$/ns/mnt\fP
mnt:[4026531840]
$ \fBsudo ./unshare -m /bin/bash\fP
[sudo] password for cecilia:
# \fBreadlink /proc/$$/ns/mnt\fP
mnt:[4026532325]
.fi
.in

The differing output of the two
.BR readlink (1)
commands shows that the two shells are in different mount namespaces.
.SS Program source
\&
.nf
/* unshare.c 

   A simple implementation of the unshare(1) command: unshare
   namespaces and execute a command.
*/
#define _GNU_SOURCE
#include <sched.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

/* A simple error\-handling function: print an error message based
   on the value in \(aqerrno\(aq and terminate the calling process */

#define errExit(msg)    do { perror(msg); exit(EXIT_FAILURE); \\
                        } while (0)

static void
usage(char *pname)
{
    fprintf(stderr, "Usage: %s [options] program [arg...]\\n", pname);
    fprintf(stderr, "Options can be:\\n");
    fprintf(stderr, "    \-i   unshare IPC namespace\\n");
    fprintf(stderr, "    \-m   unshare mount namespace\\n");
    fprintf(stderr, "    \-n   unshare network namespace\\n");
    fprintf(stderr, "    \-p   unshare PID namespace\\n");
    fprintf(stderr, "    \-u   unshare UTS namespace\\n");
    fprintf(stderr, "    \-U   unshare user namespace\\n");
    exit(EXIT_FAILURE);
}

int
main(int argc, char *argv[])
{
    int flags, opt;

    flags = 0;

    while ((opt = getopt(argc, argv, "imnpuU")) != \-1) {
        switch (opt) {
        case \(aqi\(aq: flags |= CLONE_NEWIPC;        break;
        case \(aqm\(aq: flags |= CLONE_NEWNS;         break;
        case \(aqn\(aq: flags |= CLONE_NEWNET;        break;
        case \(aqp\(aq: flags |= CLONE_NEWPID;        break;
        case \(aqu\(aq: flags |= CLONE_NEWUTS;        break;
        case \(aqU\(aq: flags |= CLONE_NEWUSER;       break;
        default:  usage(argv[0]);
        }
    }

    if (optind >= argc)
        usage(argv[0]);

    if (unshare(flags) == \-1)
        errExit("unshare");

    execvp(argv[optind], &argv[optind]);  
    errExit("execvp");
}
.fi
.SH SEE ALSO
.BR unshare (1),
.BR clone (2),
.BR fork (2),
.BR kcmp (2),
.BR setns (2),
.BR vfork (2),
.BR namespaces (7)

.I Documentation/unshare.txt
in the Linux kernel source tree

--------------050209000107050606050708
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--------------050209000107050606050708--
