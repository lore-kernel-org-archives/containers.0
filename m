From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: For review (v2): user_namespaces(7) man page
Date: Wed, 27 Mar 2013 22:26:07 +0100
Message-ID: <CAKgNAkjgmTJ1BiHVbqVtz-g-=yfewMiYaroDJELJpa1aRrFAvQ@mail.gmail.com>
Reply-To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=047d7b86e75adc236304d8eeb01f
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
Cc: linux-man <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

--047d7b86e75adc236304d8eeb01f
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi Eric et al.,

All: The attached page aims to provide a fairly complete overview of
user namespaces. I'm looking for review comments (corrections,
improvements, additions, etc.) on this man page. I've provided it in
two forms inline below, and reviewers can comment on whichever form
they are most comfortable with:

1) The rendered page as plain text
2) The *roff source (also attached); rendering that source will enable
readers to see proper formatting for the page.

Note that the namespaces(7) page referred to in this page is not yet
finished; I'll send it out for review at a future time.

Main change since v1 is to address Serge's comments here:
http://thread.gmane.org/gmane.linux.man/3745/focus=3D1457720

Cheers,

Michael

=3D=3D=3D=3D=3D

USER_NAMESPACES(7)     Linux Programmer's Manual    USER_NAMESPACES(7)



NAME
       user_namespaces - overview of Linux user_namespaces

DESCRIPTION
       For an overview of namespaces, see namespaces(7).

       User  namespaces  isolate security-related identifiers, in par=E2=80=
=90
       ticular, user IDs and group IDs (see credentials(7), keys  (see
       keyctl(2)),   and   capabilities   (see   capabilities(7)).   A
       process's user and group IDs can be different inside  and  out=E2=80=
=90
       side  a  user  namespace.   In particular, a process can have a
       normal unprivileged user ID outside a user namespace  while  at
       the  same  time  having a user ID of 0 inside the namespace; in
       other words, the process has  full  privileges  for  operations
       inside  the  user namespace, but is unprivileged for operations
       outside the namespace.

   Nested namespaces, namespace membership
       User namespaces can be nested; that is,  each  user  namespace=E2=80=
=94
       except  the initial ("root") namespace=E2=80=94has a parent user nam=
es=E2=80=90
       pace, and can have zero or more  child  user  namespaces.   The
       parent user namespace is the user namespace of the process that
       creates the user namespace via a call to unshare(2) or clone(2)
       with the CLONE_NEWUSER flag.

       Each  process  is  a  member  of exactly one user namespace.  A
       process  created  via   fork(2)   or   clone(2)   without   the
       CLONE_NEWUSER  flag  is  a member of the same user namespace as
       its parent.  A process can join  another  user  namespace  with
       setns(2)  if  it  has the CAP_SYS_ADMIN in that namespace; upon
       doing so, it gains a full set of capabilities  in  that  names=E2=80=
=90
       pace.

       A  call  to  clone(2) or unshare(2) with the CLONE_NEWUSER flag
       makes the new child process (for clone(2)) or the  caller  (for
       unshare(2))  a  member of the new user namespace created by the
       call.

   Capabilities
       The child process created by clone(2)  with  the  CLONE_NEWUSER
       flag  starts out with a complete set of capabilities in the new
       user namespace.  Likewise, a process that creates  a  new  user
       namespace  using unshare(2) or joins an existing user namespace
       using setns(2) gains a full set of capabilities in that  names=E2=80=
=90
       pace.   On  the other hand, that process has no capabilities in
       the parent (in the case of clone(2)) or previous (in  the  case
       of  unshare(2)  and  setns(2))  user namespace, even if the new
       namespace is created or  joined  by  the  root  user  (i.e.,  a
       process with user ID 0 in the root namespace).  Nevertheless, a
       process owned by the root user will be able to access resources
       such  as files that are owned by user ID 0, and will be able to
       do things such as sending signals  to  processes  belonging  to
       user ID 0.

       Note  that a call to execve(2) will cause a process to lose any
       capabilities that it has, unless it has a user ID of  0  within
       the  namespace.  Thus, before calling execve(2), a user ID map=E2=80=
=90
       ping for ID 0 must be defined, and the caller may also need  to
       use setuid(2) or similar to set its user ID to 0.

       A   call   to  clone(2),  unshare(2),  or  setns(2)  using  the
       CLONE_NEWUSER flag sets the "securebits" flags  (see  capabili=E2=80=
=90
       ties(7))  to  their  default values (all flags disabled) in the
       child (for clone(2)) or caller (for unshare(2),  or  setns(2)).
       Note  that because the caller no longer has capabilities in its
       original user namespace after a call to  setns(2),  it  is  not
       possible  for  a  process to reset its "securebits" flags while
       retaining its user namespace membership  by  using  a  pair  of
       setns(2)  calls  to  move  to  another  user namespace and then
       return to its original user namespace.

       Having a capability inside a user namespace permits  a  process
       to   perform   operations  (that  require  privilege)  only  on
       resources governed by that namespace.  The rules for  determin=E2=80=
=90
       ing  whether  or not a process has a capability in a particular
       user namespace are as follows:

       1. A process has a capability inside a user namespace if it  is
          a  member of that namespace and it has the capability in its
          effective capability set.  A process can  gain  capabilities
          in  its effective capability set in various ways.  For exam=E2=80=
=90
          ple, it may execute a set-user-ID program or  an  executable
          with  associated  file capabilities.  In addition, a process
          may  gain  capabilities  via   the   effect   of   clone(2),
          unshare(2), or setns(2), as already described.

       2. If  a  process has a capability in a user namespace, then it
          has that  capability  in  all  child  (and  further  removed
          descendant) namespaces as well.

       3. When  a  user  namespace  is created, the kernel records the
          effective user ID of  the  creating  process  as  being  the
          "owner"  of  the  namespace.   A process that resides in the
          parent of the user namespace and  whose  effective  user  ID
          matches  the  owner of the namespace has all capabilities in
          the namespace.  By virtue of the previous rule,  this  means
          that the process has all capabilities in all further removed
          descendant user namespaces as well.

   Interaction of user namespaces and other types of namespaces
       Starting in Linux 3.8, unprivileged processes can  create  user
       namespaces,  and  mount,  PID, IPC, network, and UTS namespaces
       can be created with just the CAP_SYS_ADMIN  capability  in  the
       caller's user namespace.

       If CLONE_NEWUSER is specified along with other CLONE_NEW* flags
       in a single clone(2) or unshare(2) call, the user namespace  is
       guaranteed  to be created first, giving the child (clone(2)) or
       caller (unshare(2)) privileges over  the  remaining  namespaces
       created  by the call.  Thus, it is possible for an unprivileged
       caller to specify this combination of flags.

       When a new IPC, mount, network, PID, or UTS namespace  is  cre=E2=80=
=90
       ated  via  clone(2)  or unshare(2), the kernel records the user
       namespace of the creating process against  the  new  namespace.
       (This association can't be changed.)  When a process in the new
       namespace  subsequently  performs  privileged  operations  that
       operate on global resources isolated by the namespace, the per=E2=80=
=90
       mission checks are performed according to the  process's  capa=E2=80=
=90
       bilities  in the user namespace that the kernel associated with
       the new namespace.

   User and group ID mappings: uid_map and gid_map
       When a user namespace is created, it starts out without a  map=E2=80=
=90
       ping of user IDs (group IDs) to the parent user namespace.  The
       /proc/[pid]/uid_map and  /proc/[pid]/gid_map  files  (available
       since  Linux  3.5)  expose  the mappings for user and group IDs
       inside the user namespace for the process pid.  These files can
       be read to view the mappings in a user namespace and written to
       (once) to define the mappings.

       The  description  in  the  following  paragraphs  explains  the
       details  for  uid_map;  gid_map  is  exactly the same, but each
       instance of "user ID" is replaced by "group ID".

       The uid_map file exposes the mapping of user IDs from the  user
       namespace  of  the  process  pid  to  the user namespace of the
       process that opened uid_map (but see a  qualification  to  this
       point  below).  In other words, processes that are in different
       user namespaces will  potentially  see  different  values  when
       reading  from  a particular uid_map file, depending on the user
       ID mappings for the user namespaces of the reading processes.

       Each line in the uid_map file specifies a 1-to-1 mapping  of  a
       range  of  contiguous  user  IDs  between  two user namespaces.
       (When a user namespace is first created, this file  is  empty.)
       The  specification in each line takes the form of three numbers
       delimited by white space.  The first two  numbers  specify  the
       starting user ID in each of the two user namespaces.  The third
       number specifies the length of the mapped  range.   In  detail,
       the fields are interpreted as follows:

       (1) The start of the range of user IDs in the user namespace of
           the process pid.

       (2) The start of the range of user IDs to which  the  user  IDs
           specified  by  field one map.  How field two is interpreted
           depends on whether the process that opened uid_map and  the
           process pid are in the same user namespace, as follows:

           a) If  the  two processes are in different user namespaces:
              field two is the start of a range of  user  IDs  in  the
              user namespace of the process that opened uid_map.

           b) If  the  two  processes  are in the same user namespace:
              field two is the start of the range of user IDs  in  the
              parent  user  namespace  of  the process pid.  This case
              enables the opener of uid_map (the common case  here  is
              opening  /proc/self/uid_map)  to see the mapping of user
              IDs into the user namespace of the process that  created
              this user namespace.

       (3) The  length of the range of user IDs that is mapped between
           the two user namespaces.

       System calls that return  user  IDs  (group  IDs)=E2=80=94for  examp=
le,
       getuid(2),  getgid(2),  and the credential fields in the struc=E2=80=
=90
       ture returned by stat(2)=E2=80=94return the user ID (group  ID)  map=
ped
       into the caller's user namespace.

       When  a  process  accesses  a  file, its user and group IDs are
       mapped into the initial user namespace for the purpose of  per=E2=80=
=90
       mission  checking and assigning IDs when creating a file.  When
       a process retrieves file user and group IDs  via  stat(2),  the
       IDs  are  mapped  in  the opposite direction, to produce values
       relative to the process user and group ID mappings.

       The initial user namespace has no parent  namespace,  but,  for
       consistency,  the  kernel provides dummy user and group ID map=E2=80=
=90
       ping files for this namespace.  Looking  at  the  uid_map  file
       (gid_map  is  the  same)  from a shell in the initial namespace
       shows:

           $ cat /proc/$$/uid_map
                    0          0 4294967295

       This mapping tells us that the range starting at user ID  0  in
       this  namespace  maps to a range starting at 0 in the (nonexis=E2=80=
=90
       tent) parent namespace, and the length  of  the  range  is  the
       largest 32-bit unsigned integer.

   Defining user and group ID mappings: writing to uid_map and gid_map
       After the creation of a new user namespace, the uid_map file of
       one of the processes in the namespace may be written to once to
       define  the  mapping of user IDs in the new user namespace.  An
       attempt to write more than once to a uid_map  file  in  a  user
       namespace  fails with the error EPERM.  Similar rules apply for
       gid_map files.

       The lines written to uid_map (gid_map) must conform to the fol=E2=80=
=90
       lowing rules:

       *  The  three  fields must be valid numbers, and the last field
          must be greater than 0.

       *  Lines are terminated by newline characters.

       *  There is an (arbitrary) limit on the number of lines in  the
          file.   As  at Linux 3.8, the limit is five lines.  In addi=E2=80=
=90
          tion, the number of bytes written to the file must  be  less
          than  the  system page size, and the write must be performed
          at the start of the file (i.e., lseek(2) and pwrite(2) can't
          be used to write to nonzero offsets in the file).

       *  The  range  of  user  IDs (group IDs) specified in each line
          cannot overlap with the ranges in any other lines.   In  the
          initial  implementation  (Linux  3.8),  this requirement was
          satisfied by a simplistic implementation  that  imposed  the
          further  requirement  that  the  values  in both field 1 and
          field 2 of successive lines must be in  ascending  numerical
          order,  which prevented some otherwise valid maps from being
          created.  Linux 3.9 and later fix this limitation,  allowing
          any valid set of nonoverlapping maps.

       *  At least one line must be written to the file.

       Writes that violate the above rules fail with the error EINVAL.

       In  order  for  a  process  to write to the /proc/[pid]/uid_map
       (/proc/[pid]/gid_map) file, all of the  following  requirements
       must be met:

       1. The  writing  process  must have the CAP_SETUID (CAP_SETGID)
          capability in the user namespace of the process pid.

       2. The writing process must be in either the user namespace  of
          the  process  pid or inside the parent user namespace of the
          process pid.

       3. The mapped user IDs (group IDs) must in turn have a  mapping
          in the parent user namespace.

       4. One of the following is true:

          *  The  data written to uid_map (gid_map) consists of a sin=E2=80=
=90
             gle line that maps the writing process's file system user
             ID  (group  ID) in the parent user namespace to a user ID
             (group ID) in the user namespace.  The usual case here is
             that  this  single line provides a mapping for user ID of
             the process that created the namespace.

          *  The process has the CAP_SETUID (CAP_SETGID) capability in
             the  parent  user  namespace.  Thus, a privileged process
             can make mappings to arbitrary user IDs  (group  IDs)  in
             the parent user namespace.

       Writes that violate the above rules fail with the error EPERM.

   Unmapped user and group IDs
       There  are  various places where an unmapped user ID (group ID)
       may be exposed to user space.  For example, the  first  process
       in a new user namespace may call getuid() before a user ID map=E2=80=
=90
       ping has been defined for the namespace.  In most  such  cases,
       an unmapped user ID is converted to the overflow user ID (group
       ID); the default value for the overflow user ID (group  ID)  is
       65534.   See  the  descriptions of /proc/sys/kernel/overflowuid
       and /proc/sys/kernel/overflowgid in proc(5).

       The cases where unmapped IDs are mapped in this fashion include
       system  calls  that  return  user IDs (getuid(2) getgid(2), and
       similar), credentials passed over a UNIX domain socket, creden=E2=80=
=90
       tials  returned  by  stat(2),  waitid(2),  and the System V IPC
       "ctl"   IPC_STAT    operations,    credentials    exposed    by
       /proc/PID/status  and the files in /proc/sysvipc/*, credentials
       returned via the si_uid field in the siginfo_t received with  a
       signal  (see  sigaction(2)), credentials written to the process
       accounting file (see acct(5)), and  credentials  returned  with
       POSIX message queue notifications (see mq_notify(3)).

       There is one notable case where unmapped user and group IDs are
       not converted to the corresponding  overflow  ID  value.   When
       viewing  a uid_map or gid_map file in which there is no mapping
       for the second field, that field is displayed as 4294967295 (-1
       as an unsigned integer);

   Set-user-ID and set-group-ID programs
       When  a  process inside a user namespace executes a set-user-ID
       (set-group-ID) program, the process's effective user (group) ID
       inside the namespace is changed to whatever value is mapped for
       the user (group) ID of the file.  However, if either  the  user
       or  the  group  ID of the file has no mapping inside the names=E2=80=
=90
       pace, the set-user-ID (set-group-ID) bit is  silently  ignored:
       the  new  program is executed, but the process's effective user
       (group) ID is left unchanged.  (This mirrors the  semantics  of
       executing a set-user-ID or set-group-ID program that resides on
       a file system that was mounted  with  the  MS_NOSUID  flag,  as
       described in mount(2).)

   Miscellaneous
       When  a  process's  user  and  group IDs are passed over a UNIX
       domain socket to a process in a different user  namespace  (see
       the description of SCM_CREDENTIALS in unix(7)), they are trans=E2=80=
=90
       lated into  the  corresponding  values  as  per  the  receiving
       process's user and group ID mappings.

CONFORMING TO
       Namespaces are a Linux-specific feature.

NOTES
       Over  the  years,  there  have been a lot of features that have
       been added to the Linux kernel that have  been  made  available
       only  to privileged users because of their potential to confuse
       set-user-ID-root applications.  In general, it becomes safe  to
       allow  the  root user in a user namespace to use those features
       because it is impossible, while in a user  namespace,  to  gain
       more privilege than the root user of a user namespace has.

   Availability
       Use  of  user  namespaces  requires a kernel that is configured
       with the CONFIG_USER_NS option.  User namespaces  require  sup=E2=80=
=90
       port  in  a  range  of  subsystems  across the kernel.  When an
       unsupported subsystem is configured into the kernel, it is  not
       possible  to  configure  user  namespaces support.  As at Linux
       3.8, most relevant  subsystems  support  user  namespaces,  but
       there  are  a  number  of  file systems that do not.  Linux 3.9
       added user namespaces support for many of the remaining  unsup=E2=80=
=90
       ported  file  systems:  Plan  9 (9P), Andrew File System (AFS),
       Ceph, CIFS, CODA, NFS, and OCFS2.  XFS support for user  names=E2=80=
=90
       paces is not yet available.

EXAMPLE
       The  program below is designed to allow experimenting with user
       namespaces, as well as other types of namespaces.   It  creates
       namespaces  as  specified by command-line options and then exe=E2=80=
=90
       cutes a command inside  those  namespaces.   The  comments  and
       usage()  function inside the program provide a full explanation
       of the program.  The following shell session  demonstrates  its
       use.

       First, we look at the run-time environment:

           $ uname -rs     # Need Linux 3.8 or later
           Linux 3.8.0
           $ id -u         # Running as unprivileged user
           1000
           $ id -g
           1000

       Now  start  a  new  shell in new user (-U), mount (-m), and PID
       (-p) namespaces, with user ID  (-M)  and  group  ID  (-G)  1000
       mapped to 0 inside the user namespace:

           $ ./userns_child_exec -p -m -U -M '0 1000 1' -G '0 1000 1' bash

       The shell has PID 1, because it is the first process in the new
       PID namespace:

           bash$ echo $$
           1

       Inside the user namespace, the shell has user and group  ID  0,
       and a full set of permitted and effective capabilities:

           bash$ cat /proc/$$/status | egrep '^[UG]id'
           Uid: 0    0    0    0
           Gid: 0    0    0    0
           bash$ cat /proc/$$/status | egrep '^Cap(Prm|Inh|Eff)'
           CapInh:   0000000000000000
           CapPrm:   0000001fffffffff
           CapEff:   0000001fffffffff

       Mounting  a  new  /proc file system and listing all of the pro=E2=80=
=90
       cesses visible in the new PID namespace shows  that  the  shell
       can't see any processes outside the PID namespace:

           bash$ mount -t proc proc /proc
           bash$ ps ax
             PID TTY      STAT   TIME COMMAND
               1 pts/3    S      0:00 bash
              22 pts/3    R+     0:00 ps ax

   Program source

       /* userns_child_exec.c

          Licensed under GNU General Public License v2 or later

          Create a child process that executes a shell command in new
          namespace(s); allow UID and GID mappings to be specified when
          creating a user namespace.
       */
       #define _GNU_SOURCE
       #include <sched.h>
       #include <unistd.h>
       #include <stdlib.h>
       #include <sys/wait.h>
       #include <signal.h>
       #include <fcntl.h>
       #include <stdio.h>
       #include <string.h>
       #include <limits.h>
       #include <errno.h>

       /* A simple error-handling function: print an error message based
          on the value in 'errno' and terminate the calling process */

       #define errExit(msg)    do { perror(msg); exit(EXIT_FAILURE); \
                               } while (0)

       struct child_args {
           char **argv;        /* Command to be executed by child, with arg=
s */
           int    pipe_fd[2];  /* Pipe used to synchronize parent and child=
 */
       };

       static int verbose;

       static void
       usage(char *pname)
       {
           fprintf(stderr, "Usage: %s [options] cmd [arg...]\n\n", pname);
           fprintf(stderr, "Create a child process that executes a shell "
                   "command in a new user namespace,\n"
                   "and possibly also other new namespace(s).\n\n");
           fprintf(stderr, "Options can be:\n\n");
       #define fpe(str) fprintf(stderr, "    %s", str);
           fpe("-i          New IPC namespace\n");
           fpe("-m          New mount namespace\n");
           fpe("-n          New network namespace\n");
           fpe("-p          New PID namespace\n");
           fpe("-u          New UTS namespace\n");
           fpe("-U          New user namespace\n");
           fpe("-M uid_map  Specify UID map for user namespace\n");
           fpe("-G gid_map  Specify GID map for user namespace\n");
           fpe("-z          Map user's UID and GID to 0 in user namespace\n=
");
           fpe("            (equivalent to: -M '0 <uid> 1' -G '0 <gid> 1')\=
n");
           fpe("-v          Display verbose messages\n");
           fpe("\n");
           fpe("If -z, -M, or -G is specified, -U is required.\n");
           fpe("It is not permitted to specify both -z and either -M or -G.=
\n");
           fpe("\n");
           fpe("Map strings for -M and -G consist of records of the form:\n=
");
           fpe("\n");
           fpe("    ID-inside-ns   ID-outside-ns   len\n");
           fpe("\n");
           fpe("A map string can contain multiple records, separated"
               " by commas;\n");
           fpe("the commas are replaced by newlines before writing"
               " to map files.\n");

           exit(EXIT_FAILURE);
       }

       /* Update the mapping file 'map_file', with the value provided in
          'mapping', a string that defines a UID or GID mapping. A UID or
          GID mapping consists of one or more newline-delimited records
          of the form:

              ID_inside-ns    ID-outside-ns   length

          Requiring the user to supply a string that contains newlines is
          of course inconvenient for command-line use. Thus, we permit the
          use of commas to delimit records in this string, and replace them
          with newlines before writing the string to the file. */

       static void
       update_map(char *mapping, char *map_file)
       {
           int fd, j;
           size_t map_len;     /* Length of 'mapping' */

           /* Replace commas in mapping string with newlines */

           map_len =3D strlen(mapping);
           for (j =3D 0; j < map_len; j++)
               if (mapping[j] =3D=3D ',')
                   mapping[j] =3D '\n';

           fd =3D open(map_file, O_RDWR);
           if (fd =3D=3D -1) {
               fprintf(stderr, "ERROR: open %s: %s\n", map_file,
strerror(errno));
               return;
               //exit(EXIT_FAILURE);
           }

           if (write(fd, mapping, map_len) !=3D map_len) {
               fprintf(stderr, "ERROR: write %s: %s\n", map_file,
strerror(errno));
               //exit(EXIT_FAILURE);
           }

           close(fd);
       }

       static int              /* Start function for cloned child */
       childFunc(void *arg)
       {
           struct child_args *args =3D (struct child_args *) arg;
           char ch;

           /* Wait until the parent has updated the UID and GID mappings.
              See the comment in main(). We wait for end of file on a
              pipe that will be closed by the parent process once it has
              updated the mappings. */

           close(args->pipe_fd[1]);    /* Close our descriptor for the writ=
e
                                          end of the pipe so that we see EO=
F
                                          when parent closes its descriptor=
 */
           if (read(args->pipe_fd[0], &ch, 1) !=3D 0) {
               fprintf(stderr,
                       "Failure in child: read from pipe returned !=3D 0\n"=
);
               exit(EXIT_FAILURE);
           }

           /* Execute a shell command */

           printf("About to exec %s\n", args->argv[0]);
           execvp(args->argv[0], args->argv);
           errExit("execvp");
       }

       #define STACK_SIZE (1024 * 1024)

       static char child_stack[STACK_SIZE];    /* Space for child's stack *=
/

       int
       main(int argc, char *argv[])
       {
           int flags, opt, map_zero;
           pid_t child_pid;
           struct child_args args;
           char *uid_map, *gid_map;
           const int MAP_BUF_SIZE =3D 100;
           char map_buf[MAP_BUF_SIZE];
           char map_path[PATH_MAX];

           /* Parse command-line options. The initial '+' character in
              the final getopt() argument prevents GNU-style permutation
              of command-line options. That's useful, since sometimes
              the 'command' to be executed by this program itself
              has command-line options. We don't want getopt() to treat
              those as options to this program. */

           flags =3D 0;
           verbose =3D 0;
           gid_map =3D NULL;
           uid_map =3D NULL;
           map_zero =3D 0;
           while ((opt =3D getopt(argc, argv, "+imnpuUM:G:zv")) !=3D -1) {
               switch (opt) {
               case 'i': flags |=3D CLONE_NEWIPC;        break;
               case 'm': flags |=3D CLONE_NEWNS;         break;
               case 'n': flags |=3D CLONE_NEWNET;        break;
               case 'p': flags |=3D CLONE_NEWPID;        break;
               case 'u': flags |=3D CLONE_NEWUTS;        break;
               case 'v': verbose =3D 1;                  break;
               case 'z': map_zero =3D 1;                 break;
               case 'M': uid_map =3D optarg;             break;
               case 'G': gid_map =3D optarg;             break;
               case 'U': flags |=3D CLONE_NEWUSER;       break;
               default:  usage(argv[0]);
               }
           }

           /* -M or -G without -U is nonsensical */

           if (((uid_map !=3D NULL || gid_map !=3D NULL || map_zero) &&
                       !(flags & CLONE_NEWUSER)) ||
                   (map_zero && (uid_map !=3D NULL || gid_map !=3D NULL)))
               usage(argv[0]);

           args.argv =3D &argv[optind];

           /* We use a pipe to synchronize the parent and child, in order t=
o
              ensure that the parent sets the UID and GID maps before the c=
hild
              calls execve(). This ensures that the child maintains its
              capabilities during the execve() in the common case where we
              want to map the child's effective user ID to 0 in the new use=
r
              namespace. Without this synchronization, the child would lose
              its capabilities if it performed an execve() with nonzero
              user IDs (see the capabilities(7) man page for details of the
              transformation of a process's capabilities during execve()). =
*/

           if (pipe(args.pipe_fd) =3D=3D -1)
               errExit("pipe");

           /* Create the child in new namespace(s) */

           child_pid =3D clone(childFunc, child_stack + STACK_SIZE,
                             flags | SIGCHLD, &args);
           if (child_pid =3D=3D -1)
               errExit("clone");

           /* Parent falls through to here */

           if (verbose)
               printf("%s: PID of child created by clone() is %ld\n",
                       argv[0], (long) child_pid);

           /* Update the UID and GID maps in the child */

           if (uid_map !=3D NULL || map_zero) {
               snprintf(map_path, PATH_MAX, "/proc/%ld/uid_map",
                       (long) child_pid);
               if (map_zero) {
                   snprintf(map_buf, MAP_BUF_SIZE, "0 %ld 1", (long) getuid=
());
                   uid_map =3D map_buf;
               }
               update_map(uid_map, map_path);
           }
           if (gid_map !=3D NULL || map_zero) {
               snprintf(map_path, PATH_MAX, "/proc/%ld/gid_map",
                       (long) child_pid);
               if (map_zero) {
                   snprintf(map_buf, MAP_BUF_SIZE, "0 %ld 1", (long) getgid=
());
                   gid_map =3D map_buf;
               }
               update_map(gid_map, map_path);
           }

           /* Close the write end of the pipe, to signal to the child that =
we
              have updated the UID and GID maps */

           close(args.pipe_fd[1]);

           if (waitpid(child_pid, NULL, 0) =3D=3D -1)      /* Wait for chil=
d */
               errExit("waitpid");

           if (verbose)
               printf("%s: terminating\n", argv[0]);

           exit(EXIT_SUCCESS);
       }

SEE ALSO
       newgidmap(1),  newuidmap(1),  clone(2),  setns(2),  unshare(2),
       proc(5), subgid(5), subuid(5), credentials(7), capabilities(7),
       namespaces(7), pid_namespaces(7)

       The  kernel  source file Documentation/namespaces/resource-con=E2=80=
=90
       trol.txt.



Linux                         2013-01-14            USER_NAMESPACES(7)



=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D *roff source =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

.\" Copyright (c) 2013 by Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
.\" and Copyright (c) 2012 by Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
.\"
.\" Permission is granted to make and distribute verbatim copies of this
.\" manual provided the copyright notice and this permission notice are
.\" preserved on all copies.
.\"
.\" Permission is granted to copy and distribute modified versions of this
.\" manual under the conditions for verbatim copying, provided that the
.\" entire resulting derived work is distributed under the terms of a
.\" permission notice identical to this one.
.\"
.\" Since the Linux kernel and libraries are constantly changing, this
.\" manual page may be incorrect or out-of-date.  The author(s) assume no
.\" responsibility for errors or omissions, or for damages resulting from
.\" the use of the information contained herein.  The author(s) may not
.\" have taken the same level of care in the production of this manual,
.\" which is licensed free of charge, as they might when working
.\" professionally.
.\"
.\" Formatted or processed versions of this manual, if unaccompanied by
.\" the source, must acknowledge the copyright and authors of this work.
.\"
.\"
.TH USER_NAMESPACES 7 2013-01-14 "Linux" "Linux Programmer's Manual"
.SH NAME
user_namespaces \- overview of Linux user_namespaces
.SH DESCRIPTION
For an overview of namespaces, see
.BR namespaces (7).

User namespaces isolate security-related identifiers, in particular,
user IDs and group IDs (see
.BR credentials (7),
keys (see
.BR keyctl (2)),
.\" FIXME: This page says very little about the interaction
.\" of user namespaces and keys. Add something on this topic.
and capabilities (see
.BR capabilities (7)).
A process's user and group IDs can be different
inside and outside a user namespace.
In particular,
a process can have a normal unprivileged user ID outside a user namespace
while at the same time having a user ID of 0 inside the namespace;
in other words,
the process has full privileges for operations inside the user namespace,
but is unprivileged for operations outside the namespace.
.\"
.\" =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
.\"
.SS Nested namespaces, namespace membership
User namespaces can be nested;
that is, each user namespace\(emexcept the initial ("root")
namespace\(emhas a parent user namespace,
and can have zero or more child user namespaces.
The parent user namespace is the user namespace
of the process that creates the user namespace via a call to
.BR unshare (2)
or
.BR clone (2)
with the
.BR CLONE_NEWUSER
flag.

Each process is a member of exactly one user namespace.
A process created via
.BR fork (2)
or
.BR clone (2)
without the
.BR CLONE_NEWUSER
flag is a member of the same user namespace as its parent.
A process can join another user namespace with
.BR setns (2)
if it has the
.BR CAP_SYS_ADMIN
in that namespace;
upon doing so, it gains a full set of capabilities in that namespace.

A call to
.BR clone (2)
or
.BR unshare (2)
with the
.BR CLONE_NEWUSER
flag makes the new child process (for
.BR clone (2))
or the caller (for
.BR unshare (2))
a member of the new user namespace created by the call.
.\"
.\" =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
.\"
.SS Capabilities
The child process created by
.BR clone (2)
with the
.BR CLONE_NEWUSER
flag starts out with a complete set
of capabilities in the new user namespace.
Likewise, a process that creates a new user namespace using
.BR unshare (2)
or joins an existing user namespace using
.BR setns (2)
gains a full set of capabilities in that namespace.
On the other hand,
that process has no capabilities in the parent (in the case of
.BR clone (2))
or previous (in the case of
.BR unshare (2)
and
.BR setns (2))
user namespace,
even if the new namespace is created or joined by the root user
(i.e., a process with user ID 0 in the root namespace).
Nevertheless, a process owned by the root user
will be able to access resources such as
files that are owned by user ID 0,
and will be able to do things such as sending signals
to processes belonging to user ID 0.

Note that a call to
.BR execve (2)
will cause a process to lose any capabilities that it has,
unless it has a user ID of 0 within the namespace.
Thus, before calling
.BR execve (2),
a user ID mapping for ID 0 must be defined,
and the caller may also need to use
.BR setuid (2)
or similar to set its user ID to 0.

A call to
.BR clone (2),
.BR unshare (2),
or
.BR setns (2)
using the
.BR CLONE_NEWUSER
flag sets the "securebits" flags
(see
.BR capabilities (7))
to their default values (all flags disabled) in the child (for
.BR clone (2))
or caller (for
.BR unshare (2),
or
.BR setns (2)).
Note that because the caller no longer has capabilities
in its original user namespace after a call to
.BR setns (2),
it is not possible for a process to reset its "securebits" flags while
retaining its user namespace membership by using a pair of
.BR setns (2)
calls to move to another user namespace and then return to
its original user namespace.

Having a capability inside a user namespace
permits a process to perform operations (that require privilege)
only on resources governed by that namespace.
The rules for determining whether or not a process has a capability
in a particular user namespace are as follows:
.IP 1. 3
A process has a capability inside a user namespace
if it is a member of that namespace and
it has the capability in its effective capability set.
A process can gain capabilities in its effective capability
set in various ways.
For example, it may execute a set-user-ID program or an
executable with associated file capabilities.
In addition,
a process may gain capabilities via the effect of
.BR clone (2),
.BR unshare (2),
or
.BR setns (2),
as already described.
.\" In the 3.8 sources, see security/commoncap.c::cap_capable():
.IP 2.
If a process has a capability in a user namespace,
then it has that capability in all child (and further removed descendant)
namespaces as well.
.IP 3.
.\" * The owner of the user namespace in the parent of the
.\" * user namespace has all caps.
When a user namespace is created, the kernel records the effective
user ID of the creating process as being the "owner" of the namespace.
.\" (and likewise associates the effective group ID of the creating process
.\" with the namespace).
A process that resides
in the parent of the user namespace
.\" See kernel commit 520d9eabce18edfef76a60b7b839d54facafe1f9 for a fix
.\" on this point
and whose effective user ID matches the owner of the namespace
has all capabilities in the namespace.
.\"     This includes the case where the process executes a set-user-ID
.\"     program that confers the effective UID of the creator of the namesp=
ace.
By virtue of the previous rule,
this means that the process has all capabilities in all
further removed descendant user namespaces as well.
.\"
.\" =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
.\"
.SS Interaction of user namespaces and other types of namespaces
Starting in Linux 3.8, unprivileged processes can create user namespaces,
and mount, PID, IPC, network, and UTS namespaces can be created with just t=
he
.B CAP_SYS_ADMIN
capability in the caller's user namespace.

If
.BR CLONE_NEWUSER
is specified along with other
.B CLONE_NEW*
flags in a single
.BR clone (2)
or
.BR unshare (2)
call, the user namespace is guaranteed to be created first,
giving the child
.RB ( clone (2))
or caller
.RB ( unshare (2))
privileges over the remaining namespaces created by the call.
Thus, it is possible for an unprivileged caller to specify this combination
of flags.

When a new IPC, mount, network, PID, or UTS namespace is created via
.BR clone (2)
or
.BR unshare (2),
the kernel records the user namespace of the creating process against
the new namespace.
(This association can't be changed.)
When a process in the new namespace subsequently performs
privileged operations that operate on global
resources isolated by the namespace,
the permission checks are performed according to the process's capabilities
in the user namespace that the kernel associated with the new namespace.
.\"
.\" =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
.\"
.SS User and group ID mappings: uid_map and gid_map
When a user namespace is created,
it starts out without a mapping of user IDs (group IDs)
to the parent user namespace.
The
.IR /proc/[pid]/uid_map
and
.IR /proc/[pid]/gid_map
files (available since Linux 3.5)
.\" commit 22d917d80e842829d0ca0a561967d728eb1d6303
expose the mappings for user and group IDs
inside the user namespace for the process
.IR pid .
These files can be read to view the mappings in a user namespace and
written to (once) to define the mappings.

The description in the following paragraphs explains the details for
.IR uid_map ;
.IR gid_map
is exactly the same,
but each instance of "user ID" is replaced by "group ID".

The
.I uid_map
file exposes the mapping of user IDs from the user namespace
of the process
.IR pid
to the user namespace of the process that opened
.IR uid_map
(but see a qualification to this point below).
In other words, processes that are in different user namespaces
will potentially see different values when reading from a particular
.I uid_map
file, depending on the user ID mappings for the user namespaces
of the reading processes.

Each line in the
.I uid_map
file specifies a 1-to-1 mapping of a range of contiguous
user IDs between two user namespaces.
(When a user namespace is first created, this file is empty.)
The specification in each line takes the form of
three numbers delimited by white space.
The first two numbers specify the starting user ID in
each of the two user namespaces.
The third number specifies the length of the mapped range.
In detail, the fields are interpreted as follows:
.IP (1) 4
The start of the range of user IDs in
the user namespace of the process
.IR pid .
.IP (2)
The start of the range of user
IDs to which the user IDs specified by field one map.
How field two is interpreted depends on whether the process that opened
.I uid_map
and the process
.IR pid
are in the same user namespace, as follows:
.RS
.IP a) 3
If the two processes are in different user namespaces:
field two is the start of a range of
user IDs in the user namespace of the process that opened
.IR uid_map .
.IP b)
If the two processes are in the same user namespace:
field two is the start of the range of
user IDs in the parent user namespace of the process
.IR pid .
This case enables the opener of
.I uid_map
(the common case here is opening
.IR /proc/self/uid_map )
to see the mapping of user IDs into the user namespace of the process
that created this user namespace.
.RE
.IP (3)
The length of the range of user IDs that is mapped between the two
user namespaces.
.PP
System calls that return user IDs (group IDs)\(emfor example,
.BR getuid (2),
.BR getgid (2),
and the credential fields in the structure returned by
.BR stat (2)\(emreturn
the user ID (group ID) mapped into the caller's user namespace.

When a process accesses a file, its user and group IDs
are mapped into the initial user namespace for the purpose of permission
checking and assigning IDs when creating a file.
When a process retrieves file user and group IDs via
.BR stat (2),
the IDs are mapped in the opposite direction,
to produce values relative to the process user and group ID mappings.

The initial user namespace has no parent namespace,
but, for consistency, the kernel provides dummy user and group
ID mapping files for this namespace.
Looking at the
.I uid_map
file
.RI ( gid_map
is the same) from a shell in the initial namespace shows:

.in +4n
.nf
$ \fBcat /proc/$$/uid_map\fP
         0          0 4294967295
.fi
.in

This mapping tells us
that the range starting at user ID 0 in this namespace
maps to a range starting at 0 in the (nonexistent) parent namespace,
and the length of the range is the largest 32-bit unsigned integer.
.\"
.\" =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
.\"
.SS Defining user and group ID mappings: writing to uid_map and gid_map
.PP
After the creation of a new user namespace, the
.I uid_map
file of
.I one
of the processes in the namespace may be written to
.I once
to define the mapping of user IDs in the new user namespace.
An attempt to write more than once to a
.I uid_map
file in a user namespace fails with the error
.BR EPERM .
Similar rules apply for
.I gid_map
files.

The lines written to
.IR uid_map
.RI ( gid_map )
must conform to the following rules:
.IP * 3
The three fields must be valid numbers,
and the last field must be greater than 0.
.IP *
Lines are terminated by newline characters.
.IP *
There is an (arbitrary) limit on the number of lines in the file.
As at Linux 3.8, the limit is five lines.
In addition, the number of bytes written to
the file must be less than the system page size,
.\" FIXME(Eric): the restriction "less than" rather than "less than or equa=
l"
.\" seems strangely arbitrary. Furthermore, the comment does not agree
.\" with the code in kernel/user_namespace.c. Which is correct.
and the write must be performed at the start of the file (i.e.,
.BR lseek (2)
and
.BR pwrite (2)
can't be used to write to nonzero offsets in the file).
.IP *
The range of user IDs (group IDs)
specified in each line cannot overlap with the ranges
in any other lines.
In the initial implementation (Linux 3.8), this requirement was
satisfied by a simplistic implementation that imposed the further
requirement that
the values in both field 1 and field 2 of successive lines must be
in ascending numerical order,
which prevented some otherwise valid maps from being created.
Linux 3.9 and later
.\" commit 0bd14b4fd72afd5df41e9fd59f356740f22fceba
fix this limitation, allowing any valid set of nonoverlapping maps.
.IP *
At least one line must be written to the file.
.PP
Writes that violate the above rules fail with the error
.BR EINVAL .

In order for a process to write to the
.I /proc/[pid]/uid_map
.RI ( /proc/[pid]/gid_map )
file, all of the following requirements must be met:
.IP 1. 3
The writing process must have the
.BR CAP_SETUID
.RB ( CAP_SETGID )
capability in the user namespace of the process
.IR pid .
.IP 2.
The writing process must be in either the user namespace of the process
.I pid
or inside the parent user namespace of the process
.IR pid .
.IP 3.
The mapped user IDs (group IDs) must in turn have a mapping
in the parent user namespace.
.IP 4.
One of the following is true:
.RS
.IP * 3
The data written to
.I uid_map
.RI ( gid_map )
consists of a single line that maps the writing process's file system user =
ID
(group ID) in the parent user namespace to a user ID (group ID)
in the user namespace.
The usual case here is that this single line provides a mapping for user ID
of the process that created the namespace.
.IP * 3
The process has the
.BR CAP_SETUID
.RB ( CAP_SETGID )
capability in the parent user namespace.
Thus, a privileged process can make mappings to arbitrary user IDs (group I=
Ds)
in the parent user namespace.
.RE
.PP
Writes that violate the above rules fail with the error
.BR EPERM .
.\"
.\" =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
.\"
.SS Unmapped user and group IDs
.PP
There are various places where an unmapped user ID (group ID)
may be exposed to user space.
For example, the first process in a new user namespace may call
.BR getuid ()
before a user ID mapping has been defined for the namespace.
In most such cases, an unmapped user ID is converted
.\" from_kuid_munged(), from_kgid_munged()
to the overflow user ID (group ID);
the default value for the overflow user ID (group ID) is 65534.
See the descriptions of
.IR /proc/sys/kernel/overflowuid
and
.IR /proc/sys/kernel/overflowgid
in
.BR proc (5).

The cases where unmapped IDs are mapped in this fashion include
system calls that return user IDs
.RB ( getuid (2)
.BR getgid (2),
and similar),
credentials passed over a UNIX domain socket,
.\" also SO_PEERCRED
credentials returned by
.BR stat (2),
.BR waitid (2),
and the System V IPC "ctl"
.B IPC_STAT
operations,
credentials exposed by
.IR /proc/PID/status
and the files in
.IR /proc/sysvipc/* ,
credentials returned via the
.I si_uid
field in the
.I siginfo_t
received with a signal (see
.BR sigaction (2)),
credentials written to the process accounting file (see
.BR acct (5)),
and credentials returned with POSIX message queue notifications (see
.BR mq_notify (3)).

There is one notable case where unmapped user and group IDs are
.I not
.\" from_kuid(), from_kgid()
.\" Also F_GETOWNER_UIDS is an exception
converted to the corresponding overflow ID value.
When viewing a
.I uid_map
or
.I gid_map
file in which there is no mapping for the second field,
that field is displayed as 4294967295 (\-1 as an unsigned integer);
.\"
.\" =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
.\"
.SS Set-user-ID and set-group-ID programs
.PP
When a process inside a user namespace executes
a set-user-ID (set-group-ID) program,
the process's effective user (group) ID inside the namespace is changed
to whatever value is mapped for the user (group) ID of the file.
However, if either the user
.I or
the group ID of the file has no mapping inside the namespace,
the set-user-ID (set-group-ID) bit is silently ignored:
the new program is executed,
but the process's effective user (group) ID is left unchanged.
(This mirrors the semantics of executing a set-user-ID or set-group-ID
program that resides on a file system that was mounted with the
.BR MS_NOSUID
flag, as described in
.BR mount (2).)
.\"
.\" =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
.\"
.SS Miscellaneous
.PP
When a process's user and group IDs are passed over a UNIX domain socket
to a process in a different user namespace (see the description of
.B SCM_CREDENTIALS
in
.BR unix (7)),
they are translated into the corresponding values as per the
receiving process's user and group ID mappings.
.\"
.SH CONFORMING TO
Namespaces are a Linux-specific feature.
.\"
.SH NOTES
Over the years, there have been a lot of features that have been added
to the Linux kernel that have been made available only to privileged users
because of their potential to confuse set-user-ID-root applications.
In general, it becomes safe to allow the root user in a user namespace to
use those features because it is impossible, while in a user namespace,
to gain more privilege than the root user of a user namespace has.
.SS Availability
Use of user namespaces requires a kernel that is configured with the
.B CONFIG_USER_NS
option.
User namespaces require support in a range of subsystems across
the kernel.
When an unsupported subsystem is configured into the kernel,
it is not possible to configure user namespaces support.
As at Linux 3.8, most relevant subsystems support user namespaces,
but there are a number of file systems that do not.
Linux 3.9 added user namespaces support for many of the remaining
unsupported file systems:
Plan 9 (9P), Andrew File System (AFS), Ceph, CIFS, CODA, NFS, and OCFS2.
XFS support for user namespaces is not yet available.
.\"
.SH EXAMPLE
The program below is designed to allow experimenting with
user namespaces, as well as other types of namespaces.
It creates namespaces as specified by command-line options and then execute=
s
a command inside those namespaces.
The comments and
.I usage()
function inside the program provide a full explanation of the program.
The following shell session demonstrates its use.

First, we look at the run-time environment:

.in +4n
.nf
$ \fBuname -rs\fP     # Need Linux 3.8 or later
Linux 3.8.0
$ \fBid -u\fP         # Running as unprivileged user
1000
$ \fBid -g\fP
1000
.fi
.in

Now start a new shell in new user
.RI ( \-U ),
mount
.RI ( \-m ),
and PID
.RI ( \-p )
namespaces, with user ID
.RI ( \-M )
and group ID
.RI ( \-G )
1000 mapped to 0 inside the user namespace:

.in +4n
.nf
$ \fB./userns_child_exec -p -m -U -M '0 1000 1' -G '0 1000 1' bash\fP
.fi
.in

The shell has PID 1, because it is the first process in the new
PID namespace:

.in +4n
.nf
bash$ \fBecho $$\fP
1
.fi
.in

Inside the user namespace, the shell has user and group ID 0,
and a full set of permitted and effective capabilities:

.in +4n
.nf
bash$ \fBcat /proc/$$/status | egrep '^[UG]id'\fP
Uid:	0	0	0	0
Gid:	0	0	0	0
bash$ \fBcat /proc/$$/status | egrep '^Cap(Prm|Inh|Eff)'\fP
CapInh:	0000000000000000
CapPrm:	0000001fffffffff
CapEff:	0000001fffffffff
.fi
.in

Mounting a new
.I /proc
file system and listing all of the processes visible
in the new PID namespace shows that the shell can't see
any processes outside the PID namespace:

.in +4n
.nf
bash$ \fBmount -t proc proc /proc\fP
bash$ \fBps ax\fP
  PID TTY      STAT   TIME COMMAND
    1 pts/3    S      0:00 bash
   22 pts/3    R+     0:00 ps ax
.fi
.in
.SS Program source
\&
.nf
/* userns_child_exec.c

   Licensed under GNU General Public License v2 or later

   Create a child process that executes a shell command in new
   namespace(s); allow UID and GID mappings to be specified when
   creating a user namespace.
*/
#define _GNU_SOURCE
#include <sched.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <signal.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <limits.h>
#include <errno.h>

/* A simple error\-handling function: print an error message based
   on the value in \(aqerrno\(aq and terminate the calling process */

#define errExit(msg)    do { perror(msg); exit(EXIT_FAILURE); \\
                        } while (0)

struct child_args {
    char **argv;        /* Command to be executed by child, with args */
    int    pipe_fd[2];  /* Pipe used to synchronize parent and child */
};

static int verbose;

static void
usage(char *pname)
{
    fprintf(stderr, "Usage: %s [options] cmd [arg...]\\n\\n", pname);
    fprintf(stderr, "Create a child process that executes a shell "
            "command in a new user namespace,\\n"
            "and possibly also other new namespace(s).\\n\\n");
    fprintf(stderr, "Options can be:\\n\\n");
#define fpe(str) fprintf(stderr, "    %s", str);
    fpe("\-i          New IPC namespace\\n");
    fpe("\-m          New mount namespace\\n");
    fpe("\-n          New network namespace\\n");
    fpe("\-p          New PID namespace\\n");
    fpe("\-u          New UTS namespace\\n");
    fpe("\-U          New user namespace\\n");
    fpe("\-M uid_map  Specify UID map for user namespace\\n");
    fpe("\-G gid_map  Specify GID map for user namespace\\n");
    fpe("\-z          Map user\(aqs UID and GID to 0 in user namespace\\n")=
;
    fpe("            (equivalent to: \-M \(aq0 <uid> 1\(aq \-G \(aq0
<gid> 1\(aq)\\n");
    fpe("\-v          Display verbose messages\\n");
    fpe("\\n");
    fpe("If \-z, \-M, or \-G is specified, \-U is required.\\n");
    fpe("It is not permitted to specify both \-z and either \-M or \-G.\\n"=
);
    fpe("\\n");
    fpe("Map strings for \-M and \-G consist of records of the form:\\n");
    fpe("\\n");
    fpe("    ID\-inside\-ns   ID\-outside\-ns   len\\n");
    fpe("\\n");
    fpe("A map string can contain multiple records, separated"
        " by commas;\\n");
    fpe("the commas are replaced by newlines before writing"
        " to map files.\\n");

    exit(EXIT_FAILURE);
}

/* Update the mapping file \(aqmap_file\(aq, with the value provided in
   \(aqmapping\(aq, a string that defines a UID or GID mapping. A UID or
   GID mapping consists of one or more newline\-delimited records
   of the form:

       ID_inside\-ns    ID\-outside\-ns   length

   Requiring the user to supply a string that contains newlines is
   of course inconvenient for command\-line use. Thus, we permit the
   use of commas to delimit records in this string, and replace them
   with newlines before writing the string to the file. */

static void
update_map(char *mapping, char *map_file)
{
    int fd, j;
    size_t map_len;     /* Length of \(aqmapping\(aq */

    /* Replace commas in mapping string with newlines */

    map_len =3D strlen(mapping);
    for (j =3D 0; j < map_len; j++)
        if (mapping[j] =3D=3D \(aq,\(aq)
            mapping[j] =3D \(aq\\n\(aq;

    fd =3D open(map_file, O_RDWR);
    if (fd =3D=3D \-1) {
        fprintf(stderr, "ERROR: open %s: %s\\n", map_file, strerror(errno))=
;
        return;
        //exit(EXIT_FAILURE);
    }

    if (write(fd, mapping, map_len) !=3D map_len) {
        fprintf(stderr, "ERROR: write %s: %s\\n", map_file, strerror(errno)=
);
        //exit(EXIT_FAILURE);
    }

    close(fd);
}

static int              /* Start function for cloned child */
childFunc(void *arg)
{
    struct child_args *args =3D (struct child_args *) arg;
    char ch;

    /* Wait until the parent has updated the UID and GID mappings.
       See the comment in main(). We wait for end of file on a
       pipe that will be closed by the parent process once it has
       updated the mappings. */

    close(args\->pipe_fd[1]);    /* Close our descriptor for the write
                                   end of the pipe so that we see EOF
                                   when parent closes its descriptor */
    if (read(args\->pipe_fd[0], &ch, 1) !=3D 0) {
        fprintf(stderr,
                "Failure in child: read from pipe returned !=3D 0\\n");
        exit(EXIT_FAILURE);
    }

    /* Execute a shell command */

    printf("About to exec %s\\n", args\->argv[0]);
    execvp(args\->argv[0], args\->argv);
    errExit("execvp");
}

#define STACK_SIZE (1024 * 1024)

static char child_stack[STACK_SIZE];    /* Space for child\(aqs stack */

int
main(int argc, char *argv[])
{
    int flags, opt, map_zero;
    pid_t child_pid;
    struct child_args args;
    char *uid_map, *gid_map;
    const int MAP_BUF_SIZE =3D 100;
    char map_buf[MAP_BUF_SIZE];
    char map_path[PATH_MAX];

    /* Parse command\-line options. The initial \(aq+\(aq character in
       the final getopt() argument prevents GNU\-style permutation
       of command\-line options. That\(aqs useful, since sometimes
       the \(aqcommand\(aq to be executed by this program itself
       has command\-line options. We don\(aqt want getopt() to treat
       those as options to this program. */

    flags =3D 0;
    verbose =3D 0;
    gid_map =3D NULL;
    uid_map =3D NULL;
    map_zero =3D 0;
    while ((opt =3D getopt(argc, argv, "+imnpuUM:G:zv")) !=3D \-1) {
        switch (opt) {
        case \(aqi\(aq: flags |=3D CLONE_NEWIPC;        break;
        case \(aqm\(aq: flags |=3D CLONE_NEWNS;         break;
        case \(aqn\(aq: flags |=3D CLONE_NEWNET;        break;
        case \(aqp\(aq: flags |=3D CLONE_NEWPID;        break;
        case \(aqu\(aq: flags |=3D CLONE_NEWUTS;        break;
        case \(aqv\(aq: verbose =3D 1;                  break;
        case \(aqz\(aq: map_zero =3D 1;                 break;
        case \(aqM\(aq: uid_map =3D optarg;             break;
        case \(aqG\(aq: gid_map =3D optarg;             break;
        case \(aqU\(aq: flags |=3D CLONE_NEWUSER;       break;
        default:  usage(argv[0]);
        }
    }

    /* \-M or \-G without \-U is nonsensical */

    if (((uid_map !=3D NULL || gid_map !=3D NULL || map_zero) &&
                !(flags & CLONE_NEWUSER)) ||
            (map_zero && (uid_map !=3D NULL || gid_map !=3D NULL)))
        usage(argv[0]);

    args.argv =3D &argv[optind];

    /* We use a pipe to synchronize the parent and child, in order to
       ensure that the parent sets the UID and GID maps before the child
       calls execve(). This ensures that the child maintains its
       capabilities during the execve() in the common case where we
       want to map the child\(aqs effective user ID to 0 in the new user
       namespace. Without this synchronization, the child would lose
       its capabilities if it performed an execve() with nonzero
       user IDs (see the capabilities(7) man page for details of the
       transformation of a process\(aqs capabilities during execve()). */

    if (pipe(args.pipe_fd) =3D=3D \-1)
        errExit("pipe");

    /* Create the child in new namespace(s) */

    child_pid =3D clone(childFunc, child_stack + STACK_SIZE,
                      flags | SIGCHLD, &args);
    if (child_pid =3D=3D \-1)
        errExit("clone");

    /* Parent falls through to here */

    if (verbose)
        printf("%s: PID of child created by clone() is %ld\\n",
                argv[0], (long) child_pid);

    /* Update the UID and GID maps in the child */

    if (uid_map !=3D NULL || map_zero) {
        snprintf(map_path, PATH_MAX, "/proc/%ld/uid_map",
                (long) child_pid);
        if (map_zero) {
            snprintf(map_buf, MAP_BUF_SIZE, "0 %ld 1", (long) getuid());
            uid_map =3D map_buf;
        }
        update_map(uid_map, map_path);
    }
    if (gid_map !=3D NULL || map_zero) {
        snprintf(map_path, PATH_MAX, "/proc/%ld/gid_map",
                (long) child_pid);
        if (map_zero) {
            snprintf(map_buf, MAP_BUF_SIZE, "0 %ld 1", (long) getgid());
            gid_map =3D map_buf;
        }
        update_map(gid_map, map_path);
    }

    /* Close the write end of the pipe, to signal to the child that we
       have updated the UID and GID maps */

    close(args.pipe_fd[1]);

    if (waitpid(child_pid, NULL, 0) =3D=3D \-1)      /* Wait for child */
        errExit("waitpid");

    if (verbose)
        printf("%s: terminating\\n", argv[0]);

    exit(EXIT_SUCCESS);
}
.fi
.SH SEE ALSO
.BR newgidmap (1),      \" From the shadow package
.BR newuidmap (1),      \" From the shadow package
.BR clone (2),
.BR setns (2),
.BR unshare (2),
.BR proc (5),
.BR subgid (5),         \" From the shadow package
.BR subuid (5),         \" From the shadow package
.BR credentials (7),
.BR capabilities (7),
.BR namespaces (7),
.BR pid_namespaces (7)
.sp
The kernel source file
.IR Documentation/namespaces/resource-control.txt .

--047d7b86e75adc236304d8eeb01f
Content-Type: application/octet-stream; name="user_namespaces.7"
Content-Disposition: attachment; filename="user_namespaces.7"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_heszpkk10

LlwiIENvcHlyaWdodCAoYykgMjAxMyBieSBNaWNoYWVsIEtlcnJpc2sgPG10ay5tYW5wYWdlc0Bn
bWFpbC5jb20+Ci5cIiBhbmQgQ29weXJpZ2h0IChjKSAyMDEyIGJ5IEVyaWMgVy4gQmllZGVybWFu
IDxlYmllZGVybUB4bWlzc2lvbi5jb20+Ci5cIgouXCIgUGVybWlzc2lvbiBpcyBncmFudGVkIHRv
IG1ha2UgYW5kIGRpc3RyaWJ1dGUgdmVyYmF0aW0gY29waWVzIG9mIHRoaXMKLlwiIG1hbnVhbCBw
cm92aWRlZCB0aGUgY29weXJpZ2h0IG5vdGljZSBhbmQgdGhpcyBwZXJtaXNzaW9uIG5vdGljZSBh
cmUKLlwiIHByZXNlcnZlZCBvbiBhbGwgY29waWVzLgouXCIKLlwiIFBlcm1pc3Npb24gaXMgZ3Jh
bnRlZCB0byBjb3B5IGFuZCBkaXN0cmlidXRlIG1vZGlmaWVkIHZlcnNpb25zIG9mIHRoaXMKLlwi
IG1hbnVhbCB1bmRlciB0aGUgY29uZGl0aW9ucyBmb3IgdmVyYmF0aW0gY29weWluZywgcHJvdmlk
ZWQgdGhhdCB0aGUKLlwiIGVudGlyZSByZXN1bHRpbmcgZGVyaXZlZCB3b3JrIGlzIGRpc3RyaWJ1
dGVkIHVuZGVyIHRoZSB0ZXJtcyBvZiBhCi5cIiBwZXJtaXNzaW9uIG5vdGljZSBpZGVudGljYWwg
dG8gdGhpcyBvbmUuCi5cIgouXCIgU2luY2UgdGhlIExpbnV4IGtlcm5lbCBhbmQgbGlicmFyaWVz
IGFyZSBjb25zdGFudGx5IGNoYW5naW5nLCB0aGlzCi5cIiBtYW51YWwgcGFnZSBtYXkgYmUgaW5j
b3JyZWN0IG9yIG91dC1vZi1kYXRlLiAgVGhlIGF1dGhvcihzKSBhc3N1bWUgbm8KLlwiIHJlc3Bv
bnNpYmlsaXR5IGZvciBlcnJvcnMgb3Igb21pc3Npb25zLCBvciBmb3IgZGFtYWdlcyByZXN1bHRp
bmcgZnJvbQouXCIgdGhlIHVzZSBvZiB0aGUgaW5mb3JtYXRpb24gY29udGFpbmVkIGhlcmVpbi4g
IFRoZSBhdXRob3IocykgbWF5IG5vdAouXCIgaGF2ZSB0YWtlbiB0aGUgc2FtZSBsZXZlbCBvZiBj
YXJlIGluIHRoZSBwcm9kdWN0aW9uIG9mIHRoaXMgbWFudWFsLAouXCIgd2hpY2ggaXMgbGljZW5z
ZWQgZnJlZSBvZiBjaGFyZ2UsIGFzIHRoZXkgbWlnaHQgd2hlbiB3b3JraW5nCi5cIiBwcm9mZXNz
aW9uYWxseS4KLlwiCi5cIiBGb3JtYXR0ZWQgb3IgcHJvY2Vzc2VkIHZlcnNpb25zIG9mIHRoaXMg
bWFudWFsLCBpZiB1bmFjY29tcGFuaWVkIGJ5Ci5cIiB0aGUgc291cmNlLCBtdXN0IGFja25vd2xl
ZGdlIHRoZSBjb3B5cmlnaHQgYW5kIGF1dGhvcnMgb2YgdGhpcyB3b3JrLgouXCIKLlwiCi5USCBV
U0VSX05BTUVTUEFDRVMgNyAyMDEzLTAxLTE0ICJMaW51eCIgIkxpbnV4IFByb2dyYW1tZXIncyBN
YW51YWwiCi5TSCBOQU1FCnVzZXJfbmFtZXNwYWNlcyBcLSBvdmVydmlldyBvZiBMaW51eCB1c2Vy
X25hbWVzcGFjZXMKLlNIIERFU0NSSVBUSU9OCkZvciBhbiBvdmVydmlldyBvZiBuYW1lc3BhY2Vz
LCBzZWUKLkJSIG5hbWVzcGFjZXMgKDcpLgoKVXNlciBuYW1lc3BhY2VzIGlzb2xhdGUgc2VjdXJp
dHktcmVsYXRlZCBpZGVudGlmaWVycywgaW4gcGFydGljdWxhciwKdXNlciBJRHMgYW5kIGdyb3Vw
IElEcyAoc2VlCi5CUiBjcmVkZW50aWFscyAoNyksCmtleXMgKHNlZQouQlIga2V5Y3RsICgyKSks
Ci5cIiBGSVhNRTogVGhpcyBwYWdlIHNheXMgdmVyeSBsaXR0bGUgYWJvdXQgdGhlIGludGVyYWN0
aW9uCi5cIiBvZiB1c2VyIG5hbWVzcGFjZXMgYW5kIGtleXMuIEFkZCBzb21ldGhpbmcgb24gdGhp
cyB0b3BpYy4KYW5kIGNhcGFiaWxpdGllcyAoc2VlCi5CUiBjYXBhYmlsaXRpZXMgKDcpKS4KQSBw
cm9jZXNzJ3MgdXNlciBhbmQgZ3JvdXAgSURzIGNhbiBiZSBkaWZmZXJlbnQKaW5zaWRlIGFuZCBv
dXRzaWRlIGEgdXNlciBuYW1lc3BhY2UuCkluIHBhcnRpY3VsYXIsCmEgcHJvY2VzcyBjYW4gaGF2
ZSBhIG5vcm1hbCB1bnByaXZpbGVnZWQgdXNlciBJRCBvdXRzaWRlIGEgdXNlciBuYW1lc3BhY2UK
d2hpbGUgYXQgdGhlIHNhbWUgdGltZSBoYXZpbmcgYSB1c2VyIElEIG9mIDAgaW5zaWRlIHRoZSBu
YW1lc3BhY2U7CmluIG90aGVyIHdvcmRzLAp0aGUgcHJvY2VzcyBoYXMgZnVsbCBwcml2aWxlZ2Vz
IGZvciBvcGVyYXRpb25zIGluc2lkZSB0aGUgdXNlciBuYW1lc3BhY2UsCmJ1dCBpcyB1bnByaXZp
bGVnZWQgZm9yIG9wZXJhdGlvbnMgb3V0c2lkZSB0aGUgbmFtZXNwYWNlLgouXCIKLlwiID09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PQou
XCIKLlNTIE5lc3RlZCBuYW1lc3BhY2VzLCBuYW1lc3BhY2UgbWVtYmVyc2hpcApVc2VyIG5hbWVz
cGFjZXMgY2FuIGJlIG5lc3RlZDsKdGhhdCBpcywgZWFjaCB1c2VyIG5hbWVzcGFjZVwoZW1leGNl
cHQgdGhlIGluaXRpYWwgKCJyb290IikKbmFtZXNwYWNlXChlbWhhcyBhIHBhcmVudCB1c2VyIG5h
bWVzcGFjZSwKYW5kIGNhbiBoYXZlIHplcm8gb3IgbW9yZSBjaGlsZCB1c2VyIG5hbWVzcGFjZXMu
ClRoZSBwYXJlbnQgdXNlciBuYW1lc3BhY2UgaXMgdGhlIHVzZXIgbmFtZXNwYWNlCm9mIHRoZSBw
cm9jZXNzIHRoYXQgY3JlYXRlcyB0aGUgdXNlciBuYW1lc3BhY2UgdmlhIGEgY2FsbCB0bwouQlIg
dW5zaGFyZSAoMikKb3IKLkJSIGNsb25lICgyKQp3aXRoIHRoZQouQlIgQ0xPTkVfTkVXVVNFUgpm
bGFnLgoKRWFjaCBwcm9jZXNzIGlzIGEgbWVtYmVyIG9mIGV4YWN0bHkgb25lIHVzZXIgbmFtZXNw
YWNlLgpBIHByb2Nlc3MgY3JlYXRlZCB2aWEKLkJSIGZvcmsgKDIpCm9yCi5CUiBjbG9uZSAoMikK
d2l0aG91dCB0aGUKLkJSIENMT05FX05FV1VTRVIKZmxhZyBpcyBhIG1lbWJlciBvZiB0aGUgc2Ft
ZSB1c2VyIG5hbWVzcGFjZSBhcyBpdHMgcGFyZW50LgpBIHByb2Nlc3MgY2FuIGpvaW4gYW5vdGhl
ciB1c2VyIG5hbWVzcGFjZSB3aXRoCi5CUiBzZXRucyAoMikKaWYgaXQgaGFzIHRoZQouQlIgQ0FQ
X1NZU19BRE1JTgppbiB0aGF0IG5hbWVzcGFjZTsKdXBvbiBkb2luZyBzbywgaXQgZ2FpbnMgYSBm
dWxsIHNldCBvZiBjYXBhYmlsaXRpZXMgaW4gdGhhdCBuYW1lc3BhY2UuCgpBIGNhbGwgdG8KLkJS
IGNsb25lICgyKQpvcgouQlIgdW5zaGFyZSAoMikKd2l0aCB0aGUKLkJSIENMT05FX05FV1VTRVIK
ZmxhZyBtYWtlcyB0aGUgbmV3IGNoaWxkIHByb2Nlc3MgKGZvcgouQlIgY2xvbmUgKDIpKQpvciB0
aGUgY2FsbGVyIChmb3IKLkJSIHVuc2hhcmUgKDIpKQphIG1lbWJlciBvZiB0aGUgbmV3IHVzZXIg
bmFtZXNwYWNlIGNyZWF0ZWQgYnkgdGhlIGNhbGwuCi5cIgouXCIgPT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09Ci5cIgouU1MgQ2FwYWJp
bGl0aWVzClRoZSBjaGlsZCBwcm9jZXNzIGNyZWF0ZWQgYnkKLkJSIGNsb25lICgyKQp3aXRoIHRo
ZQouQlIgQ0xPTkVfTkVXVVNFUgpmbGFnIHN0YXJ0cyBvdXQgd2l0aCBhIGNvbXBsZXRlIHNldApv
ZiBjYXBhYmlsaXRpZXMgaW4gdGhlIG5ldyB1c2VyIG5hbWVzcGFjZS4KTGlrZXdpc2UsIGEgcHJv
Y2VzcyB0aGF0IGNyZWF0ZXMgYSBuZXcgdXNlciBuYW1lc3BhY2UgdXNpbmcKLkJSIHVuc2hhcmUg
KDIpCm9yIGpvaW5zIGFuIGV4aXN0aW5nIHVzZXIgbmFtZXNwYWNlIHVzaW5nCi5CUiBzZXRucyAo
MikKZ2FpbnMgYSBmdWxsIHNldCBvZiBjYXBhYmlsaXRpZXMgaW4gdGhhdCBuYW1lc3BhY2UuCk9u
IHRoZSBvdGhlciBoYW5kLAp0aGF0IHByb2Nlc3MgaGFzIG5vIGNhcGFiaWxpdGllcyBpbiB0aGUg
cGFyZW50IChpbiB0aGUgY2FzZSBvZgouQlIgY2xvbmUgKDIpKQpvciBwcmV2aW91cyAoaW4gdGhl
IGNhc2Ugb2YKLkJSIHVuc2hhcmUgKDIpCmFuZAouQlIgc2V0bnMgKDIpKQp1c2VyIG5hbWVzcGFj
ZSwKZXZlbiBpZiB0aGUgbmV3IG5hbWVzcGFjZSBpcyBjcmVhdGVkIG9yIGpvaW5lZCBieSB0aGUg
cm9vdCB1c2VyCihpLmUuLCBhIHByb2Nlc3Mgd2l0aCB1c2VyIElEIDAgaW4gdGhlIHJvb3QgbmFt
ZXNwYWNlKS4KTmV2ZXJ0aGVsZXNzLCBhIHByb2Nlc3Mgb3duZWQgYnkgdGhlIHJvb3QgdXNlcgp3
aWxsIGJlIGFibGUgdG8gYWNjZXNzIHJlc291cmNlcyBzdWNoIGFzCmZpbGVzIHRoYXQgYXJlIG93
bmVkIGJ5IHVzZXIgSUQgMCwKYW5kIHdpbGwgYmUgYWJsZSB0byBkbyB0aGluZ3Mgc3VjaCBhcyBz
ZW5kaW5nIHNpZ25hbHMKdG8gcHJvY2Vzc2VzIGJlbG9uZ2luZyB0byB1c2VyIElEIDAuCgpOb3Rl
IHRoYXQgYSBjYWxsIHRvCi5CUiBleGVjdmUgKDIpCndpbGwgY2F1c2UgYSBwcm9jZXNzIHRvIGxv
c2UgYW55IGNhcGFiaWxpdGllcyB0aGF0IGl0IGhhcywKdW5sZXNzIGl0IGhhcyBhIHVzZXIgSUQg
b2YgMCB3aXRoaW4gdGhlIG5hbWVzcGFjZS4KVGh1cywgYmVmb3JlIGNhbGxpbmcKLkJSIGV4ZWN2
ZSAoMiksCmEgdXNlciBJRCBtYXBwaW5nIGZvciBJRCAwIG11c3QgYmUgZGVmaW5lZCwKYW5kIHRo
ZSBjYWxsZXIgbWF5IGFsc28gbmVlZCB0byB1c2UKLkJSIHNldHVpZCAoMikKb3Igc2ltaWxhciB0
byBzZXQgaXRzIHVzZXIgSUQgdG8gMC4KCkEgY2FsbCB0byAKLkJSIGNsb25lICgyKSwKLkJSIHVu
c2hhcmUgKDIpLApvcgouQlIgc2V0bnMgKDIpCnVzaW5nIHRoZQouQlIgQ0xPTkVfTkVXVVNFUgpm
bGFnIHNldHMgdGhlICJzZWN1cmViaXRzIiBmbGFncwooc2VlCi5CUiBjYXBhYmlsaXRpZXMgKDcp
KQp0byB0aGVpciBkZWZhdWx0IHZhbHVlcyAoYWxsIGZsYWdzIGRpc2FibGVkKSBpbiB0aGUgY2hp
bGQgKGZvcgouQlIgY2xvbmUgKDIpKQpvciBjYWxsZXIgKGZvcgouQlIgdW5zaGFyZSAoMiksCm9y
Ci5CUiBzZXRucyAoMikpLgpOb3RlIHRoYXQgYmVjYXVzZSB0aGUgY2FsbGVyIG5vIGxvbmdlciBo
YXMgY2FwYWJpbGl0aWVzCmluIGl0cyBvcmlnaW5hbCB1c2VyIG5hbWVzcGFjZSBhZnRlciBhIGNh
bGwgdG8KLkJSIHNldG5zICgyKSwKaXQgaXMgbm90IHBvc3NpYmxlIGZvciBhIHByb2Nlc3MgdG8g
cmVzZXQgaXRzICJzZWN1cmViaXRzIiBmbGFncyB3aGlsZQpyZXRhaW5pbmcgaXRzIHVzZXIgbmFt
ZXNwYWNlIG1lbWJlcnNoaXAgYnkgdXNpbmcgYSBwYWlyIG9mCi5CUiBzZXRucyAoMikKY2FsbHMg
dG8gbW92ZSB0byBhbm90aGVyIHVzZXIgbmFtZXNwYWNlIGFuZCB0aGVuIHJldHVybiB0bwppdHMg
b3JpZ2luYWwgdXNlciBuYW1lc3BhY2UuCgpIYXZpbmcgYSBjYXBhYmlsaXR5IGluc2lkZSBhIHVz
ZXIgbmFtZXNwYWNlCnBlcm1pdHMgYSBwcm9jZXNzIHRvIHBlcmZvcm0gb3BlcmF0aW9ucyAodGhh
dCByZXF1aXJlIHByaXZpbGVnZSkKb25seSBvbiByZXNvdXJjZXMgZ292ZXJuZWQgYnkgdGhhdCBu
YW1lc3BhY2UuClRoZSBydWxlcyBmb3IgZGV0ZXJtaW5pbmcgd2hldGhlciBvciBub3QgYSBwcm9j
ZXNzIGhhcyBhIGNhcGFiaWxpdHkKaW4gYSBwYXJ0aWN1bGFyIHVzZXIgbmFtZXNwYWNlIGFyZSBh
cyBmb2xsb3dzOgouSVAgMS4gMwpBIHByb2Nlc3MgaGFzIGEgY2FwYWJpbGl0eSBpbnNpZGUgYSB1
c2VyIG5hbWVzcGFjZQppZiBpdCBpcyBhIG1lbWJlciBvZiB0aGF0IG5hbWVzcGFjZSBhbmQKaXQg
aGFzIHRoZSBjYXBhYmlsaXR5IGluIGl0cyBlZmZlY3RpdmUgY2FwYWJpbGl0eSBzZXQuCkEgcHJv
Y2VzcyBjYW4gZ2FpbiBjYXBhYmlsaXRpZXMgaW4gaXRzIGVmZmVjdGl2ZSBjYXBhYmlsaXR5CnNl
dCBpbiB2YXJpb3VzIHdheXMuCkZvciBleGFtcGxlLCBpdCBtYXkgZXhlY3V0ZSBhIHNldC11c2Vy
LUlEIHByb2dyYW0gb3IgYW4KZXhlY3V0YWJsZSB3aXRoIGFzc29jaWF0ZWQgZmlsZSBjYXBhYmls
aXRpZXMuCkluIGFkZGl0aW9uLAphIHByb2Nlc3MgbWF5IGdhaW4gY2FwYWJpbGl0aWVzIHZpYSB0
aGUgZWZmZWN0IG9mCi5CUiBjbG9uZSAoMiksCi5CUiB1bnNoYXJlICgyKSwKb3IKLkJSIHNldG5z
ICgyKSwKYXMgYWxyZWFkeSBkZXNjcmliZWQuCi5cIiBJbiB0aGUgMy44IHNvdXJjZXMsIHNlZSBz
ZWN1cml0eS9jb21tb25jYXAuYzo6Y2FwX2NhcGFibGUoKToKLklQIDIuCklmIGEgcHJvY2VzcyBo
YXMgYSBjYXBhYmlsaXR5IGluIGEgdXNlciBuYW1lc3BhY2UsCnRoZW4gaXQgaGFzIHRoYXQgY2Fw
YWJpbGl0eSBpbiBhbGwgY2hpbGQgKGFuZCBmdXJ0aGVyIHJlbW92ZWQgZGVzY2VuZGFudCkKbmFt
ZXNwYWNlcyBhcyB3ZWxsLgouSVAgMy4KLlwiICogVGhlIG93bmVyIG9mIHRoZSB1c2VyIG5hbWVz
cGFjZSBpbiB0aGUgcGFyZW50IG9mIHRoZQouXCIgKiB1c2VyIG5hbWVzcGFjZSBoYXMgYWxsIGNh
cHMuCldoZW4gYSB1c2VyIG5hbWVzcGFjZSBpcyBjcmVhdGVkLCB0aGUga2VybmVsIHJlY29yZHMg
dGhlIGVmZmVjdGl2ZQp1c2VyIElEIG9mIHRoZSBjcmVhdGluZyBwcm9jZXNzIGFzIGJlaW5nIHRo
ZSAib3duZXIiIG9mIHRoZSBuYW1lc3BhY2UuCi5cIiAoYW5kIGxpa2V3aXNlIGFzc29jaWF0ZXMg
dGhlIGVmZmVjdGl2ZSBncm91cCBJRCBvZiB0aGUgY3JlYXRpbmcgcHJvY2VzcwouXCIgd2l0aCB0
aGUgbmFtZXNwYWNlKS4KQSBwcm9jZXNzIHRoYXQgcmVzaWRlcwppbiB0aGUgcGFyZW50IG9mIHRo
ZSB1c2VyIG5hbWVzcGFjZQouXCIgU2VlIGtlcm5lbCBjb21taXQgNTIwZDllYWJjZTE4ZWRmZWY3
NmE2MGI3YjgzOWQ1NGZhY2FmZTFmOSBmb3IgYSBmaXgKLlwiIG9uIHRoaXMgcG9pbnQKYW5kIHdo
b3NlIGVmZmVjdGl2ZSB1c2VyIElEIG1hdGNoZXMgdGhlIG93bmVyIG9mIHRoZSBuYW1lc3BhY2UK
aGFzIGFsbCBjYXBhYmlsaXRpZXMgaW4gdGhlIG5hbWVzcGFjZS4KLlwiICAgICBUaGlzIGluY2x1
ZGVzIHRoZSBjYXNlIHdoZXJlIHRoZSBwcm9jZXNzIGV4ZWN1dGVzIGEgc2V0LXVzZXItSUQKLlwi
ICAgICBwcm9ncmFtIHRoYXQgY29uZmVycyB0aGUgZWZmZWN0aXZlIFVJRCBvZiB0aGUgY3JlYXRv
ciBvZiB0aGUgbmFtZXNwYWNlLgpCeSB2aXJ0dWUgb2YgdGhlIHByZXZpb3VzIHJ1bGUsCnRoaXMg
bWVhbnMgdGhhdCB0aGUgcHJvY2VzcyBoYXMgYWxsIGNhcGFiaWxpdGllcyBpbiBhbGwKZnVydGhl
ciByZW1vdmVkIGRlc2NlbmRhbnQgdXNlciBuYW1lc3BhY2VzIGFzIHdlbGwuCi5cIgouXCIgPT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
Ci5cIgouU1MgSW50ZXJhY3Rpb24gb2YgdXNlciBuYW1lc3BhY2VzIGFuZCBvdGhlciB0eXBlcyBv
ZiBuYW1lc3BhY2VzClN0YXJ0aW5nIGluIExpbnV4IDMuOCwgdW5wcml2aWxlZ2VkIHByb2Nlc3Nl
cyBjYW4gY3JlYXRlIHVzZXIgbmFtZXNwYWNlcywKYW5kIG1vdW50LCBQSUQsIElQQywgbmV0d29y
aywgYW5kIFVUUyBuYW1lc3BhY2VzIGNhbiBiZSBjcmVhdGVkIHdpdGgganVzdCB0aGUKLkIgQ0FQ
X1NZU19BRE1JTgpjYXBhYmlsaXR5IGluIHRoZSBjYWxsZXIncyB1c2VyIG5hbWVzcGFjZS4KCklm
Ci5CUiBDTE9ORV9ORVdVU0VSCmlzIHNwZWNpZmllZCBhbG9uZyB3aXRoIG90aGVyCi5CIENMT05F
X05FVyoKZmxhZ3MgaW4gYSBzaW5nbGUKLkJSIGNsb25lICgyKQpvcgouQlIgdW5zaGFyZSAoMikK
Y2FsbCwgdGhlIHVzZXIgbmFtZXNwYWNlIGlzIGd1YXJhbnRlZWQgdG8gYmUgY3JlYXRlZCBmaXJz
dCwKZ2l2aW5nIHRoZSBjaGlsZAouUkIgKCBjbG9uZSAoMikpCm9yIGNhbGxlcgouUkIgKCB1bnNo
YXJlICgyKSkKcHJpdmlsZWdlcyBvdmVyIHRoZSByZW1haW5pbmcgbmFtZXNwYWNlcyBjcmVhdGVk
IGJ5IHRoZSBjYWxsLgpUaHVzLCBpdCBpcyBwb3NzaWJsZSBmb3IgYW4gdW5wcml2aWxlZ2VkIGNh
bGxlciB0byBzcGVjaWZ5IHRoaXMgY29tYmluYXRpb24Kb2YgZmxhZ3MuCgpXaGVuIGEgbmV3IElQ
QywgbW91bnQsIG5ldHdvcmssIFBJRCwgb3IgVVRTIG5hbWVzcGFjZSBpcyBjcmVhdGVkIHZpYQou
QlIgY2xvbmUgKDIpCm9yCi5CUiB1bnNoYXJlICgyKSwKdGhlIGtlcm5lbCByZWNvcmRzIHRoZSB1
c2VyIG5hbWVzcGFjZSBvZiB0aGUgY3JlYXRpbmcgcHJvY2VzcyBhZ2FpbnN0CnRoZSBuZXcgbmFt
ZXNwYWNlLgooVGhpcyBhc3NvY2lhdGlvbiBjYW4ndCBiZSBjaGFuZ2VkLikKV2hlbiBhIHByb2Nl
c3MgaW4gdGhlIG5ldyBuYW1lc3BhY2Ugc3Vic2VxdWVudGx5IHBlcmZvcm1zCnByaXZpbGVnZWQg
b3BlcmF0aW9ucyB0aGF0IG9wZXJhdGUgb24gZ2xvYmFsCnJlc291cmNlcyBpc29sYXRlZCBieSB0
aGUgbmFtZXNwYWNlLAp0aGUgcGVybWlzc2lvbiBjaGVja3MgYXJlIHBlcmZvcm1lZCBhY2NvcmRp
bmcgdG8gdGhlIHByb2Nlc3MncyBjYXBhYmlsaXRpZXMKaW4gdGhlIHVzZXIgbmFtZXNwYWNlIHRo
YXQgdGhlIGtlcm5lbCBhc3NvY2lhdGVkIHdpdGggdGhlIG5ldyBuYW1lc3BhY2UuCi5cIgouXCIg
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09Ci5cIgouU1MgVXNlciBhbmQgZ3JvdXAgSUQgbWFwcGluZ3M6IHVpZF9tYXAgYW5kIGdpZF9t
YXAKV2hlbiBhIHVzZXIgbmFtZXNwYWNlIGlzIGNyZWF0ZWQsCml0IHN0YXJ0cyBvdXQgd2l0aG91
dCBhIG1hcHBpbmcgb2YgdXNlciBJRHMgKGdyb3VwIElEcykKdG8gdGhlIHBhcmVudCB1c2VyIG5h
bWVzcGFjZS4KVGhlCi5JUiAvcHJvYy9bcGlkXS91aWRfbWFwCmFuZAouSVIgL3Byb2MvW3BpZF0v
Z2lkX21hcApmaWxlcyAoYXZhaWxhYmxlIHNpbmNlIExpbnV4IDMuNSkKLlwiIGNvbW1pdCAyMmQ5
MTdkODBlODQyODI5ZDBjYTBhNTYxOTY3ZDcyOGViMWQ2MzAzCmV4cG9zZSB0aGUgbWFwcGluZ3Mg
Zm9yIHVzZXIgYW5kIGdyb3VwIElEcwppbnNpZGUgdGhlIHVzZXIgbmFtZXNwYWNlIGZvciB0aGUg
cHJvY2VzcwouSVIgcGlkIC4KVGhlc2UgZmlsZXMgY2FuIGJlIHJlYWQgdG8gdmlldyB0aGUgbWFw
cGluZ3MgaW4gYSB1c2VyIG5hbWVzcGFjZSBhbmQKd3JpdHRlbiB0byAob25jZSkgdG8gZGVmaW5l
IHRoZSBtYXBwaW5ncy4KClRoZSBkZXNjcmlwdGlvbiBpbiB0aGUgZm9sbG93aW5nIHBhcmFncmFw
aHMgZXhwbGFpbnMgdGhlIGRldGFpbHMgZm9yCi5JUiB1aWRfbWFwIDsKLklSIGdpZF9tYXAKaXMg
ZXhhY3RseSB0aGUgc2FtZSwKYnV0IGVhY2ggaW5zdGFuY2Ugb2YgInVzZXIgSUQiIGlzIHJlcGxh
Y2VkIGJ5ICJncm91cCBJRCIuCgpUaGUKLkkgdWlkX21hcApmaWxlIGV4cG9zZXMgdGhlIG1hcHBp
bmcgb2YgdXNlciBJRHMgZnJvbSB0aGUgdXNlciBuYW1lc3BhY2UKb2YgdGhlIHByb2Nlc3MKLklS
IHBpZAp0byB0aGUgdXNlciBuYW1lc3BhY2Ugb2YgdGhlIHByb2Nlc3MgdGhhdCBvcGVuZWQKLklS
IHVpZF9tYXAKKGJ1dCBzZWUgYSBxdWFsaWZpY2F0aW9uIHRvIHRoaXMgcG9pbnQgYmVsb3cpLgpJ
biBvdGhlciB3b3JkcywgcHJvY2Vzc2VzIHRoYXQgYXJlIGluIGRpZmZlcmVudCB1c2VyIG5hbWVz
cGFjZXMKd2lsbCBwb3RlbnRpYWxseSBzZWUgZGlmZmVyZW50IHZhbHVlcyB3aGVuIHJlYWRpbmcg
ZnJvbSBhIHBhcnRpY3VsYXIKLkkgdWlkX21hcApmaWxlLCBkZXBlbmRpbmcgb24gdGhlIHVzZXIg
SUQgbWFwcGluZ3MgZm9yIHRoZSB1c2VyIG5hbWVzcGFjZXMKb2YgdGhlIHJlYWRpbmcgcHJvY2Vz
c2VzLgoKRWFjaCBsaW5lIGluIHRoZQouSSB1aWRfbWFwCmZpbGUgc3BlY2lmaWVzIGEgMS10by0x
IG1hcHBpbmcgb2YgYSByYW5nZSBvZiBjb250aWd1b3VzCnVzZXIgSURzIGJldHdlZW4gdHdvIHVz
ZXIgbmFtZXNwYWNlcy4KKFdoZW4gYSB1c2VyIG5hbWVzcGFjZSBpcyBmaXJzdCBjcmVhdGVkLCB0
aGlzIGZpbGUgaXMgZW1wdHkuKQpUaGUgc3BlY2lmaWNhdGlvbiBpbiBlYWNoIGxpbmUgdGFrZXMg
dGhlIGZvcm0gb2YKdGhyZWUgbnVtYmVycyBkZWxpbWl0ZWQgYnkgd2hpdGUgc3BhY2UuClRoZSBm
aXJzdCB0d28gbnVtYmVycyBzcGVjaWZ5IHRoZSBzdGFydGluZyB1c2VyIElEIGluCmVhY2ggb2Yg
dGhlIHR3byB1c2VyIG5hbWVzcGFjZXMuClRoZSB0aGlyZCBudW1iZXIgc3BlY2lmaWVzIHRoZSBs
ZW5ndGggb2YgdGhlIG1hcHBlZCByYW5nZS4KSW4gZGV0YWlsLCB0aGUgZmllbGRzIGFyZSBpbnRl
cnByZXRlZCBhcyBmb2xsb3dzOgouSVAgKDEpIDQKVGhlIHN0YXJ0IG9mIHRoZSByYW5nZSBvZiB1
c2VyIElEcyBpbgp0aGUgdXNlciBuYW1lc3BhY2Ugb2YgdGhlIHByb2Nlc3MKLklSIHBpZCAuCi5J
UCAoMikKVGhlIHN0YXJ0IG9mIHRoZSByYW5nZSBvZiB1c2VyCklEcyB0byB3aGljaCB0aGUgdXNl
ciBJRHMgc3BlY2lmaWVkIGJ5IGZpZWxkIG9uZSBtYXAuCkhvdyBmaWVsZCB0d28gaXMgaW50ZXJw
cmV0ZWQgZGVwZW5kcyBvbiB3aGV0aGVyIHRoZSBwcm9jZXNzIHRoYXQgb3BlbmVkCi5JIHVpZF9t
YXAKYW5kIHRoZSBwcm9jZXNzCi5JUiBwaWQKYXJlIGluIHRoZSBzYW1lIHVzZXIgbmFtZXNwYWNl
LCBhcyBmb2xsb3dzOgouUlMKLklQIGEpIDMKSWYgdGhlIHR3byBwcm9jZXNzZXMgYXJlIGluIGRp
ZmZlcmVudCB1c2VyIG5hbWVzcGFjZXM6CmZpZWxkIHR3byBpcyB0aGUgc3RhcnQgb2YgYSByYW5n
ZSBvZgp1c2VyIElEcyBpbiB0aGUgdXNlciBuYW1lc3BhY2Ugb2YgdGhlIHByb2Nlc3MgdGhhdCBv
cGVuZWQKLklSIHVpZF9tYXAgLgouSVAgYikKSWYgdGhlIHR3byBwcm9jZXNzZXMgYXJlIGluIHRo
ZSBzYW1lIHVzZXIgbmFtZXNwYWNlOgpmaWVsZCB0d28gaXMgdGhlIHN0YXJ0IG9mIHRoZSByYW5n
ZSBvZgp1c2VyIElEcyBpbiB0aGUgcGFyZW50IHVzZXIgbmFtZXNwYWNlIG9mIHRoZSBwcm9jZXNz
Ci5JUiBwaWQgLgpUaGlzIGNhc2UgZW5hYmxlcyB0aGUgb3BlbmVyIG9mCi5JIHVpZF9tYXAKKHRo
ZSBjb21tb24gY2FzZSBoZXJlIGlzIG9wZW5pbmcKLklSIC9wcm9jL3NlbGYvdWlkX21hcCApCnRv
IHNlZSB0aGUgbWFwcGluZyBvZiB1c2VyIElEcyBpbnRvIHRoZSB1c2VyIG5hbWVzcGFjZSBvZiB0
aGUgcHJvY2Vzcwp0aGF0IGNyZWF0ZWQgdGhpcyB1c2VyIG5hbWVzcGFjZS4KLlJFCi5JUCAoMykK
VGhlIGxlbmd0aCBvZiB0aGUgcmFuZ2Ugb2YgdXNlciBJRHMgdGhhdCBpcyBtYXBwZWQgYmV0d2Vl
biB0aGUgdHdvCnVzZXIgbmFtZXNwYWNlcy4KLlBQClN5c3RlbSBjYWxscyB0aGF0IHJldHVybiB1
c2VyIElEcyAoZ3JvdXAgSURzKVwoZW1mb3IgZXhhbXBsZSwKLkJSIGdldHVpZCAoMiksCi5CUiBn
ZXRnaWQgKDIpLAphbmQgdGhlIGNyZWRlbnRpYWwgZmllbGRzIGluIHRoZSBzdHJ1Y3R1cmUgcmV0
dXJuZWQgYnkKLkJSIHN0YXQgKDIpXChlbXJldHVybgp0aGUgdXNlciBJRCAoZ3JvdXAgSUQpIG1h
cHBlZCBpbnRvIHRoZSBjYWxsZXIncyB1c2VyIG5hbWVzcGFjZS4KCldoZW4gYSBwcm9jZXNzIGFj
Y2Vzc2VzIGEgZmlsZSwgaXRzIHVzZXIgYW5kIGdyb3VwIElEcwphcmUgbWFwcGVkIGludG8gdGhl
IGluaXRpYWwgdXNlciBuYW1lc3BhY2UgZm9yIHRoZSBwdXJwb3NlIG9mIHBlcm1pc3Npb24KY2hl
Y2tpbmcgYW5kIGFzc2lnbmluZyBJRHMgd2hlbiBjcmVhdGluZyBhIGZpbGUuCldoZW4gYSBwcm9j
ZXNzIHJldHJpZXZlcyBmaWxlIHVzZXIgYW5kIGdyb3VwIElEcyB2aWEKLkJSIHN0YXQgKDIpLAp0
aGUgSURzIGFyZSBtYXBwZWQgaW4gdGhlIG9wcG9zaXRlIGRpcmVjdGlvbiwKdG8gcHJvZHVjZSB2
YWx1ZXMgcmVsYXRpdmUgdG8gdGhlIHByb2Nlc3MgdXNlciBhbmQgZ3JvdXAgSUQgbWFwcGluZ3Mu
CgpUaGUgaW5pdGlhbCB1c2VyIG5hbWVzcGFjZSBoYXMgbm8gcGFyZW50IG5hbWVzcGFjZSwKYnV0
LCBmb3IgY29uc2lzdGVuY3ksIHRoZSBrZXJuZWwgcHJvdmlkZXMgZHVtbXkgdXNlciBhbmQgZ3Jv
dXAKSUQgbWFwcGluZyBmaWxlcyBmb3IgdGhpcyBuYW1lc3BhY2UuCkxvb2tpbmcgYXQgdGhlCi5J
IHVpZF9tYXAKZmlsZQouUkkgKCBnaWRfbWFwCmlzIHRoZSBzYW1lKSBmcm9tIGEgc2hlbGwgaW4g
dGhlIGluaXRpYWwgbmFtZXNwYWNlIHNob3dzOgoKLmluICs0bgoubmYKJCBcZkJjYXQgL3Byb2Mv
JCQvdWlkX21hcFxmUAogICAgICAgICAwICAgICAgICAgIDAgNDI5NDk2NzI5NQouZmkKLmluCgpU
aGlzIG1hcHBpbmcgdGVsbHMgdXMKdGhhdCB0aGUgcmFuZ2Ugc3RhcnRpbmcgYXQgdXNlciBJRCAw
IGluIHRoaXMgbmFtZXNwYWNlCm1hcHMgdG8gYSByYW5nZSBzdGFydGluZyBhdCAwIGluIHRoZSAo
bm9uZXhpc3RlbnQpIHBhcmVudCBuYW1lc3BhY2UsCmFuZCB0aGUgbGVuZ3RoIG9mIHRoZSByYW5n
ZSBpcyB0aGUgbGFyZ2VzdCAzMi1iaXQgdW5zaWduZWQgaW50ZWdlci4KLlwiCi5cIiA9PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0KLlwi
Ci5TUyBEZWZpbmluZyB1c2VyIGFuZCBncm91cCBJRCBtYXBwaW5nczogd3JpdGluZyB0byB1aWRf
bWFwIGFuZCBnaWRfbWFwCi5QUApBZnRlciB0aGUgY3JlYXRpb24gb2YgYSBuZXcgdXNlciBuYW1l
c3BhY2UsIHRoZQouSSB1aWRfbWFwCmZpbGUgb2YKLkkgb25lCm9mIHRoZSBwcm9jZXNzZXMgaW4g
dGhlIG5hbWVzcGFjZSBtYXkgYmUgd3JpdHRlbiB0bwouSSBvbmNlCnRvIGRlZmluZSB0aGUgbWFw
cGluZyBvZiB1c2VyIElEcyBpbiB0aGUgbmV3IHVzZXIgbmFtZXNwYWNlLgpBbiBhdHRlbXB0IHRv
IHdyaXRlIG1vcmUgdGhhbiBvbmNlIHRvIGEKLkkgdWlkX21hcApmaWxlIGluIGEgdXNlciBuYW1l
c3BhY2UgZmFpbHMgd2l0aCB0aGUgZXJyb3IKLkJSIEVQRVJNIC4KU2ltaWxhciBydWxlcyBhcHBs
eSBmb3IKLkkgZ2lkX21hcApmaWxlcy4KClRoZSBsaW5lcyB3cml0dGVuIHRvCi5JUiB1aWRfbWFw
Ci5SSSAoIGdpZF9tYXAgKQptdXN0IGNvbmZvcm0gdG8gdGhlIGZvbGxvd2luZyBydWxlczoKLklQ
ICogMwpUaGUgdGhyZWUgZmllbGRzIG11c3QgYmUgdmFsaWQgbnVtYmVycywKYW5kIHRoZSBsYXN0
IGZpZWxkIG11c3QgYmUgZ3JlYXRlciB0aGFuIDAuCi5JUCAqCkxpbmVzIGFyZSB0ZXJtaW5hdGVk
IGJ5IG5ld2xpbmUgY2hhcmFjdGVycy4KLklQICoKVGhlcmUgaXMgYW4gKGFyYml0cmFyeSkgbGlt
aXQgb24gdGhlIG51bWJlciBvZiBsaW5lcyBpbiB0aGUgZmlsZS4KQXMgYXQgTGludXggMy44LCB0
aGUgbGltaXQgaXMgZml2ZSBsaW5lcy4KSW4gYWRkaXRpb24sIHRoZSBudW1iZXIgb2YgYnl0ZXMg
d3JpdHRlbiB0bwp0aGUgZmlsZSBtdXN0IGJlIGxlc3MgdGhhbiB0aGUgc3lzdGVtIHBhZ2Ugc2l6
ZSwKLlwiIEZJWE1FKEVyaWMpOiB0aGUgcmVzdHJpY3Rpb24gImxlc3MgdGhhbiIgcmF0aGVyIHRo
YW4gImxlc3MgdGhhbiBvciBlcXVhbCIKLlwiIHNlZW1zIHN0cmFuZ2VseSBhcmJpdHJhcnkuIEZ1
cnRoZXJtb3JlLCB0aGUgY29tbWVudCBkb2VzIG5vdCBhZ3JlZQouXCIgd2l0aCB0aGUgY29kZSBp
biBrZXJuZWwvdXNlcl9uYW1lc3BhY2UuYy4gV2hpY2ggaXMgY29ycmVjdC4KYW5kIHRoZSB3cml0
ZSBtdXN0IGJlIHBlcmZvcm1lZCBhdCB0aGUgc3RhcnQgb2YgdGhlIGZpbGUgKGkuZS4sCi5CUiBs
c2VlayAoMikKYW5kCi5CUiBwd3JpdGUgKDIpCmNhbid0IGJlIHVzZWQgdG8gd3JpdGUgdG8gbm9u
emVybyBvZmZzZXRzIGluIHRoZSBmaWxlKS4KLklQICoKVGhlIHJhbmdlIG9mIHVzZXIgSURzIChn
cm91cCBJRHMpCnNwZWNpZmllZCBpbiBlYWNoIGxpbmUgY2Fubm90IG92ZXJsYXAgd2l0aCB0aGUg
cmFuZ2VzCmluIGFueSBvdGhlciBsaW5lcy4KSW4gdGhlIGluaXRpYWwgaW1wbGVtZW50YXRpb24g
KExpbnV4IDMuOCksIHRoaXMgcmVxdWlyZW1lbnQgd2FzCnNhdGlzZmllZCBieSBhIHNpbXBsaXN0
aWMgaW1wbGVtZW50YXRpb24gdGhhdCBpbXBvc2VkIHRoZSBmdXJ0aGVyCnJlcXVpcmVtZW50IHRo
YXQKdGhlIHZhbHVlcyBpbiBib3RoIGZpZWxkIDEgYW5kIGZpZWxkIDIgb2Ygc3VjY2Vzc2l2ZSBs
aW5lcyBtdXN0IGJlCmluIGFzY2VuZGluZyBudW1lcmljYWwgb3JkZXIsCndoaWNoIHByZXZlbnRl
ZCBzb21lIG90aGVyd2lzZSB2YWxpZCBtYXBzIGZyb20gYmVpbmcgY3JlYXRlZC4KTGludXggMy45
IGFuZCBsYXRlcgouXCIgY29tbWl0IDBiZDE0YjRmZDcyYWZkNWRmNDFlOWZkNTlmMzU2NzQwZjIy
ZmNlYmEKZml4IHRoaXMgbGltaXRhdGlvbiwgYWxsb3dpbmcgYW55IHZhbGlkIHNldCBvZiBub25v
dmVybGFwcGluZyBtYXBzLgouSVAgKgpBdCBsZWFzdCBvbmUgbGluZSBtdXN0IGJlIHdyaXR0ZW4g
dG8gdGhlIGZpbGUuCi5QUApXcml0ZXMgdGhhdCB2aW9sYXRlIHRoZSBhYm92ZSBydWxlcyBmYWls
IHdpdGggdGhlIGVycm9yCi5CUiBFSU5WQUwgLgoKSW4gb3JkZXIgZm9yIGEgcHJvY2VzcyB0byB3
cml0ZSB0byB0aGUKLkkgL3Byb2MvW3BpZF0vdWlkX21hcAouUkkgKCAvcHJvYy9bcGlkXS9naWRf
bWFwICkKZmlsZSwgYWxsIG9mIHRoZSBmb2xsb3dpbmcgcmVxdWlyZW1lbnRzIG11c3QgYmUgbWV0
OgouSVAgMS4gMwpUaGUgd3JpdGluZyBwcm9jZXNzIG11c3QgaGF2ZSB0aGUKLkJSIENBUF9TRVRV
SUQKLlJCICggQ0FQX1NFVEdJRCApCmNhcGFiaWxpdHkgaW4gdGhlIHVzZXIgbmFtZXNwYWNlIG9m
IHRoZSBwcm9jZXNzCi5JUiBwaWQgLgouSVAgMi4KVGhlIHdyaXRpbmcgcHJvY2VzcyBtdXN0IGJl
IGluIGVpdGhlciB0aGUgdXNlciBuYW1lc3BhY2Ugb2YgdGhlIHByb2Nlc3MKLkkgcGlkCm9yIGlu
c2lkZSB0aGUgcGFyZW50IHVzZXIgbmFtZXNwYWNlIG9mIHRoZSBwcm9jZXNzCi5JUiBwaWQgLgou
SVAgMy4KVGhlIG1hcHBlZCB1c2VyIElEcyAoZ3JvdXAgSURzKSBtdXN0IGluIHR1cm4gaGF2ZSBh
IG1hcHBpbmcKaW4gdGhlIHBhcmVudCB1c2VyIG5hbWVzcGFjZS4KLklQIDQuCk9uZSBvZiB0aGUg
Zm9sbG93aW5nIGlzIHRydWU6Ci5SUwouSVAgKiAzClRoZSBkYXRhIHdyaXR0ZW4gdG8KLkkgdWlk
X21hcAouUkkgKCBnaWRfbWFwICkKY29uc2lzdHMgb2YgYSBzaW5nbGUgbGluZSB0aGF0IG1hcHMg
dGhlIHdyaXRpbmcgcHJvY2VzcydzIGZpbGUgc3lzdGVtIHVzZXIgSUQKKGdyb3VwIElEKSBpbiB0
aGUgcGFyZW50IHVzZXIgbmFtZXNwYWNlIHRvIGEgdXNlciBJRCAoZ3JvdXAgSUQpCmluIHRoZSB1
c2VyIG5hbWVzcGFjZS4KVGhlIHVzdWFsIGNhc2UgaGVyZSBpcyB0aGF0IHRoaXMgc2luZ2xlIGxp
bmUgcHJvdmlkZXMgYSBtYXBwaW5nIGZvciB1c2VyIElECm9mIHRoZSBwcm9jZXNzIHRoYXQgY3Jl
YXRlZCB0aGUgbmFtZXNwYWNlLgouSVAgKiAzClRoZSBwcm9jZXNzIGhhcyB0aGUKLkJSIENBUF9T
RVRVSUQKLlJCICggQ0FQX1NFVEdJRCApCmNhcGFiaWxpdHkgaW4gdGhlIHBhcmVudCB1c2VyIG5h
bWVzcGFjZS4KVGh1cywgYSBwcml2aWxlZ2VkIHByb2Nlc3MgY2FuIG1ha2UgbWFwcGluZ3MgdG8g
YXJiaXRyYXJ5IHVzZXIgSURzIChncm91cCBJRHMpCmluIHRoZSBwYXJlbnQgdXNlciBuYW1lc3Bh
Y2UuCi5SRQouUFAKV3JpdGVzIHRoYXQgdmlvbGF0ZSB0aGUgYWJvdmUgcnVsZXMgZmFpbCB3aXRo
IHRoZSBlcnJvcgouQlIgRVBFUk0gLgouXCIKLlwiID09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PQouXCIKLlNTIFVubWFwcGVkIHVzZXIg
YW5kIGdyb3VwIElEcwouUFAKVGhlcmUgYXJlIHZhcmlvdXMgcGxhY2VzIHdoZXJlIGFuIHVubWFw
cGVkIHVzZXIgSUQgKGdyb3VwIElEKQptYXkgYmUgZXhwb3NlZCB0byB1c2VyIHNwYWNlLgpGb3Ig
ZXhhbXBsZSwgdGhlIGZpcnN0IHByb2Nlc3MgaW4gYSBuZXcgdXNlciBuYW1lc3BhY2UgbWF5IGNh
bGwKLkJSIGdldHVpZCAoKQpiZWZvcmUgYSB1c2VyIElEIG1hcHBpbmcgaGFzIGJlZW4gZGVmaW5l
ZCBmb3IgdGhlIG5hbWVzcGFjZS4KSW4gbW9zdCBzdWNoIGNhc2VzLCBhbiB1bm1hcHBlZCB1c2Vy
IElEIGlzIGNvbnZlcnRlZAouXCIgZnJvbV9rdWlkX211bmdlZCgpLCBmcm9tX2tnaWRfbXVuZ2Vk
KCkKdG8gdGhlIG92ZXJmbG93IHVzZXIgSUQgKGdyb3VwIElEKTsKdGhlIGRlZmF1bHQgdmFsdWUg
Zm9yIHRoZSBvdmVyZmxvdyB1c2VyIElEIChncm91cCBJRCkgaXMgNjU1MzQuClNlZSB0aGUgZGVz
Y3JpcHRpb25zIG9mCi5JUiAvcHJvYy9zeXMva2VybmVsL292ZXJmbG93dWlkCmFuZAouSVIgL3By
b2Mvc3lzL2tlcm5lbC9vdmVyZmxvd2dpZAppbgouQlIgcHJvYyAoNSkuCgpUaGUgY2FzZXMgd2hl
cmUgdW5tYXBwZWQgSURzIGFyZSBtYXBwZWQgaW4gdGhpcyBmYXNoaW9uIGluY2x1ZGUKc3lzdGVt
IGNhbGxzIHRoYXQgcmV0dXJuIHVzZXIgSURzCi5SQiAoIGdldHVpZCAoMikKLkJSIGdldGdpZCAo
MiksCmFuZCBzaW1pbGFyKSwKY3JlZGVudGlhbHMgcGFzc2VkIG92ZXIgYSBVTklYIGRvbWFpbiBz
b2NrZXQsCi5cIiBhbHNvIFNPX1BFRVJDUkVECmNyZWRlbnRpYWxzIHJldHVybmVkIGJ5Ci5CUiBz
dGF0ICgyKSwKLkJSIHdhaXRpZCAoMiksCmFuZCB0aGUgU3lzdGVtIFYgSVBDICJjdGwiCi5CIElQ
Q19TVEFUCm9wZXJhdGlvbnMsCmNyZWRlbnRpYWxzIGV4cG9zZWQgYnkKLklSIC9wcm9jL1BJRC9z
dGF0dXMgCmFuZCB0aGUgZmlsZXMgaW4KLklSIC9wcm9jL3N5c3ZpcGMvKiAsCmNyZWRlbnRpYWxz
IHJldHVybmVkIHZpYSB0aGUKLkkgc2lfdWlkCmZpZWxkIGluIHRoZQouSSBzaWdpbmZvX3QKcmVj
ZWl2ZWQgd2l0aCBhIHNpZ25hbCAoc2VlCi5CUiBzaWdhY3Rpb24gKDIpKSwKY3JlZGVudGlhbHMg
d3JpdHRlbiB0byB0aGUgcHJvY2VzcyBhY2NvdW50aW5nIGZpbGUgKHNlZQouQlIgYWNjdCAoNSkp
LAphbmQgY3JlZGVudGlhbHMgcmV0dXJuZWQgd2l0aCBQT1NJWCBtZXNzYWdlIHF1ZXVlIG5vdGlm
aWNhdGlvbnMgKHNlZQouQlIgbXFfbm90aWZ5ICgzKSkuCgpUaGVyZSBpcyBvbmUgbm90YWJsZSBj
YXNlIHdoZXJlIHVubWFwcGVkIHVzZXIgYW5kIGdyb3VwIElEcyBhcmUKLkkgbm90Ci5cIiBmcm9t
X2t1aWQoKSwgZnJvbV9rZ2lkKCkKLlwiIEFsc28gRl9HRVRPV05FUl9VSURTIGlzIGFuIGV4Y2Vw
dGlvbgpjb252ZXJ0ZWQgdG8gdGhlIGNvcnJlc3BvbmRpbmcgb3ZlcmZsb3cgSUQgdmFsdWUuCldo
ZW4gdmlld2luZyBhCi5JIHVpZF9tYXAKb3IKLkkgZ2lkX21hcApmaWxlIGluIHdoaWNoIHRoZXJl
IGlzIG5vIG1hcHBpbmcgZm9yIHRoZSBzZWNvbmQgZmllbGQsCnRoYXQgZmllbGQgaXMgZGlzcGxh
eWVkIGFzIDQyOTQ5NjcyOTUgKFwtMSBhcyBhbiB1bnNpZ25lZCBpbnRlZ2VyKTsKLlwiCi5cIiA9
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT0KLlwiCi5TUyBTZXQtdXNlci1JRCBhbmQgc2V0LWdyb3VwLUlEIHByb2dyYW1zCi5QUApXaGVu
IGEgcHJvY2VzcyBpbnNpZGUgYSB1c2VyIG5hbWVzcGFjZSBleGVjdXRlcwphIHNldC11c2VyLUlE
IChzZXQtZ3JvdXAtSUQpIHByb2dyYW0sCnRoZSBwcm9jZXNzJ3MgZWZmZWN0aXZlIHVzZXIgKGdy
b3VwKSBJRCBpbnNpZGUgdGhlIG5hbWVzcGFjZSBpcyBjaGFuZ2VkCnRvIHdoYXRldmVyIHZhbHVl
IGlzIG1hcHBlZCBmb3IgdGhlIHVzZXIgKGdyb3VwKSBJRCBvZiB0aGUgZmlsZS4KSG93ZXZlciwg
aWYgZWl0aGVyIHRoZSB1c2VyCi5JIG9yCnRoZSBncm91cCBJRCBvZiB0aGUgZmlsZSBoYXMgbm8g
bWFwcGluZyBpbnNpZGUgdGhlIG5hbWVzcGFjZSwKdGhlIHNldC11c2VyLUlEIChzZXQtZ3JvdXAt
SUQpIGJpdCBpcyBzaWxlbnRseSBpZ25vcmVkOgp0aGUgbmV3IHByb2dyYW0gaXMgZXhlY3V0ZWQs
CmJ1dCB0aGUgcHJvY2VzcydzIGVmZmVjdGl2ZSB1c2VyIChncm91cCkgSUQgaXMgbGVmdCB1bmNo
YW5nZWQuCihUaGlzIG1pcnJvcnMgdGhlIHNlbWFudGljcyBvZiBleGVjdXRpbmcgYSBzZXQtdXNl
ci1JRCBvciBzZXQtZ3JvdXAtSUQKcHJvZ3JhbSB0aGF0IHJlc2lkZXMgb24gYSBmaWxlIHN5c3Rl
bSB0aGF0IHdhcyBtb3VudGVkIHdpdGggdGhlCi5CUiBNU19OT1NVSUQKZmxhZywgYXMgZGVzY3Jp
YmVkIGluCi5CUiBtb3VudCAoMikuKQouXCIKLlwiID09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PQouXCIKLlNTIE1pc2NlbGxhbmVvdXMK
LlBQCldoZW4gYSBwcm9jZXNzJ3MgdXNlciBhbmQgZ3JvdXAgSURzIGFyZSBwYXNzZWQgb3ZlciBh
IFVOSVggZG9tYWluIHNvY2tldAp0byBhIHByb2Nlc3MgaW4gYSBkaWZmZXJlbnQgdXNlciBuYW1l
c3BhY2UgKHNlZSB0aGUgZGVzY3JpcHRpb24gb2YKLkIgU0NNX0NSRURFTlRJQUxTCmluCi5CUiB1
bml4ICg3KSksCnRoZXkgYXJlIHRyYW5zbGF0ZWQgaW50byB0aGUgY29ycmVzcG9uZGluZyB2YWx1
ZXMgYXMgcGVyIHRoZQpyZWNlaXZpbmcgcHJvY2VzcydzIHVzZXIgYW5kIGdyb3VwIElEIG1hcHBp
bmdzLgouXCIKLlNIIENPTkZPUk1JTkcgVE8KTmFtZXNwYWNlcyBhcmUgYSBMaW51eC1zcGVjaWZp
YyBmZWF0dXJlLgouXCIKLlNIIE5PVEVTCk92ZXIgdGhlIHllYXJzLCB0aGVyZSBoYXZlIGJlZW4g
YSBsb3Qgb2YgZmVhdHVyZXMgdGhhdCBoYXZlIGJlZW4gYWRkZWQKdG8gdGhlIExpbnV4IGtlcm5l
bCB0aGF0IGhhdmUgYmVlbiBtYWRlIGF2YWlsYWJsZSBvbmx5IHRvIHByaXZpbGVnZWQgdXNlcnMK
YmVjYXVzZSBvZiB0aGVpciBwb3RlbnRpYWwgdG8gY29uZnVzZSBzZXQtdXNlci1JRC1yb290IGFw
cGxpY2F0aW9ucy4KSW4gZ2VuZXJhbCwgaXQgYmVjb21lcyBzYWZlIHRvIGFsbG93IHRoZSByb290
IHVzZXIgaW4gYSB1c2VyIG5hbWVzcGFjZSB0bwp1c2UgdGhvc2UgZmVhdHVyZXMgYmVjYXVzZSBp
dCBpcyBpbXBvc3NpYmxlLCB3aGlsZSBpbiBhIHVzZXIgbmFtZXNwYWNlLAp0byBnYWluIG1vcmUg
cHJpdmlsZWdlIHRoYW4gdGhlIHJvb3QgdXNlciBvZiBhIHVzZXIgbmFtZXNwYWNlIGhhcy4KLlNT
IEF2YWlsYWJpbGl0eQpVc2Ugb2YgdXNlciBuYW1lc3BhY2VzIHJlcXVpcmVzIGEga2VybmVsIHRo
YXQgaXMgY29uZmlndXJlZCB3aXRoIHRoZQouQiBDT05GSUdfVVNFUl9OUwpvcHRpb24uClVzZXIg
bmFtZXNwYWNlcyByZXF1aXJlIHN1cHBvcnQgaW4gYSByYW5nZSBvZiBzdWJzeXN0ZW1zIGFjcm9z
cwp0aGUga2VybmVsLgpXaGVuIGFuIHVuc3VwcG9ydGVkIHN1YnN5c3RlbSBpcyBjb25maWd1cmVk
IGludG8gdGhlIGtlcm5lbCwKaXQgaXMgbm90IHBvc3NpYmxlIHRvIGNvbmZpZ3VyZSB1c2VyIG5h
bWVzcGFjZXMgc3VwcG9ydC4KQXMgYXQgTGludXggMy44LCBtb3N0IHJlbGV2YW50IHN1YnN5c3Rl
bXMgc3VwcG9ydCB1c2VyIG5hbWVzcGFjZXMsCmJ1dCB0aGVyZSBhcmUgYSBudW1iZXIgb2YgZmls
ZSBzeXN0ZW1zIHRoYXQgZG8gbm90LgpMaW51eCAzLjkgYWRkZWQgdXNlciBuYW1lc3BhY2VzIHN1
cHBvcnQgZm9yIG1hbnkgb2YgdGhlIHJlbWFpbmluZwp1bnN1cHBvcnRlZCBmaWxlIHN5c3RlbXM6
ClBsYW4gOSAoOVApLCBBbmRyZXcgRmlsZSBTeXN0ZW0gKEFGUyksIENlcGgsIENJRlMsIENPREEs
IE5GUywgYW5kIE9DRlMyLgpYRlMgc3VwcG9ydCBmb3IgdXNlciBuYW1lc3BhY2VzIGlzIG5vdCB5
ZXQgYXZhaWxhYmxlLgouXCIKLlNIIEVYQU1QTEUKVGhlIHByb2dyYW0gYmVsb3cgaXMgZGVzaWdu
ZWQgdG8gYWxsb3cgZXhwZXJpbWVudGluZyB3aXRoCnVzZXIgbmFtZXNwYWNlcywgYXMgd2VsbCBh
cyBvdGhlciB0eXBlcyBvZiBuYW1lc3BhY2VzLgpJdCBjcmVhdGVzIG5hbWVzcGFjZXMgYXMgc3Bl
Y2lmaWVkIGJ5IGNvbW1hbmQtbGluZSBvcHRpb25zIGFuZCB0aGVuIGV4ZWN1dGVzCmEgY29tbWFu
ZCBpbnNpZGUgdGhvc2UgbmFtZXNwYWNlcy4KVGhlIGNvbW1lbnRzIGFuZAouSSB1c2FnZSgpCmZ1
bmN0aW9uIGluc2lkZSB0aGUgcHJvZ3JhbSBwcm92aWRlIGEgZnVsbCBleHBsYW5hdGlvbiBvZiB0
aGUgcHJvZ3JhbS4KVGhlIGZvbGxvd2luZyBzaGVsbCBzZXNzaW9uIGRlbW9uc3RyYXRlcyBpdHMg
dXNlLgoKRmlyc3QsIHdlIGxvb2sgYXQgdGhlIHJ1bi10aW1lIGVudmlyb25tZW50OgoKLmluICs0
bgoubmYKJCBcZkJ1bmFtZSAtcnNcZlAgICAgICMgTmVlZCBMaW51eCAzLjggb3IgbGF0ZXIKTGlu
dXggMy44LjAKJCBcZkJpZCAtdVxmUCAgICAgICAgICMgUnVubmluZyBhcyB1bnByaXZpbGVnZWQg
dXNlcgoxMDAwCiQgXGZCaWQgLWdcZlAKMTAwMAouZmkKLmluCgpOb3cgc3RhcnQgYSBuZXcgc2hl
bGwgaW4gbmV3IHVzZXIKLlJJICggXC1VICksCm1vdW50Ci5SSSAoIFwtbSApLAphbmQgUElECi5S
SSAoIFwtcCApCm5hbWVzcGFjZXMsIHdpdGggdXNlciBJRAouUkkgKCBcLU0gKQphbmQgZ3JvdXAg
SUQKLlJJICggXC1HICkKMTAwMCBtYXBwZWQgdG8gMCBpbnNpZGUgdGhlIHVzZXIgbmFtZXNwYWNl
OgoKLmluICs0bgoubmYKJCBcZkIuL3VzZXJuc19jaGlsZF9leGVjIC1wIC1tIC1VIC1NICcwIDEw
MDAgMScgLUcgJzAgMTAwMCAxJyBiYXNoXGZQCi5maQouaW4KClRoZSBzaGVsbCBoYXMgUElEIDEs
IGJlY2F1c2UgaXQgaXMgdGhlIGZpcnN0IHByb2Nlc3MgaW4gdGhlIG5ldyAKUElEIG5hbWVzcGFj
ZToKCi5pbiArNG4KLm5mCmJhc2gkIFxmQmVjaG8gJCRcZlAKMQouZmkKLmluCgpJbnNpZGUgdGhl
IHVzZXIgbmFtZXNwYWNlLCB0aGUgc2hlbGwgaGFzIHVzZXIgYW5kIGdyb3VwIElEIDAsCmFuZCBh
IGZ1bGwgc2V0IG9mIHBlcm1pdHRlZCBhbmQgZWZmZWN0aXZlIGNhcGFiaWxpdGllczoKCi5pbiAr
NG4KLm5mCmJhc2gkIFxmQmNhdCAvcHJvYy8kJC9zdGF0dXMgfCBlZ3JlcCAnXltVR11pZCdcZlAK
VWlkOgkwCTAJMAkwCkdpZDoJMAkwCTAJMApiYXNoJCBcZkJjYXQgL3Byb2MvJCQvc3RhdHVzIHwg
ZWdyZXAgJ15DYXAoUHJtfEluaHxFZmYpJ1xmUApDYXBJbmg6CTAwMDAwMDAwMDAwMDAwMDAKQ2Fw
UHJtOgkwMDAwMDAxZmZmZmZmZmZmCkNhcEVmZjoJMDAwMDAwMWZmZmZmZmZmZgouZmkKLmluCgpN
b3VudGluZyBhIG5ldwouSSAvcHJvYwpmaWxlIHN5c3RlbSBhbmQgbGlzdGluZyBhbGwgb2YgdGhl
IHByb2Nlc3NlcyB2aXNpYmxlCmluIHRoZSBuZXcgUElEIG5hbWVzcGFjZSBzaG93cyB0aGF0IHRo
ZSBzaGVsbCBjYW4ndCBzZWUKYW55IHByb2Nlc3NlcyBvdXRzaWRlIHRoZSBQSUQgbmFtZXNwYWNl
OgoKLmluICs0bgoubmYKYmFzaCQgXGZCbW91bnQgLXQgcHJvYyBwcm9jIC9wcm9jXGZQCmJhc2gk
IFxmQnBzIGF4XGZQCiAgUElEIFRUWSAgICAgIFNUQVQgICBUSU1FIENPTU1BTkQKICAgIDEgcHRz
LzMgICAgUyAgICAgIDA6MDAgYmFzaAogICAyMiBwdHMvMyAgICBSKyAgICAgMDowMCBwcyBheAou
ZmkKLmluCi5TUyBQcm9ncmFtIHNvdXJjZQpcJgoubmYKLyogdXNlcm5zX2NoaWxkX2V4ZWMuYwoK
ICAgTGljZW5zZWQgdW5kZXIgR05VIEdlbmVyYWwgUHVibGljIExpY2Vuc2UgdjIgb3IgbGF0ZXIK
CiAgIENyZWF0ZSBhIGNoaWxkIHByb2Nlc3MgdGhhdCBleGVjdXRlcyBhIHNoZWxsIGNvbW1hbmQg
aW4gbmV3CiAgIG5hbWVzcGFjZShzKTsgYWxsb3cgVUlEIGFuZCBHSUQgbWFwcGluZ3MgdG8gYmUg
c3BlY2lmaWVkIHdoZW4KICAgY3JlYXRpbmcgYSB1c2VyIG5hbWVzcGFjZS4KKi8KI2RlZmluZSBf
R05VX1NPVVJDRQojaW5jbHVkZSA8c2NoZWQuaD4KI2luY2x1ZGUgPHVuaXN0ZC5oPgojaW5jbHVk
ZSA8c3RkbGliLmg+CiNpbmNsdWRlIDxzeXMvd2FpdC5oPgojaW5jbHVkZSA8c2lnbmFsLmg+CiNp
bmNsdWRlIDxmY250bC5oPgojaW5jbHVkZSA8c3RkaW8uaD4KI2luY2x1ZGUgPHN0cmluZy5oPgoj
aW5jbHVkZSA8bGltaXRzLmg+CiNpbmNsdWRlIDxlcnJuby5oPgoKLyogQSBzaW1wbGUgZXJyb3Jc
LWhhbmRsaW5nIGZ1bmN0aW9uOiBwcmludCBhbiBlcnJvciBtZXNzYWdlIGJhc2VkCiAgIG9uIHRo
ZSB2YWx1ZSBpbiBcKGFxZXJybm9cKGFxIGFuZCB0ZXJtaW5hdGUgdGhlIGNhbGxpbmcgcHJvY2Vz
cyAqLwoKI2RlZmluZSBlcnJFeGl0KG1zZykgICAgZG8geyBwZXJyb3IobXNnKTsgZXhpdChFWElU
X0ZBSUxVUkUpOyBcXAogICAgICAgICAgICAgICAgICAgICAgICB9IHdoaWxlICgwKQoKc3RydWN0
IGNoaWxkX2FyZ3MgewogICAgY2hhciAqKmFyZ3Y7ICAgICAgICAvKiBDb21tYW5kIHRvIGJlIGV4
ZWN1dGVkIGJ5IGNoaWxkLCB3aXRoIGFyZ3MgKi8KICAgIGludCAgICBwaXBlX2ZkWzJdOyAgLyog
UGlwZSB1c2VkIHRvIHN5bmNocm9uaXplIHBhcmVudCBhbmQgY2hpbGQgKi8KfTsKCnN0YXRpYyBp
bnQgdmVyYm9zZTsKCnN0YXRpYyB2b2lkCnVzYWdlKGNoYXIgKnBuYW1lKQp7CiAgICBmcHJpbnRm
KHN0ZGVyciwgIlVzYWdlOiAlcyBbb3B0aW9uc10gY21kIFthcmcuLi5dXFxuXFxuIiwgcG5hbWUp
OwogICAgZnByaW50ZihzdGRlcnIsICJDcmVhdGUgYSBjaGlsZCBwcm9jZXNzIHRoYXQgZXhlY3V0
ZXMgYSBzaGVsbCAiCiAgICAgICAgICAgICJjb21tYW5kIGluIGEgbmV3IHVzZXIgbmFtZXNwYWNl
LFxcbiIKICAgICAgICAgICAgImFuZCBwb3NzaWJseSBhbHNvIG90aGVyIG5ldyBuYW1lc3BhY2Uo
cykuXFxuXFxuIik7CiAgICBmcHJpbnRmKHN0ZGVyciwgIk9wdGlvbnMgY2FuIGJlOlxcblxcbiIp
OwojZGVmaW5lIGZwZShzdHIpIGZwcmludGYoc3RkZXJyLCAiICAgICVzIiwgc3RyKTsKICAgIGZw
ZSgiXC1pICAgICAgICAgIE5ldyBJUEMgbmFtZXNwYWNlXFxuIik7CiAgICBmcGUoIlwtbSAgICAg
ICAgICBOZXcgbW91bnQgbmFtZXNwYWNlXFxuIik7CiAgICBmcGUoIlwtbiAgICAgICAgICBOZXcg
bmV0d29yayBuYW1lc3BhY2VcXG4iKTsKICAgIGZwZSgiXC1wICAgICAgICAgIE5ldyBQSUQgbmFt
ZXNwYWNlXFxuIik7CiAgICBmcGUoIlwtdSAgICAgICAgICBOZXcgVVRTIG5hbWVzcGFjZVxcbiIp
OwogICAgZnBlKCJcLVUgICAgICAgICAgTmV3IHVzZXIgbmFtZXNwYWNlXFxuIik7CiAgICBmcGUo
IlwtTSB1aWRfbWFwICBTcGVjaWZ5IFVJRCBtYXAgZm9yIHVzZXIgbmFtZXNwYWNlXFxuIik7CiAg
ICBmcGUoIlwtRyBnaWRfbWFwICBTcGVjaWZ5IEdJRCBtYXAgZm9yIHVzZXIgbmFtZXNwYWNlXFxu
Iik7CiAgICBmcGUoIlwteiAgICAgICAgICBNYXAgdXNlclwoYXFzIFVJRCBhbmQgR0lEIHRvIDAg
aW4gdXNlciBuYW1lc3BhY2VcXG4iKTsKICAgIGZwZSgiICAgICAgICAgICAgKGVxdWl2YWxlbnQg
dG86IFwtTSBcKGFxMCA8dWlkPiAxXChhcSBcLUcgXChhcTAgPGdpZD4gMVwoYXEpXFxuIik7CiAg
ICBmcGUoIlwtdiAgICAgICAgICBEaXNwbGF5IHZlcmJvc2UgbWVzc2FnZXNcXG4iKTsKICAgIGZw
ZSgiXFxuIik7CiAgICBmcGUoIklmIFwteiwgXC1NLCBvciBcLUcgaXMgc3BlY2lmaWVkLCBcLVUg
aXMgcmVxdWlyZWQuXFxuIik7CiAgICBmcGUoIkl0IGlzIG5vdCBwZXJtaXR0ZWQgdG8gc3BlY2lm
eSBib3RoIFwteiBhbmQgZWl0aGVyIFwtTSBvciBcLUcuXFxuIik7CiAgICBmcGUoIlxcbiIpOwog
ICAgZnBlKCJNYXAgc3RyaW5ncyBmb3IgXC1NIGFuZCBcLUcgY29uc2lzdCBvZiByZWNvcmRzIG9m
IHRoZSBmb3JtOlxcbiIpOwogICAgZnBlKCJcXG4iKTsKICAgIGZwZSgiICAgIElEXC1pbnNpZGVc
LW5zICAgSURcLW91dHNpZGVcLW5zICAgbGVuXFxuIik7CiAgICBmcGUoIlxcbiIpOwogICAgZnBl
KCJBIG1hcCBzdHJpbmcgY2FuIGNvbnRhaW4gbXVsdGlwbGUgcmVjb3Jkcywgc2VwYXJhdGVkIgog
ICAgICAgICIgYnkgY29tbWFzO1xcbiIpOwogICAgZnBlKCJ0aGUgY29tbWFzIGFyZSByZXBsYWNl
ZCBieSBuZXdsaW5lcyBiZWZvcmUgd3JpdGluZyIKICAgICAgICAiIHRvIG1hcCBmaWxlcy5cXG4i
KTsKCiAgICBleGl0KEVYSVRfRkFJTFVSRSk7Cn0KCi8qIFVwZGF0ZSB0aGUgbWFwcGluZyBmaWxl
IFwoYXFtYXBfZmlsZVwoYXEsIHdpdGggdGhlIHZhbHVlIHByb3ZpZGVkIGluCiAgIFwoYXFtYXBw
aW5nXChhcSwgYSBzdHJpbmcgdGhhdCBkZWZpbmVzIGEgVUlEIG9yIEdJRCBtYXBwaW5nLiBBIFVJ
RCBvcgogICBHSUQgbWFwcGluZyBjb25zaXN0cyBvZiBvbmUgb3IgbW9yZSBuZXdsaW5lXC1kZWxp
bWl0ZWQgcmVjb3JkcwogICBvZiB0aGUgZm9ybToKCiAgICAgICBJRF9pbnNpZGVcLW5zICAgIElE
XC1vdXRzaWRlXC1ucyAgIGxlbmd0aAoKICAgUmVxdWlyaW5nIHRoZSB1c2VyIHRvIHN1cHBseSBh
IHN0cmluZyB0aGF0IGNvbnRhaW5zIG5ld2xpbmVzIGlzCiAgIG9mIGNvdXJzZSBpbmNvbnZlbmll
bnQgZm9yIGNvbW1hbmRcLWxpbmUgdXNlLiBUaHVzLCB3ZSBwZXJtaXQgdGhlCiAgIHVzZSBvZiBj
b21tYXMgdG8gZGVsaW1pdCByZWNvcmRzIGluIHRoaXMgc3RyaW5nLCBhbmQgcmVwbGFjZSB0aGVt
CiAgIHdpdGggbmV3bGluZXMgYmVmb3JlIHdyaXRpbmcgdGhlIHN0cmluZyB0byB0aGUgZmlsZS4g
Ki8KCnN0YXRpYyB2b2lkCnVwZGF0ZV9tYXAoY2hhciAqbWFwcGluZywgY2hhciAqbWFwX2ZpbGUp
CnsKICAgIGludCBmZCwgajsKICAgIHNpemVfdCBtYXBfbGVuOyAgICAgLyogTGVuZ3RoIG9mIFwo
YXFtYXBwaW5nXChhcSAqLwoKICAgIC8qIFJlcGxhY2UgY29tbWFzIGluIG1hcHBpbmcgc3RyaW5n
IHdpdGggbmV3bGluZXMgKi8KCiAgICBtYXBfbGVuID0gc3RybGVuKG1hcHBpbmcpOwogICAgZm9y
IChqID0gMDsgaiA8IG1hcF9sZW47IGorKykKICAgICAgICBpZiAobWFwcGluZ1tqXSA9PSBcKGFx
LFwoYXEpCiAgICAgICAgICAgIG1hcHBpbmdbal0gPSBcKGFxXFxuXChhcTsKCiAgICBmZCA9IG9w
ZW4obWFwX2ZpbGUsIE9fUkRXUik7CiAgICBpZiAoZmQgPT0gXC0xKSB7CiAgICAgICAgZnByaW50
ZihzdGRlcnIsICJFUlJPUjogb3BlbiAlczogJXNcXG4iLCBtYXBfZmlsZSwgc3RyZXJyb3IoZXJy
bm8pKTsKICAgICAgICByZXR1cm47CiAgICAgICAgLy9leGl0KEVYSVRfRkFJTFVSRSk7CiAgICB9
CgogICAgaWYgKHdyaXRlKGZkLCBtYXBwaW5nLCBtYXBfbGVuKSAhPSBtYXBfbGVuKSB7CiAgICAg
ICAgZnByaW50ZihzdGRlcnIsICJFUlJPUjogd3JpdGUgJXM6ICVzXFxuIiwgbWFwX2ZpbGUsIHN0
cmVycm9yKGVycm5vKSk7CiAgICAgICAgLy9leGl0KEVYSVRfRkFJTFVSRSk7CiAgICB9CgogICAg
Y2xvc2UoZmQpOwp9CgpzdGF0aWMgaW50ICAgICAgICAgICAgICAvKiBTdGFydCBmdW5jdGlvbiBm
b3IgY2xvbmVkIGNoaWxkICovCmNoaWxkRnVuYyh2b2lkICphcmcpCnsKICAgIHN0cnVjdCBjaGls
ZF9hcmdzICphcmdzID0gKHN0cnVjdCBjaGlsZF9hcmdzICopIGFyZzsKICAgIGNoYXIgY2g7Cgog
ICAgLyogV2FpdCB1bnRpbCB0aGUgcGFyZW50IGhhcyB1cGRhdGVkIHRoZSBVSUQgYW5kIEdJRCBt
YXBwaW5ncy4KICAgICAgIFNlZSB0aGUgY29tbWVudCBpbiBtYWluKCkuIFdlIHdhaXQgZm9yIGVu
ZCBvZiBmaWxlIG9uIGEKICAgICAgIHBpcGUgdGhhdCB3aWxsIGJlIGNsb3NlZCBieSB0aGUgcGFy
ZW50IHByb2Nlc3Mgb25jZSBpdCBoYXMKICAgICAgIHVwZGF0ZWQgdGhlIG1hcHBpbmdzLiAqLwoK
ICAgIGNsb3NlKGFyZ3NcLT5waXBlX2ZkWzFdKTsgICAgLyogQ2xvc2Ugb3VyIGRlc2NyaXB0b3Ig
Zm9yIHRoZSB3cml0ZQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIGVuZCBvZiB0
aGUgcGlwZSBzbyB0aGF0IHdlIHNlZSBFT0YKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg
ICAgICB3aGVuIHBhcmVudCBjbG9zZXMgaXRzIGRlc2NyaXB0b3IgKi8KICAgIGlmIChyZWFkKGFy
Z3NcLT5waXBlX2ZkWzBdLCAmY2gsIDEpICE9IDApIHsKICAgICAgICBmcHJpbnRmKHN0ZGVyciwK
ICAgICAgICAgICAgICAgICJGYWlsdXJlIGluIGNoaWxkOiByZWFkIGZyb20gcGlwZSByZXR1cm5l
ZCAhPSAwXFxuIik7CiAgICAgICAgZXhpdChFWElUX0ZBSUxVUkUpOwogICAgfQoKICAgIC8qIEV4
ZWN1dGUgYSBzaGVsbCBjb21tYW5kICovCgogICAgcHJpbnRmKCJBYm91dCB0byBleGVjICVzXFxu
IiwgYXJnc1wtPmFyZ3ZbMF0pOwogICAgZXhlY3ZwKGFyZ3NcLT5hcmd2WzBdLCBhcmdzXC0+YXJn
dik7CiAgICBlcnJFeGl0KCJleGVjdnAiKTsKfQoKI2RlZmluZSBTVEFDS19TSVpFICgxMDI0ICog
MTAyNCkKCnN0YXRpYyBjaGFyIGNoaWxkX3N0YWNrW1NUQUNLX1NJWkVdOyAgICAvKiBTcGFjZSBm
b3IgY2hpbGRcKGFxcyBzdGFjayAqLwoKaW50Cm1haW4oaW50IGFyZ2MsIGNoYXIgKmFyZ3ZbXSkK
ewogICAgaW50IGZsYWdzLCBvcHQsIG1hcF96ZXJvOwogICAgcGlkX3QgY2hpbGRfcGlkOwogICAg
c3RydWN0IGNoaWxkX2FyZ3MgYXJnczsKICAgIGNoYXIgKnVpZF9tYXAsICpnaWRfbWFwOwogICAg
Y29uc3QgaW50IE1BUF9CVUZfU0laRSA9IDEwMDsKICAgIGNoYXIgbWFwX2J1ZltNQVBfQlVGX1NJ
WkVdOwogICAgY2hhciBtYXBfcGF0aFtQQVRIX01BWF07CgogICAgLyogUGFyc2UgY29tbWFuZFwt
bGluZSBvcHRpb25zLiBUaGUgaW5pdGlhbCBcKGFxK1woYXEgY2hhcmFjdGVyIGluCiAgICAgICB0
aGUgZmluYWwgZ2V0b3B0KCkgYXJndW1lbnQgcHJldmVudHMgR05VXC1zdHlsZSBwZXJtdXRhdGlv
bgogICAgICAgb2YgY29tbWFuZFwtbGluZSBvcHRpb25zLiBUaGF0XChhcXMgdXNlZnVsLCBzaW5j
ZSBzb21ldGltZXMKICAgICAgIHRoZSBcKGFxY29tbWFuZFwoYXEgdG8gYmUgZXhlY3V0ZWQgYnkg
dGhpcyBwcm9ncmFtIGl0c2VsZgogICAgICAgaGFzIGNvbW1hbmRcLWxpbmUgb3B0aW9ucy4gV2Ug
ZG9uXChhcXQgd2FudCBnZXRvcHQoKSB0byB0cmVhdAogICAgICAgdGhvc2UgYXMgb3B0aW9ucyB0
byB0aGlzIHByb2dyYW0uICovCgogICAgZmxhZ3MgPSAwOwogICAgdmVyYm9zZSA9IDA7CiAgICBn
aWRfbWFwID0gTlVMTDsKICAgIHVpZF9tYXAgPSBOVUxMOwogICAgbWFwX3plcm8gPSAwOwogICAg
d2hpbGUgKChvcHQgPSBnZXRvcHQoYXJnYywgYXJndiwgIitpbW5wdVVNOkc6enYiKSkgIT0gXC0x
KSB7CiAgICAgICAgc3dpdGNoIChvcHQpIHsKICAgICAgICBjYXNlIFwoYXFpXChhcTogZmxhZ3Mg
fD0gQ0xPTkVfTkVXSVBDOyAgICAgICAgYnJlYWs7CiAgICAgICAgY2FzZSBcKGFxbVwoYXE6IGZs
YWdzIHw9IENMT05FX05FV05TOyAgICAgICAgIGJyZWFrOwogICAgICAgIGNhc2UgXChhcW5cKGFx
OiBmbGFncyB8PSBDTE9ORV9ORVdORVQ7ICAgICAgICBicmVhazsKICAgICAgICBjYXNlIFwoYXFw
XChhcTogZmxhZ3MgfD0gQ0xPTkVfTkVXUElEOyAgICAgICAgYnJlYWs7CiAgICAgICAgY2FzZSBc
KGFxdVwoYXE6IGZsYWdzIHw9IENMT05FX05FV1VUUzsgICAgICAgIGJyZWFrOwogICAgICAgIGNh
c2UgXChhcXZcKGFxOiB2ZXJib3NlID0gMTsgICAgICAgICAgICAgICAgICBicmVhazsKICAgICAg
ICBjYXNlIFwoYXF6XChhcTogbWFwX3plcm8gPSAxOyAgICAgICAgICAgICAgICAgYnJlYWs7CiAg
ICAgICAgY2FzZSBcKGFxTVwoYXE6IHVpZF9tYXAgPSBvcHRhcmc7ICAgICAgICAgICAgIGJyZWFr
OwogICAgICAgIGNhc2UgXChhcUdcKGFxOiBnaWRfbWFwID0gb3B0YXJnOyAgICAgICAgICAgICBi
cmVhazsKICAgICAgICBjYXNlIFwoYXFVXChhcTogZmxhZ3MgfD0gQ0xPTkVfTkVXVVNFUjsgICAg
ICAgYnJlYWs7CiAgICAgICAgZGVmYXVsdDogIHVzYWdlKGFyZ3ZbMF0pOwogICAgICAgIH0KICAg
IH0KCiAgICAvKiBcLU0gb3IgXC1HIHdpdGhvdXQgXC1VIGlzIG5vbnNlbnNpY2FsICovCgogICAg
aWYgKCgodWlkX21hcCAhPSBOVUxMIHx8IGdpZF9tYXAgIT0gTlVMTCB8fCBtYXBfemVybykgJiYK
ICAgICAgICAgICAgICAgICEoZmxhZ3MgJiBDTE9ORV9ORVdVU0VSKSkgfHwKICAgICAgICAgICAg
KG1hcF96ZXJvICYmICh1aWRfbWFwICE9IE5VTEwgfHwgZ2lkX21hcCAhPSBOVUxMKSkpCiAgICAg
ICAgdXNhZ2UoYXJndlswXSk7CgogICAgYXJncy5hcmd2ID0gJmFyZ3Zbb3B0aW5kXTsKCiAgICAv
KiBXZSB1c2UgYSBwaXBlIHRvIHN5bmNocm9uaXplIHRoZSBwYXJlbnQgYW5kIGNoaWxkLCBpbiBv
cmRlciB0bwogICAgICAgZW5zdXJlIHRoYXQgdGhlIHBhcmVudCBzZXRzIHRoZSBVSUQgYW5kIEdJ
RCBtYXBzIGJlZm9yZSB0aGUgY2hpbGQKICAgICAgIGNhbGxzIGV4ZWN2ZSgpLiBUaGlzIGVuc3Vy
ZXMgdGhhdCB0aGUgY2hpbGQgbWFpbnRhaW5zIGl0cwogICAgICAgY2FwYWJpbGl0aWVzIGR1cmlu
ZyB0aGUgZXhlY3ZlKCkgaW4gdGhlIGNvbW1vbiBjYXNlIHdoZXJlIHdlCiAgICAgICB3YW50IHRv
IG1hcCB0aGUgY2hpbGRcKGFxcyBlZmZlY3RpdmUgdXNlciBJRCB0byAwIGluIHRoZSBuZXcgdXNl
cgogICAgICAgbmFtZXNwYWNlLiBXaXRob3V0IHRoaXMgc3luY2hyb25pemF0aW9uLCB0aGUgY2hp
bGQgd291bGQgbG9zZQogICAgICAgaXRzIGNhcGFiaWxpdGllcyBpZiBpdCBwZXJmb3JtZWQgYW4g
ZXhlY3ZlKCkgd2l0aCBub256ZXJvCiAgICAgICB1c2VyIElEcyAoc2VlIHRoZSBjYXBhYmlsaXRp
ZXMoNykgbWFuIHBhZ2UgZm9yIGRldGFpbHMgb2YgdGhlCiAgICAgICB0cmFuc2Zvcm1hdGlvbiBv
ZiBhIHByb2Nlc3NcKGFxcyBjYXBhYmlsaXRpZXMgZHVyaW5nIGV4ZWN2ZSgpKS4gKi8KCiAgICBp
ZiAocGlwZShhcmdzLnBpcGVfZmQpID09IFwtMSkKICAgICAgICBlcnJFeGl0KCJwaXBlIik7Cgog
ICAgLyogQ3JlYXRlIHRoZSBjaGlsZCBpbiBuZXcgbmFtZXNwYWNlKHMpICovCgogICAgY2hpbGRf
cGlkID0gY2xvbmUoY2hpbGRGdW5jLCBjaGlsZF9zdGFjayArIFNUQUNLX1NJWkUsCiAgICAgICAg
ICAgICAgICAgICAgICBmbGFncyB8IFNJR0NITEQsICZhcmdzKTsKICAgIGlmIChjaGlsZF9waWQg
PT0gXC0xKQogICAgICAgIGVyckV4aXQoImNsb25lIik7CgogICAgLyogUGFyZW50IGZhbGxzIHRo
cm91Z2ggdG8gaGVyZSAqLwoKICAgIGlmICh2ZXJib3NlKQogICAgICAgIHByaW50ZigiJXM6IFBJ
RCBvZiBjaGlsZCBjcmVhdGVkIGJ5IGNsb25lKCkgaXMgJWxkXFxuIiwKICAgICAgICAgICAgICAg
IGFyZ3ZbMF0sIChsb25nKSBjaGlsZF9waWQpOwoKICAgIC8qIFVwZGF0ZSB0aGUgVUlEIGFuZCBH
SUQgbWFwcyBpbiB0aGUgY2hpbGQgKi8KCiAgICBpZiAodWlkX21hcCAhPSBOVUxMIHx8IG1hcF96
ZXJvKSB7CiAgICAgICAgc25wcmludGYobWFwX3BhdGgsIFBBVEhfTUFYLCAiL3Byb2MvJWxkL3Vp
ZF9tYXAiLAogICAgICAgICAgICAgICAgKGxvbmcpIGNoaWxkX3BpZCk7CiAgICAgICAgaWYgKG1h
cF96ZXJvKSB7CiAgICAgICAgICAgIHNucHJpbnRmKG1hcF9idWYsIE1BUF9CVUZfU0laRSwgIjAg
JWxkIDEiLCAobG9uZykgZ2V0dWlkKCkpOwogICAgICAgICAgICB1aWRfbWFwID0gbWFwX2J1ZjsK
ICAgICAgICB9CiAgICAgICAgdXBkYXRlX21hcCh1aWRfbWFwLCBtYXBfcGF0aCk7CiAgICB9CiAg
ICBpZiAoZ2lkX21hcCAhPSBOVUxMIHx8IG1hcF96ZXJvKSB7CiAgICAgICAgc25wcmludGYobWFw
X3BhdGgsIFBBVEhfTUFYLCAiL3Byb2MvJWxkL2dpZF9tYXAiLAogICAgICAgICAgICAgICAgKGxv
bmcpIGNoaWxkX3BpZCk7CiAgICAgICAgaWYgKG1hcF96ZXJvKSB7CiAgICAgICAgICAgIHNucHJp
bnRmKG1hcF9idWYsIE1BUF9CVUZfU0laRSwgIjAgJWxkIDEiLCAobG9uZykgZ2V0Z2lkKCkpOwog
ICAgICAgICAgICBnaWRfbWFwID0gbWFwX2J1ZjsKICAgICAgICB9CiAgICAgICAgdXBkYXRlX21h
cChnaWRfbWFwLCBtYXBfcGF0aCk7CiAgICB9CgogICAgLyogQ2xvc2UgdGhlIHdyaXRlIGVuZCBv
ZiB0aGUgcGlwZSwgdG8gc2lnbmFsIHRvIHRoZSBjaGlsZCB0aGF0IHdlCiAgICAgICBoYXZlIHVw
ZGF0ZWQgdGhlIFVJRCBhbmQgR0lEIG1hcHMgKi8KCiAgICBjbG9zZShhcmdzLnBpcGVfZmRbMV0p
OwoKICAgIGlmICh3YWl0cGlkKGNoaWxkX3BpZCwgTlVMTCwgMCkgPT0gXC0xKSAgICAgIC8qIFdh
aXQgZm9yIGNoaWxkICovCiAgICAgICAgZXJyRXhpdCgid2FpdHBpZCIpOwoKICAgIGlmICh2ZXJi
b3NlKQogICAgICAgIHByaW50ZigiJXM6IHRlcm1pbmF0aW5nXFxuIiwgYXJndlswXSk7CgogICAg
ZXhpdChFWElUX1NVQ0NFU1MpOwp9Ci5maQouU0ggU0VFIEFMU08KLkJSIG5ld2dpZG1hcCAoMSks
ICAgICAgXCIgRnJvbSB0aGUgc2hhZG93IHBhY2thZ2UKLkJSIG5ld3VpZG1hcCAoMSksICAgICAg
XCIgRnJvbSB0aGUgc2hhZG93IHBhY2thZ2UKLkJSIGNsb25lICgyKSwKLkJSIHNldG5zICgyKSwK
LkJSIHVuc2hhcmUgKDIpLAouQlIgcHJvYyAoNSksCi5CUiBzdWJnaWQgKDUpLCAgICAgICAgIFwi
IEZyb20gdGhlIHNoYWRvdyBwYWNrYWdlCi5CUiBzdWJ1aWQgKDUpLCAgICAgICAgIFwiIEZyb20g
dGhlIHNoYWRvdyBwYWNrYWdlCi5CUiBjcmVkZW50aWFscyAoNyksCi5CUiBjYXBhYmlsaXRpZXMg
KDcpLAouQlIgbmFtZXNwYWNlcyAoNyksCi5CUiBwaWRfbmFtZXNwYWNlcyAoNykKLnNwClRoZSBr
ZXJuZWwgc291cmNlIGZpbGUKLklSIERvY3VtZW50YXRpb24vbmFtZXNwYWNlcy9yZXNvdXJjZS1j
b250cm9sLnR4dCAuCg==
--047d7b86e75adc236304d8eeb01f
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--047d7b86e75adc236304d8eeb01f--
