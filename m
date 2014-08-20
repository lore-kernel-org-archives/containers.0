From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: For review: setns(2) man page [RESEND]
Date: Wed, 20 Aug 2014 18:42:13 -0500
Message-ID: <53F53255.10201@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------070802060803030406080204"
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
--------------070802060803030406080204
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

[Messed up Eric's email address on first send. Resending...]


Hello Eric et al.

With the namespaces changes, a number of additions have been=20
made to the setns(2) man page, so I will send out the entire page
for review at the same time as the various namespaces page.
The rendered version is below, and the source is attached.

Review comments/suggestions for improvements / bug fixes welcome.

Cheers,

Michael

=3D=3D=3D  =20

NAME
       setns - reassociate thread with a namespace

SYNOPSIS
       #define _GNU_SOURCE             /* See feature_test_macros(7) */
       #include <sched.h>

       int setns(int fd, int nstype);

DESCRIPTION
       Given a file descriptor referring to a namespace, reassociate the
       calling thread with that namespace.

       The fd argument is a file descriptor  referring  to  one  of  the
       namespace  entries  in  a  /proc/[pid]/ns/  directory; see names=E2=
=80=90
       paces(5) for further information on /proc/[pid]/ns/.  The calling
       thread  will  be  reassociated  with the corresponding namespace,
       subject to any constraints imposed by the nstype argument.

       The nstype argument specifies which type of namespace the calling
       thread  may  be reassociated with.  This argument can have one of
       the following values:

       0      Allow any type of namespace to be joined.

       CLONE_NEWIPC (since Linux 3.0)
              fd must refer to an IPC namespace.

       CLONE_NEWNET (since Linux 3.0)
              fd must refer to a network namespace.

       CLONE_NEWNS (since Linux 3.8)
              fd must refer to a mount namespace.

       CLONE_NEWPID (since Linux 3.8)
              fd must refer to a PID namespace.

       CLONE_NEWUSER (since Linux 3.8)
              fd must refer to a user namespace.

       CLONE_NEWUTS (since Linux 3.0)
              fd must refer to a UTS namespace.

       Specifying nstype as 0 suffices if the caller knows (or does  not
       care)  what type of namespace is referred to by fd.  Specifying a
       nonzero value for nstype is useful if the caller  does  not  know
       what  type  of namespace is referred to by fd and wants to ensure
       that the namespace is of a particular type.   (The  caller  might
       not  know the type of the namespace referred to by fd if the file
       descriptor was opened by another process and, for example, passed
       to the caller via a UNIX domain socket.)

       CLONE_NEWPID  behaves  somewhat differently from the other nstype
       values: reassociating the calling thread  with  a  PID  namespace
       only changes the PID namespace that child processes of the caller
       will be created in; it does not change the PID namespace  of  the
       caller  itself.   Reassociating  with  a  PID  namespace  is only
       allowed if the PID namespace specified  by  fd  is  a  descendant
       (child,  grandchild,  etc.)   of the PID namespace of the caller.
       For further details on PID namespaces, see user_namespaces(7).

       A process reassociating itself with a user  namespace  must  have
       the  CAP_SYS_ADMIN capability in the target user namespace.  Upon
       successfully joining a user namespace, a process is  granted  all
       capabilities  in that namespace, regardless of its user and group
       IDs.  A multithreaded process may not change user namespace  with
       setns().  It is not permitted to use setns() to reenter the call=E2=
=80=90
       er's current user namespace.  This prevents  a  caller  that  has
       dropped capabilities from regaining those capabilities via a call
       to setns().  For security reasons, a process  can't  join  a  new
       user  namespace  if  it  is sharing filesystem-related attributes
       (the attributes whose  sharing  is  controlled  by  the  clone(2)
       CLONE_FS flag) with another process.  For further details on user
       namespaces, see user_namespaces(7).

       A process may not be reassociated with a new mount  namespace  if
       it  is multithreaded.  Changing the mount namespace requires that
       the caller possess both CAP_SYS_CHROOT and CAP_SYS_ADMIN capabil=E2=
=80=90
       ities  in  its own user namespace and CAP_SYS_ADMIN in the target
       mount namespace.

RETURN VALUE
       On success, setns() returns 0.  On failure, -1  is  returned  and
       errno is set to indicate the error.

ERRORS
       EBADF  fd is not a valid file descriptor.

       EINVAL fd  refers  to  a namespace whose type does not match that
              specified in nstype.

       EINVAL There is problem with reassociating the  thread  with  the
              specified namespace.

       EINVAL The  caller  attempted to join the user namespace in which
              it is already a member.

       EINVAL The caller shares filesystem (CLONE_FS) state (in particu=E2=
=80=90
              lar, the root directory) with other processes and tried to
              join a new user namespace.

       EINVAL The caller is multithreaded and tried to join a  new  user
              namespace.

       ENOMEM Cannot  allocate sufficient memory to change the specified
              namespace.

       EPERM  The calling thread did not have  the  required  capability
              for this operation.

VERSIONS
       The  setns()  system  call first appeared in Linux in kernel 3.0;
       library support was added to glibc in version 2.14.

CONFORMING TO
       The setns() system call is Linux-specific.

NOTES
       Not all of the attributes that can be shared when a new thread is
       created using clone(2) can be changed using setns().

EXAMPLE
       The  program  below takes two or more arguments.  The first argu=E2=
=80=90
       ment specifies the pathname of a namespace file  in  an  existing
       /proc/[pid]/ns/  directory.   The  remaining  arguments specify a
       command and its arguments.  The program opens the namespace file,
       joins  that  namespace  using setns(), and executes the specified
       command inside that namespace.

       The following shell session demonstrates the use of this  program
       (compiled  as  a  binary  named  ns_exec) in conjunction with the
       CLONE_NEWUTS example program in the clone(2) man  page  (complied
       as a binary named newuts).

       We  begin  by  executing  the  example program in clone(2) in the
       background.  That program creates  a  child  in  a  separate  UTS
       namespace.   The child changes the hostname in its namespace, and
       then both processes display the hostnames  in  their  UTS  names=E2=
=80=90
       paces, so that we can see that they are different.

           $ su                   # Need privilege for namespace operatio=
ns
           Password:
           # ./newuts bizarro &
           [1] 3549
           clone() returned 3550
           uts.nodename in child:  bizarro
           uts.nodename in parent: antero
           # uname -n             # Verify hostname in the shell
           antero

       We then run the program shown below, using it to execute a shell.
       Inside that shell, we verify that the hostname is the one set  by
       the child created by the first program:

           # ./ns_exec /proc/3550/ns/uts /bin/bash
           # uname -n             # Executed in shell started by ns_exec
           bizarro

   Program source
       #define _GNU_SOURCE
       #include <fcntl.h>
       #include <sched.h>
       #include <unistd.h>
       #include <stdlib.h>
       #include <stdio.h>

       #define errExit(msg)    do { perror(msg); exit(EXIT_FAILURE); \
                               } while (0)

       int
       main(int argc, char *argv[])
       {
           int fd;

           if (argc < 3) {
               fprintf(stderr, "%s /proc/PID/ns/FILE cmd args...\n", argv=
[0]);
               exit(EXIT_FAILURE);
           }

           fd =3D open(argv[1], O_RDONLY);   /* Get descriptor for namesp=
ace */
           if (fd =3D=3D -1)
               errExit("open");

           if (setns(fd, 0) =3D=3D -1)         /* Join that namespace */
               errExit("setns");

           execvp(argv[2], &argv[2]);      /* Execute a command in namesp=
ace */
           errExit("execvp");
       }

SEE ALSO
       clone(2), fork(2), unshare(2), vfork(2), namespaces(7), unix(7)


--=20
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/


--------------070802060803030406080204
Content-Type: application/x-troff-man;
 name="setns.2"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="setns.2"

.\" Copyright (C) 2011, Eric Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
.\" and Copyright (C) 2011, 2012, Michael Kerrisk <mtk.manpages-zHaIU10uUXsAvxtiuMwx3w@public.gmane.org>
.\"
.\" %%%LICENSE_START(GPLv2_ONELINE)
.\" Licensed under the GPLv2
.\" %%%LICENSE_END
.\"
.TH SETNS 2 2013-01-01 "Linux" "Linux Programmer's Manual"
.SH NAME
setns \- reassociate thread with a namespace
.SH SYNOPSIS
.nf
.BR "#define _GNU_SOURCE" "             /* See feature_test_macros(7) */"
.B #include <sched.h>
.sp
.BI "int setns(int " fd ", int " nstype );
.fi
.SH DESCRIPTION
Given a file descriptor referring to a namespace,
reassociate the calling thread with that namespace.

The
.I fd
argument is a file descriptor referring to one of the namespace entries in a
.I /proc/[pid]/ns/
directory; see
.BR namespaces (5)
for further information on
.IR /proc/[pid]/ns/ .
The calling thread will be reassociated with the corresponding namespace,
subject to any constraints imposed by the
.I nstype
argument.

The
.I nstype
argument specifies which type of namespace
the calling thread may be reassociated with.
This argument can have one of the following values:
.TP
.BR 0
Allow any type of namespace to be joined.
.TP
.BR CLONE_NEWIPC " (since Linux 3.0)"
.I fd
must refer to an IPC namespace.
.TP
.BR CLONE_NEWNET " (since Linux 3.0)"
.I fd
must refer to a network namespace.
.TP
.BR CLONE_NEWNS " (since Linux 3.8)"
.I fd
must refer to a mount namespace.
.TP
.BR CLONE_NEWPID " (since Linux 3.8)"
.I fd
must refer to a PID namespace.
.TP
.BR CLONE_NEWUSER " (since Linux 3.8)"
.I fd
must refer to a user namespace.
.TP
.BR CLONE_NEWUTS " (since Linux 3.0)"
.I fd
must refer to a UTS namespace.
.PP
Specifying
.I nstype
as 0 suffices if the caller knows (or does not care)
what type of namespace is referred to by
.IR fd .
Specifying a nonzero value for
.I nstype
is useful if the caller does not know what type of namespace is referred to by
.IR fd
and wants to ensure that the namespace is of a particular type.
(The caller might not know the type of the namespace referred to by
.IR fd
if the file descriptor was opened by another process and, for example,
passed to the caller via a UNIX domain socket.)

.B CLONE_NEWPID
behaves somewhat differently from the other
.I nstype
values:
reassociating the calling thread with a PID namespace only changes
the PID namespace that child processes of the caller will be created in;
it does not change the PID namespace of the caller itself.
Reassociating with a PID namespace is only allowed if the
PID namespace specified by
.IR fd
is a descendant (child, grandchild, etc.)
of the PID namespace of the caller.
For further details on PID namespaces, see
.BR user_namespaces (7).

A process reassociating itself with a user namespace must have the
.B CAP_SYS_ADMIN
.\" See kernel/user_namespace.c:userns_install() [3.8 source]
capability in the target user namespace.
Upon successfully joining a user namespace,
a process is granted all capabilities in that namespace,
regardless of its user and group IDs.
A multithreaded process may not change user namespace with
.BR setns ().
It is not permitted to use
.BR setns ()
to reenter the caller's current user namespace.
This prevents a caller that has dropped capabilities from regaining
those capabilities via a call to
.BR setns ().
For security reasons,
.\" commit e66eded8309ebf679d3d3c1f5820d1f2ca332c71
.\" https://lwn.net/Articles/543273/
a process can't join a new user namespace if it is sharing
filesystem-related attributes
(the attributes whose sharing is controlled by the
.BR clone (2)
.B CLONE_FS
flag) with another process.
For further details on user namespaces, see
.BR user_namespaces (7).

A process may not be reassociated with a new mount namespace if it is
multithreaded.
.\" Above check is in fs/namespace.c:mntns_install() [3.8 source]
Changing the mount namespace requires that the caller possess both
.B CAP_SYS_CHROOT
and
.BR CAP_SYS_ADMIN 
capabilities in its own user namespace and
.BR CAP_SYS_ADMIN 
in the target mount namespace.
.SH RETURN VALUE
On success,
.IR setns ()
returns 0.
On failure, \-1 is returned and
.I errno
is set to indicate the error.
.SH ERRORS
.TP
.B EBADF
.I fd
is not a valid file descriptor.
.TP
.B EINVAL
.I fd
refers to a namespace whose type does not match that specified in
.IR nstype .
.TP
.B EINVAL
There is problem with reassociating
the thread with the specified namespace.
.TP
.B EINVAL
The caller attempted to join the user namespace
in which it is already a member.
.TP
.B EINVAL
.\" commit e66eded8309ebf679d3d3c1f5820d1f2ca332c71
The caller shares filesystem
.RB ( CLONE_FS )
state (in particular, the root directory)
with other processes and tried to join a new user namespace.
.TP
.B EINVAL
.\" See kernel/user_namespace.c::userns_install() [kernel 3.15 sources]
The caller is multithreaded and tried to join a new user namespace.
.TP
.B ENOMEM
Cannot allocate sufficient memory to change the specified namespace.
.TP
.B EPERM
The calling thread did not have the required capability
for this operation.
.SH VERSIONS
The
.BR setns ()
system call first appeared in Linux in kernel 3.0;
library support was added to glibc in version 2.14.
.SH CONFORMING TO
The
.BR setns ()
system call is Linux-specific.
.SH NOTES
Not all of the attributes that can be shared when
a new thread is created using
.BR clone (2)
can be changed using
.BR setns ().
.SH EXAMPLE
The program below takes two or more arguments.
The first argument specifies the pathname of a namespace file in an existing
.I /proc/[pid]/ns/
directory.
The remaining arguments specify a command and its arguments.
The program opens the namespace file, joins that namespace using
.BR setns (),
and executes the specified command inside that namespace.

The following shell session demonstrates the use of this program
(compiled as a binary named
.IR ns_exec )
in conjunction with the
.BR CLONE_NEWUTS
example program in the
.BR clone (2)
man page (complied as a binary named
.IR newuts ).

We begin by executing the example program in
.BR clone (2)
in the background.
That program creates a child in a separate UTS namespace.
The child changes the hostname in its namespace,
and then both processes display the hostnames in their UTS namespaces,
so that we can see that they are different.

.nf
.in +4n
$ \fBsu\fP                   # Need privilege for namespace operations
Password:
# \fB./newuts bizarro &\fP
[1] 3549
clone() returned 3550
uts.nodename in child:  bizarro
uts.nodename in parent: antero
# \fBuname \-n\fP             # Verify hostname in the shell
antero
.in
.fi

We then run the program shown below,
using it to execute a shell.
Inside that shell, we verify that the hostname is the one
set by the child created by the first program:

.nf
.in +4n
# \fB./ns_exec /proc/3550/ns/uts /bin/bash\fP
# \fBuname \-n\fP             # Executed in shell started by ns_exec
bizarro
.in
.fi
.SS Program source
.nf
#define _GNU_SOURCE
#include <fcntl.h>
#include <sched.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

#define errExit(msg)    do { perror(msg); exit(EXIT_FAILURE); \\
                        } while (0)

int
main(int argc, char *argv[])
{
    int fd;

    if (argc < 3) {
        fprintf(stderr, "%s /proc/PID/ns/FILE cmd args...\\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    fd = open(argv[1], O_RDONLY);   /* Get descriptor for namespace */
    if (fd == \-1)
        errExit("open");

    if (setns(fd, 0) == \-1)         /* Join that namespace */
        errExit("setns");

    execvp(argv[2], &argv[2]);      /* Execute a command in namespace */
    errExit("execvp");
}
.fi
.SH SEE ALSO
.BR clone (2),
.BR fork (2),
.BR unshare (2),
.BR vfork (2),
.BR namespaces (7),
.BR unix (7)


--------------070802060803030406080204
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--------------070802060803030406080204--
