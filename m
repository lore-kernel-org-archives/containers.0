From: "Michael Kerrisk (man-pages)" <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: For review: user_namespaces(7) man page
Date: Fri, 15 Mar 2013 07:37:48 +0100
Message-ID: <CAKgNAkh1TEkQiQ2g2jhbNzVTwpDYOreJt3rAukZCP9H1wh0mLQ__27003.6726295531$1363329528$gmane$org@mail.gmail.com>
Reply-To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=bcaec5314b2df1bcc404d7f0e15e
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
Cc: linux-man <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

--bcaec5314b2df1bcc404d7f0e15e
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

Eric: Various pieces of the page are shifted out of other pages
(clone(2), setns(2), etc.) and are derived from comments you've
emailed me off list, so you are (jointly) in the copyright of the
page. I've chosen the common license for man-pages (the same as used
for the pid_namespaces(7) page). I assume that license will be okay
for you, since you gae it a pass for pid_namespaces(7), but please
confirm.

Cheers,

Michael

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

USER_NAMESPACES(7)         Linux Programmer's Manual        USER_NAMESPACES=
(7)



NAME
       user_namespaces - overview of Linux user_namespaces

DESCRIPTION
       For an overview of namespaces, see namespaces(7).

       User  namespaces  isolate  security-related identifiers, in particul=
ar,
       user IDs and group IDs (see credentials(7), keys (see  keyctl(2)),  =
and
       capabilities (see capabilities(7)).  A process's user and group IDs =
can
       be different inside and outside a user  namespace.   In  particular,=
  a
       process can have a normal unprivileged user ID outside a user namesp=
ace
       while at the same time having a user ID of 0 inside the  namespace; =
 in
       other  words, the process has full privileges for operations inside =
the
       user namespace, but is unprivileged for operations outside  the  nam=
es=E2=80=90
       pace.

       Use  of  user  namespaces requires a kernel that is configured with =
the
       CONFIG_USER_NS option.

   Nested namespaces, namespace membership
       User namespaces can be nested; that is, each user namespace=E2=80=94=
except  the
       initial  ("root")  namespace=E2=80=94has  a parent user namespace, a=
nd can have
       zero or more child user namespaces.  The parent user namespace  is  =
the
       user  namespace  of  the  process that creates the user namespace vi=
a a
       call to unshare(2) or clone(2) with the CLONE_NEWUSER flag.

       Each process is a member of exactly one user namespace.  A process c=
re=E2=80=90
       ated via fork(2) or clone(2) without the CLONE_NEWUSER flag is a mem=
ber
       of the same user namespace as its parent.  A process can  join  anot=
her
       user namespace with setns(2) if it has the CAP_SYS_ADMIN in that nam=
es=E2=80=90
       pace; upon doing so, it gains a full set of capabilities in that nam=
es=E2=80=90
       pace.

       A  call to clone(2) or unshare(2) with the CLONE_NEWUSER flag makes =
the
       new child process (for clone(2)) or the caller (for unshare(2)) a  m=
em=E2=80=90
       ber of the new user namespace created by the call.

   Capabilities
       The  child  process  created  by  clone(2)  with the CLONE_NEWUSER f=
lag
       starts out with a complete set of capabilities in the new  user  nam=
es=E2=80=90
       pace.   Likewise,  a  process  that  creates a new user namespace us=
ing
       unshare(2) or joins an existing user namespace using setns(2)  gains=
  a
       full  set  of  capabilities in that namespace.  On the other hand, t=
hat
       process has no capabilities in the parent (in the case of clone(2)) =
 or
       previous  (in the case of unshare(2) and setns(2)) user namespace, e=
ven
       if the new namespace is created or joined by the  root  user  (i.e.,=
  a
       process  with  user  ID  0  in  the  root namespace).  (Nevertheless=
, a
       process owned by the root user will be able to access resources such=
 as
       files  that  are owned by user ID 0, and will be able to do things s=
uch
       as sending signals to processes belonging to user ID 0.)

       A call to clone(2), unshare(2), or  setns(2)  using  the  CLONE_NEWU=
SER
       flag sets the "securebits" flags (see capabilities(7)) to their defa=
ult
       values (all flags disabled) in the child (for clone(2)) or caller  (=
for
       unshare(2),  or  setns(2)).  Note that because the caller no longer =
has
       capabilities in its original user namespace after a call  to  setns(=
2),
       it  is not possible for a process to reset its "securebits" flags wh=
ile
       retaining its user namespace membership by using  a  pair  of  setns=
(2)
       calls to move to another user namespace and then return to its origi=
nal
       user namespace.

       Having a capability inside a user namespace permits a process  to  p=
er=E2=80=90
       form  operations (that require privilege) only on resources governed=
 by
       that namespace.  The rules for determining whether or not a process =
has
       a capability in a particular user namespace are as follows:

       1. A process has a capability inside a user namespace if it is a mem=
ber
          of that namespace and it has the capability in its  effective  ca=
pa=E2=80=90
          bility  set.  A process can gain capabilities in its effective ca=
pa=E2=80=90
          bility set in various ways.  For example, it may execute a set-us=
er-
          ID  program  or an executable with associated file capabilities. =
 In
          addition,  a  process  may  gain  capabilities  via  the  effect =
 of
          clone(2), unshare(2), or setns(2), as already described.

       2. If  a process has a capability in a user namespace, then it has t=
hat
          capability in all child (and further removed descendant)  namespa=
ces
          as well.

       3. When  a  user namespace is created, the kernel records the effect=
ive
          user ID of the creating process as being the "owner" of  the  nam=
es=E2=80=90
          pace.   A  process  that resides in the parent of the user namesp=
ace
          and whose effective user ID matches the owner of the  namespace  =
has
          all  capabilities in the namespace.  By virtue of the previous ru=
le,
          this means that the process has  all  capabilities  in  all  furt=
her
          removed descendant user namespaces as well.

   Interaction of user namespaces and other types of namespaces
       Starting  in  Linux  3.8, unprivileged processes can create user nam=
es=E2=80=90
       paces, and mount, PID, IPC, network, and UTS namespaces can be  crea=
ted
       with just the CAP_SYS_ADMIN capability in the caller's user namespac=
e.

       If  CLONE_NEWUSER  is  specified along with other CLONE_NEW* flags i=
n a
       single clone(2) or unshare(2) call, the user namespace is guaranteed=
 to
       be  created  first,  giving the child (clone(2)) or caller (unshare(=
2))
       privileges over the remaining namespaces created by the call.  Thus,=
 it
       is  possible  for an unprivileged caller to specify this combination=
 of
       flags.

       When a new IPC, mount, network, PID, or UTS namespace  is  created  =
via
       clone(2)  or  unshare(2),  the kernel records the user namespace of =
the
       creating process against the new namespace.  (This association can't=
 be
       changed.)   When  a  process in the new namespace subsequently perfo=
rms
       privileged operations that operate on global resources isolated by  =
the
       namespace,  the  permission  checks  are  performed  according  to  =
the
       process's capabilities in the user namespace that the kernel associa=
ted
       with the new namespace.

   User and group ID mappings: uid_map and gid_map
       When  a  user  namespace is created, it starts out without a mapping=
 of
       user  IDs  (group   IDs)   to   the   parent   user   namespace.    =
The
       /proc/[pid]/uid_map  and  /proc/[pid]/gid_map  files  (available  si=
nce
       Linux 3.5) expose the mappings for user and group IDs inside  the  u=
ser
       namespace  for  the  process  pid.  These files can be read to view =
the
       mappings in a user namespace and written to (once) to define  the  m=
ap=E2=80=90
       pings.

       The  description  in  the following paragraphs explains the details =
for
       uid_map; gid_map is exactly the same, but each instance of "user ID"=
 is
       replaced by "group ID".

       The  uid_map  file exposes the mapping of user IDs from the user nam=
es=E2=80=90
       pace of the process pid to the  user  namespace  of  the  process  t=
hat
       opened uid_map (but see a qualification to this point below).  In ot=
her
       words, processes that are in different user namespaces will potentia=
lly
       see  different  values  when  reading  from  a particular uid_map fi=
le,
       depending on the user ID mappings for the user namespaces of the  re=
ad=E2=80=90
       ing processes.

       Each  line in the uid_map file specifies a 1-to-1 mapping of a range=
 of
       contiguous user IDs between two user namespaces.  (When a  user  nam=
es=E2=80=90
       pace  is first created, this file is empty.)  The specification in e=
ach
       line takes the form of three numbers delimited  by  white  space.   =
The
       first  two numbers specify the starting user ID in each of the two u=
ser
       namespaces.  The third number specifies the length of the mapped ran=
ge.
       In detail, the fields are interpreted as follows:

       (1) The  start  of  the  range of user IDs in the user namespace of =
the
           process pid.

       (2) The start of the range of user IDs to which the user IDs  specif=
ied
           by  field one map.  How field two is interpreted depends on whet=
her
           the process that opened uid_map and the process pid are in the s=
ame
           user namespace, as follows:

           a) If the two processes are in different user namespaces: field =
two
              is the start of a range of user IDs in the user namespace of =
the
              process that opened uid_map.

           b) If  the  two processes are in the same user namespace: field =
two
              is the start of the range of user IDs in the parent user  nam=
es=E2=80=90
              pace  of  the  process  pid.   This  case  enables the opener=
 of
              uid_map (the common case here is opening /proc/self/uid_map) =
 to
              see  the  mapping  of  user  IDs  into the user namespace of =
the
              process that created this user namespace.

       (3) The length of the range of user IDs that is mapped between the  =
two
           user namespaces.

       System  calls  that return user IDs (group IDs)=E2=80=94for example,=
 getuid(2),
       getgid(2), and the credential  fields  in  the  structure  returned =
 by
       stat(2)=E2=80=94return  the  user  ID  (group ID) mapped into the ca=
ller's user
       namespace.

       When a process accesses a file, its user and group IDs are mapped  i=
nto
       the  initial  user namespace for the purpose of permission checking =
and
       assigning IDs when creating a file.  When a process retrieves file u=
ser
       and  group  IDs  via stat(2), the IDs are mapped in the opposite dir=
ec=E2=80=90
       tion, to produce values relative to the process user and group ID  m=
ap=E2=80=90
       pings.

       The  initial  user  namespace has no parent namespace, but, for cons=
is=E2=80=90
       tency, the kernel provides dummy user and group ID  mapping  files  =
for
       this namespace.  Looking at the uid_map file (gid_map is the same) f=
rom
       a shell in the initial namespace shows:

           $ cat /proc/$$/uid_map
                    0          0 4294967295

       This mapping tells us that the range starting at  user  ID  0  in  t=
his
       namespace  maps  to  a  range starting at 0 in the (nonexistent) par=
ent
       namespace, and the length of the range is the largest  32-bit  unsig=
ned
       integer.

   Defining user and group ID mappings: writing to uid_map and gid_map
       After  the creation of a new user namespace, the uid_map file of one=
 of
       the processes in the namespace may be written to  once  to  define  =
the
       mapping  of  user  IDs  in the new user namespace.  An attempt to wr=
ite
       more than once to a uid_map file in a user  namespace  fails  with  =
the
       error EPERM.  Similar rules apply for gid_map files.

       The  lines  written  to uid_map (gid_map) must conform to the follow=
ing
       rules:

       *  The three fields must be valid numbers, and the last field  must =
 be
          greater than 0.

       *  Lines are terminated by newline characters.

       *  There  is  an  (arbitrary) limit on the number of lines in the fi=
le.
          As at Linux 3.8, the limit is five lines.  In addition,  the  num=
ber
          of bytes written to the file must be less than the system page si=
ze,
          and the write must be performed at the  start  of  the  file  (i.=
e.,
          lseek(2)  and pwrite(2) can't be used to write to nonzero offsets=
 in
          the file).

       *  The range of user IDs (group IDs)  specified  in  each  line  can=
not
          overlap  with  the ranges in any other lines.  In the initial imp=
le=E2=80=90
          mentation (Linux 3.8), this requirement was satisfied by a  simpl=
is=E2=80=90
          tic  implementation  that  imposed  the further requirement that =
the
          values in both field 1 and field 2 of successive lines  must  be =
 in
          ascending numerical order, which prevented some otherwise valid m=
aps
          from being created.  Linux 3.9 and later fix this limitation, all=
ow=E2=80=90
          ing any valid set of nonoverlapping maps.

       *  At least one line must be written to the file.

       Writes that violate the above rules fail with the error EINVAL.

       In   order   for   a   process  to  write  to  the  /proc/[pid]/uid_=
map
       (/proc/[pid]/gid_map) file, all of the following requirements  must =
 be
       met:

       1. The writing process must have the CAP_SETUID (CAP_SETGID) capabil=
ity
          in the user namespace of the process pid.

       2. The writing process must be in either  the  user  namespace  of  =
the
          process pid or inside the parent user namespace of the process pi=
d.

       3. The  mapped  user IDs (group IDs) must in turn have a mapping in =
the
          parent user namespace.

       4. One of the following is true:

          *  The data written to uid_map (gid_map) consists of a  single  l=
ine
             that maps the writing process's file system user ID (group ID)=
 in
             the parent user namespace to a user ID (group  ID)  in  the  u=
ser
             namespace.  The usual case here is that this single line provi=
des
             a mapping for user ID of the process that created the namespac=
e.

          *  The process has the CAP_SETUID  (CAP_SETGID)  capability  in  =
the
             parent  user namespace.  Thus, a privileged process can make m=
ap=E2=80=90
             pings to arbitrary user IDs (group IDs) in the parent user nam=
es=E2=80=90
             pace.

       Writes that violate the above rules fail with the error EPERM.

   Unmapped user and group IDs
       There  are  various  places where an unmapped user ID (group ID) may=
 be
       exposed to user space.  For example, the first process in  a  new  u=
ser
       namespace  may  call getuid() before a user ID mapping has been defi=
ned
       for the namespace.  In most such cases, an unmapped  user  ID  is  c=
on=E2=80=90
       verted  to  the  overflow user ID (group ID); the default value for =
the
       overflow user  ID  (group  ID)  is  65534.   See  the  descriptions =
 of
       /proc/sys/kernel/overflowuid    and   /proc/sys/kernel/overflowgid  =
 in
       proc(5).

       The cases where unmapped IDs are mapped in this fashion include  sys=
tem
       calls  that return user IDs (getuid(2) getgid(2), and similar), cred=
en=E2=80=90
       tials passed  over  a  UNIX  domain  socket,  credentials  returned =
 by
       stat(2),  waitid(2),  and  the  System V IPC "ctl" IPC_STAT operatio=
ns,
       credentials   exposed   by   /proc/PID/status   and   the   files   =
 in
       /proc/sysvipc/*,  credentials returned via the si_uid field in the s=
ig=E2=80=90
       info_t received with a signal (see sigaction(2)),  credentials  writ=
ten
       to  the process accounting file (see acct(5)), and credentials retur=
ned
       with POSIX message queue notifications (see mq_notify(3)).

       There is one notable case where unmapped user and  group  IDs  are  =
not
       converted  to  the  corresponding  overflow  ID  value.  When viewin=
g a
       uid_map or gid_map file in which there is no  mapping  for  the  sec=
ond
       field,  that  field is displayed as 4294967295 (-1 as an unsigned in=
te=E2=80=90
       ger);

   Set-user-ID and set-group-ID programs
       When a process inside a user namespace  executes  a  set-user-ID  (s=
et-
       group-ID)  program,  the process's effective user (group) ID inside =
the
       namespace is changed to whatever value is mapped for the  user  (gro=
up)
       ID  of  the  file.   However, if either the user or the group ID of =
the
       file has no mapping inside the namespace, the  set-user-ID  (set-gro=
up-
       ID)  bit  is  silently  ignored:  the  new program is executed, but =
the
       process's effective user (group) ID is left unchanged.   (This  mirr=
ors
       the  semantics  of executing a set-user-ID or set-group-ID program t=
hat
       resides on a file system that was mounted with the MS_NOSUID  flag, =
 as
       described in mount(2).)

   Miscellaneous
       When  a  process's  user  and  group  IDs are passed over a UNIX dom=
ain
       socket to a process in a different user namespace (see the  descript=
ion
       of  SCM_CREDENTIALS  in  unix(7)),  they are translated into the cor=
re=E2=80=90
       sponding values as per the receiving process's user and group  ID  m=
ap=E2=80=90
       pings.


CONFORMING TO
       Namespaces are a Linux-specific feature.

NOTES
       Over  the years, there have been a lot of features that have been ad=
ded
       to the Linux kernel that have been made available  only  to  privile=
ged
       users  because  of their potential to confuse set-user-ID-root appli=
ca=E2=80=90
       tions.  In general, it becomes safe to allow the root user  in  a  u=
ser
       namespace  to  use  those features because it is impossible, while i=
n a
       user namespace, to gain more privilege than the root  user  of  a  u=
ser
       namespace has.

EXAMPLE
       The  program  below is designed to allow experimenting with user nam=
es=E2=80=90
       paces, as well as other types of namespaces.  It creates namespaces =
 as
       specified  by  command-line  options and then executes a command ins=
ide
       those namespaces.  The comments and usage() function inside the prog=
ram
       provide a full explanation of the program.  The following shell sess=
ion
       demonstrates its use.

       First, we look at the run-time environment:

           $ uname -rs     # Need Linux 3.8 or later
           Linux 3.8.0
           $ id -u         # Running as unprivileged user
           1000
           $ id -g
           1000

       Now start a new shell in new user (-U), mount (-m), and PID (-p) nam=
es=E2=80=90
       paces,  with user ID (-M) and group ID (-G) 1000 mapped to 0 inside =
the
       user namespace:

           $ ./userns_child_exec -p -m -U -M '0 1000 1' -G '0 1000 1' bash

       The shell has PID 1, because it is the first process  in  the  new  =
PID
       namespace:

           bash$ echo $$
           1

       Inside  the  user  namespace,  the shell has user and group ID 0, an=
d a
       full set of permitted and effective capabilities:

           bash$ cat /proc/$$/status | egrep '^[UG]id'
           Uid: 0    0    0    0
           Gid: 0    0    0    0
           bash$ cat /proc/$$/status | egrep '^Cap(Prm|Inh|Eff)'
           CapInh:   0000000000000000
           CapPrm:   0000001fffffffff
           CapEff:   0000001fffffffff

       Mounting a new /proc file system and listing all of the processes vi=
si=E2=80=90
       ble  in  the  new PID namespace shows that the shell can't see any p=
ro=E2=80=90
       cesses outside the PID namespace:

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
           fpe("            If -M or -G is specified, -U is required\n");
           fpe("-v          Display verbose messages\n");
           fpe("\n");
           fpe("Map strings for -M and -G consist of records of the form:\n=
");
           fpe("\n");
           fpe("    ID-inside-ns   ID-outside-ns   len\n");
           fpe("\n");
           fpe("A map string can contain multiple records, ");
           fpe("separated by commas;\n");
           fpe("the commas are replaced by newlines before writing");
           fpe(" to map files.\n");

           exit(EXIT_FAILURE);
       }

       /* Update the mapping file 'map_file', with the value provided in
          'mapping', a string that defines a UID or GID mapping. A UID or
          GID mapping consists of one or more newline-delimited records
          of the form:

              ID-inside-ns    ID-outside-ns   length

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
               fprintf(stderr, "open %s: %s\n", map_file, strerror(errno));
               exit(EXIT_FAILURE);
           }

           if (write(fd, mapping, map_len) !=3D map_len) {
               fprintf(stderr, "write %s: %s\n", map_file, strerror(errno))=
;
               exit(EXIT_FAILURE);
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

           execvp(args->argv[0], args->argv);
           errExit("execvp");
       }

       #define STACK_SIZE (1024 * 1024)

       static char child_stack[STACK_SIZE];    /* Space for child's stack *=
/

       int
       main(int argc, char *argv[])
       {
           int flags, opt;
           pid_t child_pid;
           struct child_args args;
           char *uid_map, *gid_map;
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
           while ((opt =3D getopt(argc, argv, "+imnpuUM:G:v")) !=3D -1) {
               switch (opt) {
               case 'i': flags |=3D CLONE_NEWIPC;        break;
               case 'm': flags |=3D CLONE_NEWNS;         break;
               case 'n': flags |=3D CLONE_NEWNET;        break;
               case 'p': flags |=3D CLONE_NEWPID;        break;
               case 'u': flags |=3D CLONE_NEWUTS;        break;
               case 'v': verbose =3D 1;                  break;
               case 'M': uid_map =3D optarg;             break;
               case 'G': gid_map =3D optarg;             break;
               case 'U': flags |=3D CLONE_NEWUSER;       break;
               default:  usage(argv[0]);
               }
           }

           /* -M or -G without -U is nonsensical */

           if ((uid_map !=3D NULL || gid_map !=3D NULL) &&
                   !(flags & CLONE_NEWUSER))
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

           if (uid_map !=3D NULL) {
               snprintf(map_path, PATH_MAX, "/proc/%ld/uid_map",
                       (long) child_pid);
               update_map(uid_map, map_path);
           }
           if (gid_map !=3D NULL) {
               snprintf(map_path, PATH_MAX, "/proc/%ld/gid_map",
                       (long) child_pid);
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
       clone(2),  setns(2),  unshare(2),  proc(5),  credentials(7),  capabi=
li=E2=80=90
       ties(7), namespaces(7), pid_namespaces(7)

       The kernel source file Documentation/namespaces/resource-control.txt=
.



Linux                             2013-01-14                USER_NAMESPACES=
(7)



=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D *roff source =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

$ cat user_namespaces.7
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

Use of user namespaces requires a kernel that is configured with the
.B CONFIG_USER_NS
option.
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
(Nevertheless, a process owned by the root user
will be able to access resources such as
files that are owned by user ID 0,
and will be able to do things such as sending signals
to processes belonging to user ID 0.)

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

.SH CONFORMING TO
Namespaces are a Linux-specific feature.
.SH NOTES
Over the years, there have been a lot of features that have been added
to the Linux kernel that have been made available only to privileged users
because of their potential to confuse set-user-ID-root applications.
In general, it becomes safe to allow the root user in a user namespace to
use those features because it is impossible, while in a user namespace,
to gain more privilege than the root user of a user namespace has.
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
    fpe("            If \-M or \-G is specified, \-U is required\\n");
    fpe("\-v          Display verbose messages\\n");
    fpe("\\n");
    fpe("Map strings for \-M and \-G consist of records of the form:\\n");
    fpe("\\n");
    fpe("    ID\-inside\-ns   ID\-outside\-ns   len\\n");
    fpe("\\n");
    fpe("A map string can contain multiple records, ");
    fpe("separated by commas;\\n");
    fpe("the commas are replaced by newlines before writing");
    fpe(" to map files.\\n");

    exit(EXIT_FAILURE);
}

/* Update the mapping file \(aqmap_file\(aq, with the value provided in
   \(aqmapping\(aq, a string that defines a UID or GID mapping. A UID or
   GID mapping consists of one or more newline\-delimited records
   of the form:

       ID\-inside\-ns    ID\-outside\-ns   length

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
        fprintf(stderr, "open %s: %s\\n", map_file, strerror(errno));
        exit(EXIT_FAILURE);
    }

    if (write(fd, mapping, map_len) !=3D map_len) {
        fprintf(stderr, "write %s: %s\\n", map_file, strerror(errno));
        exit(EXIT_FAILURE);
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

    execvp(args\->argv[0], args\->argv);
    errExit("execvp");
}

#define STACK_SIZE (1024 * 1024)

static char child_stack[STACK_SIZE];    /* Space for child\(aqs stack */

int
main(int argc, char *argv[])
{
    int flags, opt;
    pid_t child_pid;
    struct child_args args;
    char *uid_map, *gid_map;
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
    while ((opt =3D getopt(argc, argv, "+imnpuUM:G:v")) !=3D \-1) {
        switch (opt) {
        case \(aqi\(aq: flags |=3D CLONE_NEWIPC;        break;
        case \(aqm\(aq: flags |=3D CLONE_NEWNS;         break;
        case \(aqn\(aq: flags |=3D CLONE_NEWNET;        break;
        case \(aqp\(aq: flags |=3D CLONE_NEWPID;        break;
        case \(aqu\(aq: flags |=3D CLONE_NEWUTS;        break;
        case \(aqv\(aq: verbose =3D 1;                  break;
        case \(aqM\(aq: uid_map =3D optarg;             break;
        case \(aqG\(aq: gid_map =3D optarg;             break;
        case \(aqU\(aq: flags |=3D CLONE_NEWUSER;       break;
        default:  usage(argv[0]);
        }
    }

    /* \-M or \-G without \-U is nonsensical */

    if ((uid_map !=3D NULL || gid_map !=3D NULL) &&
            !(flags & CLONE_NEWUSER))
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

    if (uid_map !=3D NULL) {
        snprintf(map_path, PATH_MAX, "/proc/%ld/uid_map",
                (long) child_pid);
        update_map(uid_map, map_path);
    }
    if (gid_map !=3D NULL) {
        snprintf(map_path, PATH_MAX, "/proc/%ld/gid_map",
                (long) child_pid);
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
.BR clone (2),
.BR setns (2),
.BR unshare (2),
.BR proc (5),
.BR credentials (7),
.BR capabilities (7),
.BR namespaces (7),
.BR pid_namespaces (7)
.sp
The kernel source file
.IR Documentation/namespaces/resource-control.txt .

--bcaec5314b2df1bcc404d7f0e15e
Content-Type: application/octet-stream; name="user_namespaces.7"
Content-Disposition: attachment; filename="user_namespaces.7"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_heaz3vou0

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
CmFuZCBjYXBhYmlsaXRpZXMgKHNlZQouQlIgY2FwYWJpbGl0aWVzICg3KSkuCkEgcHJvY2Vzcydz
IHVzZXIgYW5kIGdyb3VwIElEcyBjYW4gYmUgZGlmZmVyZW50Cmluc2lkZSBhbmQgb3V0c2lkZSBh
IHVzZXIgbmFtZXNwYWNlLgpJbiBwYXJ0aWN1bGFyLAphIHByb2Nlc3MgY2FuIGhhdmUgYSBub3Jt
YWwgdW5wcml2aWxlZ2VkIHVzZXIgSUQgb3V0c2lkZSBhIHVzZXIgbmFtZXNwYWNlCndoaWxlIGF0
IHRoZSBzYW1lIHRpbWUgaGF2aW5nIGEgdXNlciBJRCBvZiAwIGluc2lkZSB0aGUgbmFtZXNwYWNl
OwppbiBvdGhlciB3b3JkcywKdGhlIHByb2Nlc3MgaGFzIGZ1bGwgcHJpdmlsZWdlcyBmb3Igb3Bl
cmF0aW9ucyBpbnNpZGUgdGhlIHVzZXIgbmFtZXNwYWNlLApidXQgaXMgdW5wcml2aWxlZ2VkIGZv
ciBvcGVyYXRpb25zIG91dHNpZGUgdGhlIG5hbWVzcGFjZS4KClVzZSBvZiB1c2VyIG5hbWVzcGFj
ZXMgcmVxdWlyZXMgYSBrZXJuZWwgdGhhdCBpcyBjb25maWd1cmVkIHdpdGggdGhlCi5CIENPTkZJ
R19VU0VSX05TCm9wdGlvbi4KLlwiCi5cIiA9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0KLlwiCi5TUyBOZXN0ZWQgbmFtZXNwYWNlcywg
bmFtZXNwYWNlIG1lbWJlcnNoaXAKVXNlciBuYW1lc3BhY2VzIGNhbiBiZSBuZXN0ZWQ7CnRoYXQg
aXMsIGVhY2ggdXNlciBuYW1lc3BhY2VcKGVtZXhjZXB0IHRoZSBpbml0aWFsICgicm9vdCIpCm5h
bWVzcGFjZVwoZW1oYXMgYSBwYXJlbnQgdXNlciBuYW1lc3BhY2UsCmFuZCBjYW4gaGF2ZSB6ZXJv
IG9yIG1vcmUgY2hpbGQgdXNlciBuYW1lc3BhY2VzLgpUaGUgcGFyZW50IHVzZXIgbmFtZXNwYWNl
IGlzIHRoZSB1c2VyIG5hbWVzcGFjZQpvZiB0aGUgcHJvY2VzcyB0aGF0IGNyZWF0ZXMgdGhlIHVz
ZXIgbmFtZXNwYWNlIHZpYSBhIGNhbGwgdG8KLkJSIHVuc2hhcmUgKDIpCm9yCi5CUiBjbG9uZSAo
MikKd2l0aCB0aGUKLkJSIENMT05FX05FV1VTRVIKZmxhZy4KCkVhY2ggcHJvY2VzcyBpcyBhIG1l
bWJlciBvZiBleGFjdGx5IG9uZSB1c2VyIG5hbWVzcGFjZS4KQSBwcm9jZXNzIGNyZWF0ZWQgdmlh
Ci5CUiBmb3JrICgyKQpvcgouQlIgY2xvbmUgKDIpCndpdGhvdXQgdGhlCi5CUiBDTE9ORV9ORVdV
U0VSCmZsYWcgaXMgYSBtZW1iZXIgb2YgdGhlIHNhbWUgdXNlciBuYW1lc3BhY2UgYXMgaXRzIHBh
cmVudC4KQSBwcm9jZXNzIGNhbiBqb2luIGFub3RoZXIgdXNlciBuYW1lc3BhY2Ugd2l0aAouQlIg
c2V0bnMgKDIpCmlmIGl0IGhhcyB0aGUKLkJSIENBUF9TWVNfQURNSU4KaW4gdGhhdCBuYW1lc3Bh
Y2U7CnVwb24gZG9pbmcgc28sIGl0IGdhaW5zIGEgZnVsbCBzZXQgb2YgY2FwYWJpbGl0aWVzIGlu
IHRoYXQgbmFtZXNwYWNlLgoKQSBjYWxsIHRvCi5CUiBjbG9uZSAoMikKb3IKLkJSIHVuc2hhcmUg
KDIpCndpdGggdGhlCi5CUiBDTE9ORV9ORVdVU0VSCmZsYWcgbWFrZXMgdGhlIG5ldyBjaGlsZCBw
cm9jZXNzIChmb3IKLkJSIGNsb25lICgyKSkKb3IgdGhlIGNhbGxlciAoZm9yCi5CUiB1bnNoYXJl
ICgyKSkKYSBtZW1iZXIgb2YgdGhlIG5ldyB1c2VyIG5hbWVzcGFjZSBjcmVhdGVkIGJ5IHRoZSBj
YWxsLgouXCIKLlwiID09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PQouXCIKLlNTIENhcGFiaWxpdGllcwpUaGUgY2hpbGQgcHJvY2VzcyBj
cmVhdGVkIGJ5Ci5CUiBjbG9uZSAoMikKd2l0aCB0aGUKLkJSIENMT05FX05FV1VTRVIKZmxhZyBz
dGFydHMgb3V0IHdpdGggYSBjb21wbGV0ZSBzZXQKb2YgY2FwYWJpbGl0aWVzIGluIHRoZSBuZXcg
dXNlciBuYW1lc3BhY2UuCkxpa2V3aXNlLCBhIHByb2Nlc3MgdGhhdCBjcmVhdGVzIGEgbmV3IHVz
ZXIgbmFtZXNwYWNlIHVzaW5nCi5CUiB1bnNoYXJlICgyKQpvciBqb2lucyBhbiBleGlzdGluZyB1
c2VyIG5hbWVzcGFjZSB1c2luZwouQlIgc2V0bnMgKDIpCmdhaW5zIGEgZnVsbCBzZXQgb2YgY2Fw
YWJpbGl0aWVzIGluIHRoYXQgbmFtZXNwYWNlLgpPbiB0aGUgb3RoZXIgaGFuZCwKdGhhdCBwcm9j
ZXNzIGhhcyBubyBjYXBhYmlsaXRpZXMgaW4gdGhlIHBhcmVudCAoaW4gdGhlIGNhc2Ugb2YKLkJS
IGNsb25lICgyKSkKb3IgcHJldmlvdXMgKGluIHRoZSBjYXNlIG9mCi5CUiB1bnNoYXJlICgyKQph
bmQKLkJSIHNldG5zICgyKSkKdXNlciBuYW1lc3BhY2UsCmV2ZW4gaWYgdGhlIG5ldyBuYW1lc3Bh
Y2UgaXMgY3JlYXRlZCBvciBqb2luZWQgYnkgdGhlIHJvb3QgdXNlcgooaS5lLiwgYSBwcm9jZXNz
IHdpdGggdXNlciBJRCAwIGluIHRoZSByb290IG5hbWVzcGFjZSkuCihOZXZlcnRoZWxlc3MsIGEg
cHJvY2VzcyBvd25lZCBieSB0aGUgcm9vdCB1c2VyCndpbGwgYmUgYWJsZSB0byBhY2Nlc3MgcmVz
b3VyY2VzIHN1Y2ggYXMKZmlsZXMgdGhhdCBhcmUgb3duZWQgYnkgdXNlciBJRCAwLAphbmQgd2ls
bCBiZSBhYmxlIHRvIGRvIHRoaW5ncyBzdWNoIGFzIHNlbmRpbmcgc2lnbmFscwp0byBwcm9jZXNz
ZXMgYmVsb25naW5nIHRvIHVzZXIgSUQgMC4pCgpBIGNhbGwgdG8gCi5CUiBjbG9uZSAoMiksCi5C
UiB1bnNoYXJlICgyKSwKb3IKLkJSIHNldG5zICgyKQp1c2luZyB0aGUKLkJSIENMT05FX05FV1VT
RVIKZmxhZyBzZXRzIHRoZSAic2VjdXJlYml0cyIgZmxhZ3MKKHNlZQouQlIgY2FwYWJpbGl0aWVz
ICg3KSkKdG8gdGhlaXIgZGVmYXVsdCB2YWx1ZXMgKGFsbCBmbGFncyBkaXNhYmxlZCkgaW4gdGhl
IGNoaWxkIChmb3IKLkJSIGNsb25lICgyKSkKb3IgY2FsbGVyIChmb3IKLkJSIHVuc2hhcmUgKDIp
LApvcgouQlIgc2V0bnMgKDIpKS4KTm90ZSB0aGF0IGJlY2F1c2UgdGhlIGNhbGxlciBubyBsb25n
ZXIgaGFzIGNhcGFiaWxpdGllcwppbiBpdHMgb3JpZ2luYWwgdXNlciBuYW1lc3BhY2UgYWZ0ZXIg
YSBjYWxsIHRvCi5CUiBzZXRucyAoMiksCml0IGlzIG5vdCBwb3NzaWJsZSBmb3IgYSBwcm9jZXNz
IHRvIHJlc2V0IGl0cyAic2VjdXJlYml0cyIgZmxhZ3Mgd2hpbGUKcmV0YWluaW5nIGl0cyB1c2Vy
IG5hbWVzcGFjZSBtZW1iZXJzaGlwIGJ5IHVzaW5nIGEgcGFpciBvZgouQlIgc2V0bnMgKDIpCmNh
bGxzIHRvIG1vdmUgdG8gYW5vdGhlciB1c2VyIG5hbWVzcGFjZSBhbmQgdGhlbiByZXR1cm4gdG8K
aXRzIG9yaWdpbmFsIHVzZXIgbmFtZXNwYWNlLgoKSGF2aW5nIGEgY2FwYWJpbGl0eSBpbnNpZGUg
YSB1c2VyIG5hbWVzcGFjZQpwZXJtaXRzIGEgcHJvY2VzcyB0byBwZXJmb3JtIG9wZXJhdGlvbnMg
KHRoYXQgcmVxdWlyZSBwcml2aWxlZ2UpCm9ubHkgb24gcmVzb3VyY2VzIGdvdmVybmVkIGJ5IHRo
YXQgbmFtZXNwYWNlLgpUaGUgcnVsZXMgZm9yIGRldGVybWluaW5nIHdoZXRoZXIgb3Igbm90IGEg
cHJvY2VzcyBoYXMgYSBjYXBhYmlsaXR5CmluIGEgcGFydGljdWxhciB1c2VyIG5hbWVzcGFjZSBh
cmUgYXMgZm9sbG93czoKLklQIDEuIDMKQSBwcm9jZXNzIGhhcyBhIGNhcGFiaWxpdHkgaW5zaWRl
IGEgdXNlciBuYW1lc3BhY2UKaWYgaXQgaXMgYSBtZW1iZXIgb2YgdGhhdCBuYW1lc3BhY2UgYW5k
Cml0IGhhcyB0aGUgY2FwYWJpbGl0eSBpbiBpdHMgZWZmZWN0aXZlIGNhcGFiaWxpdHkgc2V0LgpB
IHByb2Nlc3MgY2FuIGdhaW4gY2FwYWJpbGl0aWVzIGluIGl0cyBlZmZlY3RpdmUgY2FwYWJpbGl0
eQpzZXQgaW4gdmFyaW91cyB3YXlzLgpGb3IgZXhhbXBsZSwgaXQgbWF5IGV4ZWN1dGUgYSBzZXQt
dXNlci1JRCBwcm9ncmFtIG9yIGFuCmV4ZWN1dGFibGUgd2l0aCBhc3NvY2lhdGVkIGZpbGUgY2Fw
YWJpbGl0aWVzLgpJbiBhZGRpdGlvbiwKYSBwcm9jZXNzIG1heSBnYWluIGNhcGFiaWxpdGllcyB2
aWEgdGhlIGVmZmVjdCBvZgouQlIgY2xvbmUgKDIpLAouQlIgdW5zaGFyZSAoMiksCm9yCi5CUiBz
ZXRucyAoMiksCmFzIGFscmVhZHkgZGVzY3JpYmVkLgouXCIgSW4gdGhlIDMuOCBzb3VyY2VzLCBz
ZWUgc2VjdXJpdHkvY29tbW9uY2FwLmM6OmNhcF9jYXBhYmxlKCk6Ci5JUCAyLgpJZiBhIHByb2Nl
c3MgaGFzIGEgY2FwYWJpbGl0eSBpbiBhIHVzZXIgbmFtZXNwYWNlLAp0aGVuIGl0IGhhcyB0aGF0
IGNhcGFiaWxpdHkgaW4gYWxsIGNoaWxkIChhbmQgZnVydGhlciByZW1vdmVkIGRlc2NlbmRhbnQp
Cm5hbWVzcGFjZXMgYXMgd2VsbC4KLklQIDMuCi5cIiAqIFRoZSBvd25lciBvZiB0aGUgdXNlciBu
YW1lc3BhY2UgaW4gdGhlIHBhcmVudCBvZiB0aGUKLlwiICogdXNlciBuYW1lc3BhY2UgaGFzIGFs
bCBjYXBzLgpXaGVuIGEgdXNlciBuYW1lc3BhY2UgaXMgY3JlYXRlZCwgdGhlIGtlcm5lbCByZWNv
cmRzIHRoZSBlZmZlY3RpdmUKdXNlciBJRCBvZiB0aGUgY3JlYXRpbmcgcHJvY2VzcyBhcyBiZWlu
ZyB0aGUgIm93bmVyIiBvZiB0aGUgbmFtZXNwYWNlLgouXCIgKGFuZCBsaWtld2lzZSBhc3NvY2lh
dGVzIHRoZSBlZmZlY3RpdmUgZ3JvdXAgSUQgb2YgdGhlIGNyZWF0aW5nIHByb2Nlc3MKLlwiIHdp
dGggdGhlIG5hbWVzcGFjZSkuCkEgcHJvY2VzcyB0aGF0IHJlc2lkZXMKaW4gdGhlIHBhcmVudCBv
ZiB0aGUgdXNlciBuYW1lc3BhY2UKLlwiIFNlZSBrZXJuZWwgY29tbWl0IDUyMGQ5ZWFiY2UxOGVk
ZmVmNzZhNjBiN2I4MzlkNTRmYWNhZmUxZjkgZm9yIGEgZml4Ci5cIiBvbiB0aGlzIHBvaW50CmFu
ZCB3aG9zZSBlZmZlY3RpdmUgdXNlciBJRCBtYXRjaGVzIHRoZSBvd25lciBvZiB0aGUgbmFtZXNw
YWNlCmhhcyBhbGwgY2FwYWJpbGl0aWVzIGluIHRoZSBuYW1lc3BhY2UuCi5cIiAgICAgVGhpcyBp
bmNsdWRlcyB0aGUgY2FzZSB3aGVyZSB0aGUgcHJvY2VzcyBleGVjdXRlcyBhIHNldC11c2VyLUlE
Ci5cIiAgICAgcHJvZ3JhbSB0aGF0IGNvbmZlcnMgdGhlIGVmZmVjdGl2ZSBVSUQgb2YgdGhlIGNy
ZWF0b3Igb2YgdGhlIG5hbWVzcGFjZS4KQnkgdmlydHVlIG9mIHRoZSBwcmV2aW91cyBydWxlLAp0
aGlzIG1lYW5zIHRoYXQgdGhlIHByb2Nlc3MgaGFzIGFsbCBjYXBhYmlsaXRpZXMgaW4gYWxsCmZ1
cnRoZXIgcmVtb3ZlZCBkZXNjZW5kYW50IHVzZXIgbmFtZXNwYWNlcyBhcyB3ZWxsLgouXCIKLlwi
ID09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PQouXCIKLlNTIEludGVyYWN0aW9uIG9mIHVzZXIgbmFtZXNwYWNlcyBhbmQgb3RoZXIgdHlw
ZXMgb2YgbmFtZXNwYWNlcwpTdGFydGluZyBpbiBMaW51eCAzLjgsIHVucHJpdmlsZWdlZCBwcm9j
ZXNzZXMgY2FuIGNyZWF0ZSB1c2VyIG5hbWVzcGFjZXMsCmFuZCBtb3VudCwgUElELCBJUEMsIG5l
dHdvcmssIGFuZCBVVFMgbmFtZXNwYWNlcyBjYW4gYmUgY3JlYXRlZCB3aXRoIGp1c3QgdGhlCi5C
IENBUF9TWVNfQURNSU4KY2FwYWJpbGl0eSBpbiB0aGUgY2FsbGVyJ3MgdXNlciBuYW1lc3BhY2Uu
CgpJZgouQlIgQ0xPTkVfTkVXVVNFUgppcyBzcGVjaWZpZWQgYWxvbmcgd2l0aCBvdGhlcgouQiBD
TE9ORV9ORVcqCmZsYWdzIGluIGEgc2luZ2xlCi5CUiBjbG9uZSAoMikKb3IKLkJSIHVuc2hhcmUg
KDIpCmNhbGwsIHRoZSB1c2VyIG5hbWVzcGFjZSBpcyBndWFyYW50ZWVkIHRvIGJlIGNyZWF0ZWQg
Zmlyc3QsCmdpdmluZyB0aGUgY2hpbGQKLlJCICggY2xvbmUgKDIpKQpvciBjYWxsZXIKLlJCICgg
dW5zaGFyZSAoMikpCnByaXZpbGVnZXMgb3ZlciB0aGUgcmVtYWluaW5nIG5hbWVzcGFjZXMgY3Jl
YXRlZCBieSB0aGUgY2FsbC4KVGh1cywgaXQgaXMgcG9zc2libGUgZm9yIGFuIHVucHJpdmlsZWdl
ZCBjYWxsZXIgdG8gc3BlY2lmeSB0aGlzIGNvbWJpbmF0aW9uCm9mIGZsYWdzLgoKV2hlbiBhIG5l
dyBJUEMsIG1vdW50LCBuZXR3b3JrLCBQSUQsIG9yIFVUUyBuYW1lc3BhY2UgaXMgY3JlYXRlZCB2
aWEKLkJSIGNsb25lICgyKQpvcgouQlIgdW5zaGFyZSAoMiksCnRoZSBrZXJuZWwgcmVjb3JkcyB0
aGUgdXNlciBuYW1lc3BhY2Ugb2YgdGhlIGNyZWF0aW5nIHByb2Nlc3MgYWdhaW5zdAp0aGUgbmV3
IG5hbWVzcGFjZS4KKFRoaXMgYXNzb2NpYXRpb24gY2FuJ3QgYmUgY2hhbmdlZC4pCldoZW4gYSBw
cm9jZXNzIGluIHRoZSBuZXcgbmFtZXNwYWNlIHN1YnNlcXVlbnRseSBwZXJmb3Jtcwpwcml2aWxl
Z2VkIG9wZXJhdGlvbnMgdGhhdCBvcGVyYXRlIG9uIGdsb2JhbApyZXNvdXJjZXMgaXNvbGF0ZWQg
YnkgdGhlIG5hbWVzcGFjZSwKdGhlIHBlcm1pc3Npb24gY2hlY2tzIGFyZSBwZXJmb3JtZWQgYWNj
b3JkaW5nIHRvIHRoZSBwcm9jZXNzJ3MgY2FwYWJpbGl0aWVzCmluIHRoZSB1c2VyIG5hbWVzcGFj
ZSB0aGF0IHRoZSBrZXJuZWwgYXNzb2NpYXRlZCB3aXRoIHRoZSBuZXcgbmFtZXNwYWNlLgouXCIK
LlwiID09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PQouXCIKLlNTIFVzZXIgYW5kIGdyb3VwIElEIG1hcHBpbmdzOiB1aWRfbWFwIGFuZCBn
aWRfbWFwCldoZW4gYSB1c2VyIG5hbWVzcGFjZSBpcyBjcmVhdGVkLAppdCBzdGFydHMgb3V0IHdp
dGhvdXQgYSBtYXBwaW5nIG9mIHVzZXIgSURzIChncm91cCBJRHMpCnRvIHRoZSBwYXJlbnQgdXNl
ciBuYW1lc3BhY2UuClRoZQouSVIgL3Byb2MvW3BpZF0vdWlkX21hcAphbmQKLklSIC9wcm9jL1tw
aWRdL2dpZF9tYXAKZmlsZXMgKGF2YWlsYWJsZSBzaW5jZSBMaW51eCAzLjUpCi5cIiBjb21taXQg
MjJkOTE3ZDgwZTg0MjgyOWQwY2EwYTU2MTk2N2Q3MjhlYjFkNjMwMwpleHBvc2UgdGhlIG1hcHBp
bmdzIGZvciB1c2VyIGFuZCBncm91cCBJRHMKaW5zaWRlIHRoZSB1c2VyIG5hbWVzcGFjZSBmb3Ig
dGhlIHByb2Nlc3MKLklSIHBpZCAuClRoZXNlIGZpbGVzIGNhbiBiZSByZWFkIHRvIHZpZXcgdGhl
IG1hcHBpbmdzIGluIGEgdXNlciBuYW1lc3BhY2UgYW5kCndyaXR0ZW4gdG8gKG9uY2UpIHRvIGRl
ZmluZSB0aGUgbWFwcGluZ3MuCgpUaGUgZGVzY3JpcHRpb24gaW4gdGhlIGZvbGxvd2luZyBwYXJh
Z3JhcGhzIGV4cGxhaW5zIHRoZSBkZXRhaWxzIGZvcgouSVIgdWlkX21hcCA7Ci5JUiBnaWRfbWFw
CmlzIGV4YWN0bHkgdGhlIHNhbWUsCmJ1dCBlYWNoIGluc3RhbmNlIG9mICJ1c2VyIElEIiBpcyBy
ZXBsYWNlZCBieSAiZ3JvdXAgSUQiLgoKVGhlCi5JIHVpZF9tYXAKZmlsZSBleHBvc2VzIHRoZSBt
YXBwaW5nIG9mIHVzZXIgSURzIGZyb20gdGhlIHVzZXIgbmFtZXNwYWNlCm9mIHRoZSBwcm9jZXNz
Ci5JUiBwaWQKdG8gdGhlIHVzZXIgbmFtZXNwYWNlIG9mIHRoZSBwcm9jZXNzIHRoYXQgb3BlbmVk
Ci5JUiB1aWRfbWFwCihidXQgc2VlIGEgcXVhbGlmaWNhdGlvbiB0byB0aGlzIHBvaW50IGJlbG93
KS4KSW4gb3RoZXIgd29yZHMsIHByb2Nlc3NlcyB0aGF0IGFyZSBpbiBkaWZmZXJlbnQgdXNlciBu
YW1lc3BhY2VzCndpbGwgcG90ZW50aWFsbHkgc2VlIGRpZmZlcmVudCB2YWx1ZXMgd2hlbiByZWFk
aW5nIGZyb20gYSBwYXJ0aWN1bGFyCi5JIHVpZF9tYXAKZmlsZSwgZGVwZW5kaW5nIG9uIHRoZSB1
c2VyIElEIG1hcHBpbmdzIGZvciB0aGUgdXNlciBuYW1lc3BhY2VzCm9mIHRoZSByZWFkaW5nIHBy
b2Nlc3Nlcy4KCkVhY2ggbGluZSBpbiB0aGUKLkkgdWlkX21hcApmaWxlIHNwZWNpZmllcyBhIDEt
dG8tMSBtYXBwaW5nIG9mIGEgcmFuZ2Ugb2YgY29udGlndW91cwp1c2VyIElEcyBiZXR3ZWVuIHR3
byB1c2VyIG5hbWVzcGFjZXMuCihXaGVuIGEgdXNlciBuYW1lc3BhY2UgaXMgZmlyc3QgY3JlYXRl
ZCwgdGhpcyBmaWxlIGlzIGVtcHR5LikKVGhlIHNwZWNpZmljYXRpb24gaW4gZWFjaCBsaW5lIHRh
a2VzIHRoZSBmb3JtIG9mCnRocmVlIG51bWJlcnMgZGVsaW1pdGVkIGJ5IHdoaXRlIHNwYWNlLgpU
aGUgZmlyc3QgdHdvIG51bWJlcnMgc3BlY2lmeSB0aGUgc3RhcnRpbmcgdXNlciBJRCBpbgplYWNo
IG9mIHRoZSB0d28gdXNlciBuYW1lc3BhY2VzLgpUaGUgdGhpcmQgbnVtYmVyIHNwZWNpZmllcyB0
aGUgbGVuZ3RoIG9mIHRoZSBtYXBwZWQgcmFuZ2UuCkluIGRldGFpbCwgdGhlIGZpZWxkcyBhcmUg
aW50ZXJwcmV0ZWQgYXMgZm9sbG93czoKLklQICgxKSA0ClRoZSBzdGFydCBvZiB0aGUgcmFuZ2Ug
b2YgdXNlciBJRHMgaW4KdGhlIHVzZXIgbmFtZXNwYWNlIG9mIHRoZSBwcm9jZXNzCi5JUiBwaWQg
LgouSVAgKDIpClRoZSBzdGFydCBvZiB0aGUgcmFuZ2Ugb2YgdXNlcgpJRHMgdG8gd2hpY2ggdGhl
IHVzZXIgSURzIHNwZWNpZmllZCBieSBmaWVsZCBvbmUgbWFwLgpIb3cgZmllbGQgdHdvIGlzIGlu
dGVycHJldGVkIGRlcGVuZHMgb24gd2hldGhlciB0aGUgcHJvY2VzcyB0aGF0IG9wZW5lZAouSSB1
aWRfbWFwCmFuZCB0aGUgcHJvY2VzcwouSVIgcGlkCmFyZSBpbiB0aGUgc2FtZSB1c2VyIG5hbWVz
cGFjZSwgYXMgZm9sbG93czoKLlJTCi5JUCBhKSAzCklmIHRoZSB0d28gcHJvY2Vzc2VzIGFyZSBp
biBkaWZmZXJlbnQgdXNlciBuYW1lc3BhY2VzOgpmaWVsZCB0d28gaXMgdGhlIHN0YXJ0IG9mIGEg
cmFuZ2Ugb2YKdXNlciBJRHMgaW4gdGhlIHVzZXIgbmFtZXNwYWNlIG9mIHRoZSBwcm9jZXNzIHRo
YXQgb3BlbmVkCi5JUiB1aWRfbWFwIC4KLklQIGIpCklmIHRoZSB0d28gcHJvY2Vzc2VzIGFyZSBp
biB0aGUgc2FtZSB1c2VyIG5hbWVzcGFjZToKZmllbGQgdHdvIGlzIHRoZSBzdGFydCBvZiB0aGUg
cmFuZ2Ugb2YKdXNlciBJRHMgaW4gdGhlIHBhcmVudCB1c2VyIG5hbWVzcGFjZSBvZiB0aGUgcHJv
Y2VzcwouSVIgcGlkIC4KVGhpcyBjYXNlIGVuYWJsZXMgdGhlIG9wZW5lciBvZgouSSB1aWRfbWFw
Cih0aGUgY29tbW9uIGNhc2UgaGVyZSBpcyBvcGVuaW5nCi5JUiAvcHJvYy9zZWxmL3VpZF9tYXAg
KQp0byBzZWUgdGhlIG1hcHBpbmcgb2YgdXNlciBJRHMgaW50byB0aGUgdXNlciBuYW1lc3BhY2Ug
b2YgdGhlIHByb2Nlc3MKdGhhdCBjcmVhdGVkIHRoaXMgdXNlciBuYW1lc3BhY2UuCi5SRQouSVAg
KDMpClRoZSBsZW5ndGggb2YgdGhlIHJhbmdlIG9mIHVzZXIgSURzIHRoYXQgaXMgbWFwcGVkIGJl
dHdlZW4gdGhlIHR3bwp1c2VyIG5hbWVzcGFjZXMuCi5QUApTeXN0ZW0gY2FsbHMgdGhhdCByZXR1
cm4gdXNlciBJRHMgKGdyb3VwIElEcylcKGVtZm9yIGV4YW1wbGUsCi5CUiBnZXR1aWQgKDIpLAou
QlIgZ2V0Z2lkICgyKSwKYW5kIHRoZSBjcmVkZW50aWFsIGZpZWxkcyBpbiB0aGUgc3RydWN0dXJl
IHJldHVybmVkIGJ5Ci5CUiBzdGF0ICgyKVwoZW1yZXR1cm4KdGhlIHVzZXIgSUQgKGdyb3VwIElE
KSBtYXBwZWQgaW50byB0aGUgY2FsbGVyJ3MgdXNlciBuYW1lc3BhY2UuCgpXaGVuIGEgcHJvY2Vz
cyBhY2Nlc3NlcyBhIGZpbGUsIGl0cyB1c2VyIGFuZCBncm91cCBJRHMKYXJlIG1hcHBlZCBpbnRv
IHRoZSBpbml0aWFsIHVzZXIgbmFtZXNwYWNlIGZvciB0aGUgcHVycG9zZSBvZiBwZXJtaXNzaW9u
CmNoZWNraW5nIGFuZCBhc3NpZ25pbmcgSURzIHdoZW4gY3JlYXRpbmcgYSBmaWxlLgpXaGVuIGEg
cHJvY2VzcyByZXRyaWV2ZXMgZmlsZSB1c2VyIGFuZCBncm91cCBJRHMgdmlhCi5CUiBzdGF0ICgy
KSwKdGhlIElEcyBhcmUgbWFwcGVkIGluIHRoZSBvcHBvc2l0ZSBkaXJlY3Rpb24sCnRvIHByb2R1
Y2UgdmFsdWVzIHJlbGF0aXZlIHRvIHRoZSBwcm9jZXNzIHVzZXIgYW5kIGdyb3VwIElEIG1hcHBp
bmdzLgoKVGhlIGluaXRpYWwgdXNlciBuYW1lc3BhY2UgaGFzIG5vIHBhcmVudCBuYW1lc3BhY2Us
CmJ1dCwgZm9yIGNvbnNpc3RlbmN5LCB0aGUga2VybmVsIHByb3ZpZGVzIGR1bW15IHVzZXIgYW5k
IGdyb3VwCklEIG1hcHBpbmcgZmlsZXMgZm9yIHRoaXMgbmFtZXNwYWNlLgpMb29raW5nIGF0IHRo
ZQouSSB1aWRfbWFwCmZpbGUKLlJJICggZ2lkX21hcAppcyB0aGUgc2FtZSkgZnJvbSBhIHNoZWxs
IGluIHRoZSBpbml0aWFsIG5hbWVzcGFjZSBzaG93czoKCi5pbiArNG4KLm5mCiQgXGZCY2F0IC9w
cm9jLyQkL3VpZF9tYXBcZlAKICAgICAgICAgMCAgICAgICAgICAwIDQyOTQ5NjcyOTUKLmZpCi5p
bgoKVGhpcyBtYXBwaW5nIHRlbGxzIHVzCnRoYXQgdGhlIHJhbmdlIHN0YXJ0aW5nIGF0IHVzZXIg
SUQgMCBpbiB0aGlzIG5hbWVzcGFjZQptYXBzIHRvIGEgcmFuZ2Ugc3RhcnRpbmcgYXQgMCBpbiB0
aGUgKG5vbmV4aXN0ZW50KSBwYXJlbnQgbmFtZXNwYWNlLAphbmQgdGhlIGxlbmd0aCBvZiB0aGUg
cmFuZ2UgaXMgdGhlIGxhcmdlc3QgMzItYml0IHVuc2lnbmVkIGludGVnZXIuCi5cIgouXCIgPT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
Ci5cIgouU1MgRGVmaW5pbmcgdXNlciBhbmQgZ3JvdXAgSUQgbWFwcGluZ3M6IHdyaXRpbmcgdG8g
dWlkX21hcCBhbmQgZ2lkX21hcAouUFAKQWZ0ZXIgdGhlIGNyZWF0aW9uIG9mIGEgbmV3IHVzZXIg
bmFtZXNwYWNlLCB0aGUKLkkgdWlkX21hcApmaWxlIG9mCi5JIG9uZQpvZiB0aGUgcHJvY2Vzc2Vz
IGluIHRoZSBuYW1lc3BhY2UgbWF5IGJlIHdyaXR0ZW4gdG8KLkkgb25jZQp0byBkZWZpbmUgdGhl
IG1hcHBpbmcgb2YgdXNlciBJRHMgaW4gdGhlIG5ldyB1c2VyIG5hbWVzcGFjZS4KQW4gYXR0ZW1w
dCB0byB3cml0ZSBtb3JlIHRoYW4gb25jZSB0byBhCi5JIHVpZF9tYXAKZmlsZSBpbiBhIHVzZXIg
bmFtZXNwYWNlIGZhaWxzIHdpdGggdGhlIGVycm9yCi5CUiBFUEVSTSAuClNpbWlsYXIgcnVsZXMg
YXBwbHkgZm9yCi5JIGdpZF9tYXAKZmlsZXMuCgpUaGUgbGluZXMgd3JpdHRlbiB0bwouSVIgdWlk
X21hcAouUkkgKCBnaWRfbWFwICkKbXVzdCBjb25mb3JtIHRvIHRoZSBmb2xsb3dpbmcgcnVsZXM6
Ci5JUCAqIDMKVGhlIHRocmVlIGZpZWxkcyBtdXN0IGJlIHZhbGlkIG51bWJlcnMsCmFuZCB0aGUg
bGFzdCBmaWVsZCBtdXN0IGJlIGdyZWF0ZXIgdGhhbiAwLgouSVAgKgpMaW5lcyBhcmUgdGVybWlu
YXRlZCBieSBuZXdsaW5lIGNoYXJhY3RlcnMuCi5JUCAqClRoZXJlIGlzIGFuIChhcmJpdHJhcnkp
IGxpbWl0IG9uIHRoZSBudW1iZXIgb2YgbGluZXMgaW4gdGhlIGZpbGUuCkFzIGF0IExpbnV4IDMu
OCwgdGhlIGxpbWl0IGlzIGZpdmUgbGluZXMuCkluIGFkZGl0aW9uLCB0aGUgbnVtYmVyIG9mIGJ5
dGVzIHdyaXR0ZW4gdG8KdGhlIGZpbGUgbXVzdCBiZSBsZXNzIHRoYW4gdGhlIHN5c3RlbSBwYWdl
IHNpemUsCi5cIiBGSVhNRShFcmljKTogdGhlIHJlc3RyaWN0aW9uICJsZXNzIHRoYW4iIHJhdGhl
ciB0aGFuICJsZXNzIHRoYW4gb3IgZXF1YWwiCi5cIiBzZWVtcyBzdHJhbmdlbHkgYXJiaXRyYXJ5
LiBGdXJ0aGVybW9yZSwgdGhlIGNvbW1lbnQgZG9lcyBub3QgYWdyZWUKLlwiIHdpdGggdGhlIGNv
ZGUgaW4ga2VybmVsL3VzZXJfbmFtZXNwYWNlLmMuIFdoaWNoIGlzIGNvcnJlY3QuCmFuZCB0aGUg
d3JpdGUgbXVzdCBiZSBwZXJmb3JtZWQgYXQgdGhlIHN0YXJ0IG9mIHRoZSBmaWxlIChpLmUuLAou
QlIgbHNlZWsgKDIpCmFuZAouQlIgcHdyaXRlICgyKQpjYW4ndCBiZSB1c2VkIHRvIHdyaXRlIHRv
IG5vbnplcm8gb2Zmc2V0cyBpbiB0aGUgZmlsZSkuCi5JUCAqClRoZSByYW5nZSBvZiB1c2VyIElE
cyAoZ3JvdXAgSURzKQpzcGVjaWZpZWQgaW4gZWFjaCBsaW5lIGNhbm5vdCBvdmVybGFwIHdpdGgg
dGhlIHJhbmdlcwppbiBhbnkgb3RoZXIgbGluZXMuCkluIHRoZSBpbml0aWFsIGltcGxlbWVudGF0
aW9uIChMaW51eCAzLjgpLCB0aGlzIHJlcXVpcmVtZW50IHdhcwpzYXRpc2ZpZWQgYnkgYSBzaW1w
bGlzdGljIGltcGxlbWVudGF0aW9uIHRoYXQgaW1wb3NlZCB0aGUgZnVydGhlcgpyZXF1aXJlbWVu
dCB0aGF0CnRoZSB2YWx1ZXMgaW4gYm90aCBmaWVsZCAxIGFuZCBmaWVsZCAyIG9mIHN1Y2Nlc3Np
dmUgbGluZXMgbXVzdCBiZQppbiBhc2NlbmRpbmcgbnVtZXJpY2FsIG9yZGVyLAp3aGljaCBwcmV2
ZW50ZWQgc29tZSBvdGhlcndpc2UgdmFsaWQgbWFwcyBmcm9tIGJlaW5nIGNyZWF0ZWQuCkxpbnV4
IDMuOSBhbmQgbGF0ZXIKLlwiIGNvbW1pdCAwYmQxNGI0ZmQ3MmFmZDVkZjQxZTlmZDU5ZjM1Njc0
MGYyMmZjZWJhCmZpeCB0aGlzIGxpbWl0YXRpb24sIGFsbG93aW5nIGFueSB2YWxpZCBzZXQgb2Yg
bm9ub3ZlcmxhcHBpbmcgbWFwcy4KLklQICoKQXQgbGVhc3Qgb25lIGxpbmUgbXVzdCBiZSB3cml0
dGVuIHRvIHRoZSBmaWxlLgouUFAKV3JpdGVzIHRoYXQgdmlvbGF0ZSB0aGUgYWJvdmUgcnVsZXMg
ZmFpbCB3aXRoIHRoZSBlcnJvcgouQlIgRUlOVkFMIC4KCkluIG9yZGVyIGZvciBhIHByb2Nlc3Mg
dG8gd3JpdGUgdG8gdGhlCi5JIC9wcm9jL1twaWRdL3VpZF9tYXAKLlJJICggL3Byb2MvW3BpZF0v
Z2lkX21hcCApCmZpbGUsIGFsbCBvZiB0aGUgZm9sbG93aW5nIHJlcXVpcmVtZW50cyBtdXN0IGJl
IG1ldDoKLklQIDEuIDMKVGhlIHdyaXRpbmcgcHJvY2VzcyBtdXN0IGhhdmUgdGhlCi5CUiBDQVBf
U0VUVUlECi5SQiAoIENBUF9TRVRHSUQgKQpjYXBhYmlsaXR5IGluIHRoZSB1c2VyIG5hbWVzcGFj
ZSBvZiB0aGUgcHJvY2VzcwouSVIgcGlkIC4KLklQIDIuClRoZSB3cml0aW5nIHByb2Nlc3MgbXVz
dCBiZSBpbiBlaXRoZXIgdGhlIHVzZXIgbmFtZXNwYWNlIG9mIHRoZSBwcm9jZXNzCi5JIHBpZApv
ciBpbnNpZGUgdGhlIHBhcmVudCB1c2VyIG5hbWVzcGFjZSBvZiB0aGUgcHJvY2VzcwouSVIgcGlk
IC4KLklQIDMuClRoZSBtYXBwZWQgdXNlciBJRHMgKGdyb3VwIElEcykgbXVzdCBpbiB0dXJuIGhh
dmUgYSBtYXBwaW5nCmluIHRoZSBwYXJlbnQgdXNlciBuYW1lc3BhY2UuCi5JUCA0LgpPbmUgb2Yg
dGhlIGZvbGxvd2luZyBpcyB0cnVlOgouUlMKLklQICogMwpUaGUgZGF0YSB3cml0dGVuIHRvCi5J
IHVpZF9tYXAKLlJJICggZ2lkX21hcCApCmNvbnNpc3RzIG9mIGEgc2luZ2xlIGxpbmUgdGhhdCBt
YXBzIHRoZSB3cml0aW5nIHByb2Nlc3MncyBmaWxlIHN5c3RlbSB1c2VyIElECihncm91cCBJRCkg
aW4gdGhlIHBhcmVudCB1c2VyIG5hbWVzcGFjZSB0byBhIHVzZXIgSUQgKGdyb3VwIElEKQppbiB0
aGUgdXNlciBuYW1lc3BhY2UuClRoZSB1c3VhbCBjYXNlIGhlcmUgaXMgdGhhdCB0aGlzIHNpbmds
ZSBsaW5lIHByb3ZpZGVzIGEgbWFwcGluZyBmb3IgdXNlciBJRApvZiB0aGUgcHJvY2VzcyB0aGF0
IGNyZWF0ZWQgdGhlIG5hbWVzcGFjZS4KLklQICogMwpUaGUgcHJvY2VzcyBoYXMgdGhlCi5CUiBD
QVBfU0VUVUlECi5SQiAoIENBUF9TRVRHSUQgKQpjYXBhYmlsaXR5IGluIHRoZSBwYXJlbnQgdXNl
ciBuYW1lc3BhY2UuClRodXMsIGEgcHJpdmlsZWdlZCBwcm9jZXNzIGNhbiBtYWtlIG1hcHBpbmdz
IHRvIGFyYml0cmFyeSB1c2VyIElEcyAoZ3JvdXAgSURzKQppbiB0aGUgcGFyZW50IHVzZXIgbmFt
ZXNwYWNlLgouUkUKLlBQCldyaXRlcyB0aGF0IHZpb2xhdGUgdGhlIGFib3ZlIHJ1bGVzIGZhaWwg
d2l0aCB0aGUgZXJyb3IKLkJSIEVQRVJNIC4KLlwiCi5cIiA9PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0KLlwiCi5TUyBVbm1hcHBlZCB1
c2VyIGFuZCBncm91cCBJRHMKLlBQClRoZXJlIGFyZSB2YXJpb3VzIHBsYWNlcyB3aGVyZSBhbiB1
bm1hcHBlZCB1c2VyIElEIChncm91cCBJRCkKbWF5IGJlIGV4cG9zZWQgdG8gdXNlciBzcGFjZS4K
Rm9yIGV4YW1wbGUsIHRoZSBmaXJzdCBwcm9jZXNzIGluIGEgbmV3IHVzZXIgbmFtZXNwYWNlIG1h
eSBjYWxsCi5CUiBnZXR1aWQgKCkKYmVmb3JlIGEgdXNlciBJRCBtYXBwaW5nIGhhcyBiZWVuIGRl
ZmluZWQgZm9yIHRoZSBuYW1lc3BhY2UuCkluIG1vc3Qgc3VjaCBjYXNlcywgYW4gdW5tYXBwZWQg
dXNlciBJRCBpcyBjb252ZXJ0ZWQKLlwiIGZyb21fa3VpZF9tdW5nZWQoKSwgZnJvbV9rZ2lkX211
bmdlZCgpCnRvIHRoZSBvdmVyZmxvdyB1c2VyIElEIChncm91cCBJRCk7CnRoZSBkZWZhdWx0IHZh
bHVlIGZvciB0aGUgb3ZlcmZsb3cgdXNlciBJRCAoZ3JvdXAgSUQpIGlzIDY1NTM0LgpTZWUgdGhl
IGRlc2NyaXB0aW9ucyBvZgouSVIgL3Byb2Mvc3lzL2tlcm5lbC9vdmVyZmxvd3VpZAphbmQKLklS
IC9wcm9jL3N5cy9rZXJuZWwvb3ZlcmZsb3dnaWQKaW4KLkJSIHByb2MgKDUpLgoKVGhlIGNhc2Vz
IHdoZXJlIHVubWFwcGVkIElEcyBhcmUgbWFwcGVkIGluIHRoaXMgZmFzaGlvbiBpbmNsdWRlCnN5
c3RlbSBjYWxscyB0aGF0IHJldHVybiB1c2VyIElEcwouUkIgKCBnZXR1aWQgKDIpCi5CUiBnZXRn
aWQgKDIpLAphbmQgc2ltaWxhciksCmNyZWRlbnRpYWxzIHBhc3NlZCBvdmVyIGEgVU5JWCBkb21h
aW4gc29ja2V0LAouXCIgYWxzbyBTT19QRUVSQ1JFRApjcmVkZW50aWFscyByZXR1cm5lZCBieQou
QlIgc3RhdCAoMiksCi5CUiB3YWl0aWQgKDIpLAphbmQgdGhlIFN5c3RlbSBWIElQQyAiY3RsIgou
QiBJUENfU1RBVApvcGVyYXRpb25zLApjcmVkZW50aWFscyBleHBvc2VkIGJ5Ci5JUiAvcHJvYy9Q
SUQvc3RhdHVzIAphbmQgdGhlIGZpbGVzIGluCi5JUiAvcHJvYy9zeXN2aXBjLyogLApjcmVkZW50
aWFscyByZXR1cm5lZCB2aWEgdGhlCi5JIHNpX3VpZApmaWVsZCBpbiB0aGUKLkkgc2lnaW5mb190
CnJlY2VpdmVkIHdpdGggYSBzaWduYWwgKHNlZQouQlIgc2lnYWN0aW9uICgyKSksCmNyZWRlbnRp
YWxzIHdyaXR0ZW4gdG8gdGhlIHByb2Nlc3MgYWNjb3VudGluZyBmaWxlIChzZWUKLkJSIGFjY3Qg
KDUpKSwKYW5kIGNyZWRlbnRpYWxzIHJldHVybmVkIHdpdGggUE9TSVggbWVzc2FnZSBxdWV1ZSBu
b3RpZmljYXRpb25zIChzZWUKLkJSIG1xX25vdGlmeSAoMykpLgoKVGhlcmUgaXMgb25lIG5vdGFi
bGUgY2FzZSB3aGVyZSB1bm1hcHBlZCB1c2VyIGFuZCBncm91cCBJRHMgYXJlCi5JIG5vdAouXCIg
ZnJvbV9rdWlkKCksIGZyb21fa2dpZCgpCi5cIiBBbHNvIEZfR0VUT1dORVJfVUlEUyBpcyBhbiBl
eGNlcHRpb24KY29udmVydGVkIHRvIHRoZSBjb3JyZXNwb25kaW5nIG92ZXJmbG93IElEIHZhbHVl
LgpXaGVuIHZpZXdpbmcgYQouSSB1aWRfbWFwCm9yCi5JIGdpZF9tYXAKZmlsZSBpbiB3aGljaCB0
aGVyZSBpcyBubyBtYXBwaW5nIGZvciB0aGUgc2Vjb25kIGZpZWxkLAp0aGF0IGZpZWxkIGlzIGRp
c3BsYXllZCBhcyA0Mjk0OTY3Mjk1IChcLTEgYXMgYW4gdW5zaWduZWQgaW50ZWdlcik7Ci5cIgou
XCIgPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09Ci5cIgouU1MgU2V0LXVzZXItSUQgYW5kIHNldC1ncm91cC1JRCBwcm9ncmFtcwouUFAK
V2hlbiBhIHByb2Nlc3MgaW5zaWRlIGEgdXNlciBuYW1lc3BhY2UgZXhlY3V0ZXMKYSBzZXQtdXNl
ci1JRCAoc2V0LWdyb3VwLUlEKSBwcm9ncmFtLAp0aGUgcHJvY2VzcydzIGVmZmVjdGl2ZSB1c2Vy
IChncm91cCkgSUQgaW5zaWRlIHRoZSBuYW1lc3BhY2UgaXMgY2hhbmdlZAp0byB3aGF0ZXZlciB2
YWx1ZSBpcyBtYXBwZWQgZm9yIHRoZSB1c2VyIChncm91cCkgSUQgb2YgdGhlIGZpbGUuCkhvd2V2
ZXIsIGlmIGVpdGhlciB0aGUgdXNlcgouSSBvcgp0aGUgZ3JvdXAgSUQgb2YgdGhlIGZpbGUgaGFz
IG5vIG1hcHBpbmcgaW5zaWRlIHRoZSBuYW1lc3BhY2UsCnRoZSBzZXQtdXNlci1JRCAoc2V0LWdy
b3VwLUlEKSBiaXQgaXMgc2lsZW50bHkgaWdub3JlZDoKdGhlIG5ldyBwcm9ncmFtIGlzIGV4ZWN1
dGVkLApidXQgdGhlIHByb2Nlc3MncyBlZmZlY3RpdmUgdXNlciAoZ3JvdXApIElEIGlzIGxlZnQg
dW5jaGFuZ2VkLgooVGhpcyBtaXJyb3JzIHRoZSBzZW1hbnRpY3Mgb2YgZXhlY3V0aW5nIGEgc2V0
LXVzZXItSUQgb3Igc2V0LWdyb3VwLUlECnByb2dyYW0gdGhhdCByZXNpZGVzIG9uIGEgZmlsZSBz
eXN0ZW0gdGhhdCB3YXMgbW91bnRlZCB3aXRoIHRoZQouQlIgTVNfTk9TVUlECmZsYWcsIGFzIGRl
c2NyaWJlZCBpbgouQlIgbW91bnQgKDIpLikKLlwiCi5cIiA9PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT0KLlwiCi5TUyBNaXNjZWxsYW5l
b3VzCi5QUApXaGVuIGEgcHJvY2VzcydzIHVzZXIgYW5kIGdyb3VwIElEcyBhcmUgcGFzc2VkIG92
ZXIgYSBVTklYIGRvbWFpbiBzb2NrZXQKdG8gYSBwcm9jZXNzIGluIGEgZGlmZmVyZW50IHVzZXIg
bmFtZXNwYWNlIChzZWUgdGhlIGRlc2NyaXB0aW9uIG9mCi5CIFNDTV9DUkVERU5USUFMUwppbgou
QlIgdW5peCAoNykpLAp0aGV5IGFyZSB0cmFuc2xhdGVkIGludG8gdGhlIGNvcnJlc3BvbmRpbmcg
dmFsdWVzIGFzIHBlciB0aGUKcmVjZWl2aW5nIHByb2Nlc3MncyB1c2VyIGFuZCBncm91cCBJRCBt
YXBwaW5ncy4KCi5TSCBDT05GT1JNSU5HIFRPCk5hbWVzcGFjZXMgYXJlIGEgTGludXgtc3BlY2lm
aWMgZmVhdHVyZS4KLlNIIE5PVEVTCk92ZXIgdGhlIHllYXJzLCB0aGVyZSBoYXZlIGJlZW4gYSBs
b3Qgb2YgZmVhdHVyZXMgdGhhdCBoYXZlIGJlZW4gYWRkZWQKdG8gdGhlIExpbnV4IGtlcm5lbCB0
aGF0IGhhdmUgYmVlbiBtYWRlIGF2YWlsYWJsZSBvbmx5IHRvIHByaXZpbGVnZWQgdXNlcnMKYmVj
YXVzZSBvZiB0aGVpciBwb3RlbnRpYWwgdG8gY29uZnVzZSBzZXQtdXNlci1JRC1yb290IGFwcGxp
Y2F0aW9ucy4KSW4gZ2VuZXJhbCwgaXQgYmVjb21lcyBzYWZlIHRvIGFsbG93IHRoZSByb290IHVz
ZXIgaW4gYSB1c2VyIG5hbWVzcGFjZSB0bwp1c2UgdGhvc2UgZmVhdHVyZXMgYmVjYXVzZSBpdCBp
cyBpbXBvc3NpYmxlLCB3aGlsZSBpbiBhIHVzZXIgbmFtZXNwYWNlLAp0byBnYWluIG1vcmUgcHJp
dmlsZWdlIHRoYW4gdGhlIHJvb3QgdXNlciBvZiBhIHVzZXIgbmFtZXNwYWNlIGhhcy4KLlNIIEVY
QU1QTEUKVGhlIHByb2dyYW0gYmVsb3cgaXMgZGVzaWduZWQgdG8gYWxsb3cgZXhwZXJpbWVudGlu
ZyB3aXRoCnVzZXIgbmFtZXNwYWNlcywgYXMgd2VsbCBhcyBvdGhlciB0eXBlcyBvZiBuYW1lc3Bh
Y2VzLgpJdCBjcmVhdGVzIG5hbWVzcGFjZXMgYXMgc3BlY2lmaWVkIGJ5IGNvbW1hbmQtbGluZSBv
cHRpb25zIGFuZCB0aGVuIGV4ZWN1dGVzCmEgY29tbWFuZCBpbnNpZGUgdGhvc2UgbmFtZXNwYWNl
cy4KVGhlIGNvbW1lbnRzIGFuZAouSSB1c2FnZSgpCmZ1bmN0aW9uIGluc2lkZSB0aGUgcHJvZ3Jh
bSBwcm92aWRlIGEgZnVsbCBleHBsYW5hdGlvbiBvZiB0aGUgcHJvZ3JhbS4KVGhlIGZvbGxvd2lu
ZyBzaGVsbCBzZXNzaW9uIGRlbW9uc3RyYXRlcyBpdHMgdXNlLgoKRmlyc3QsIHdlIGxvb2sgYXQg
dGhlIHJ1bi10aW1lIGVudmlyb25tZW50OgoKLmluICs0bgoubmYKJCBcZkJ1bmFtZSAtcnNcZlAg
ICAgICMgTmVlZCBMaW51eCAzLjggb3IgbGF0ZXIKTGludXggMy44LjAKJCBcZkJpZCAtdVxmUCAg
ICAgICAgICMgUnVubmluZyBhcyB1bnByaXZpbGVnZWQgdXNlcgoxMDAwCiQgXGZCaWQgLWdcZlAK
MTAwMAouZmkKLmluCgpOb3cgc3RhcnQgYSBuZXcgc2hlbGwgaW4gbmV3IHVzZXIKLlJJICggXC1V
ICksCm1vdW50Ci5SSSAoIFwtbSApLAphbmQgUElECi5SSSAoIFwtcCApCm5hbWVzcGFjZXMsIHdp
dGggdXNlciBJRAouUkkgKCBcLU0gKQphbmQgZ3JvdXAgSUQKLlJJICggXC1HICkKMTAwMCBtYXBw
ZWQgdG8gMCBpbnNpZGUgdGhlIHVzZXIgbmFtZXNwYWNlOgoKLmluICs0bgoubmYKJCBcZkIuL3Vz
ZXJuc19jaGlsZF9leGVjIC1wIC1tIC1VIC1NICcwIDEwMDAgMScgLUcgJzAgMTAwMCAxJyBiYXNo
XGZQCi5maQouaW4KClRoZSBzaGVsbCBoYXMgUElEIDEsIGJlY2F1c2UgaXQgaXMgdGhlIGZpcnN0
IHByb2Nlc3MgaW4gdGhlIG5ldyAKUElEIG5hbWVzcGFjZToKCi5pbiArNG4KLm5mCmJhc2gkIFxm
QmVjaG8gJCRcZlAKMQouZmkKLmluCgpJbnNpZGUgdGhlIHVzZXIgbmFtZXNwYWNlLCB0aGUgc2hl
bGwgaGFzIHVzZXIgYW5kIGdyb3VwIElEIDAsCmFuZCBhIGZ1bGwgc2V0IG9mIHBlcm1pdHRlZCBh
bmQgZWZmZWN0aXZlIGNhcGFiaWxpdGllczoKCi5pbiArNG4KLm5mCmJhc2gkIFxmQmNhdCAvcHJv
Yy8kJC9zdGF0dXMgfCBlZ3JlcCAnXltVR11pZCdcZlAKVWlkOgkwCTAJMAkwCkdpZDoJMAkwCTAJ
MApiYXNoJCBcZkJjYXQgL3Byb2MvJCQvc3RhdHVzIHwgZWdyZXAgJ15DYXAoUHJtfEluaHxFZmYp
J1xmUApDYXBJbmg6CTAwMDAwMDAwMDAwMDAwMDAKQ2FwUHJtOgkwMDAwMDAxZmZmZmZmZmZmCkNh
cEVmZjoJMDAwMDAwMWZmZmZmZmZmZgouZmkKLmluCgpNb3VudGluZyBhIG5ldwouSSAvcHJvYwpm
aWxlIHN5c3RlbSBhbmQgbGlzdGluZyBhbGwgb2YgdGhlIHByb2Nlc3NlcyB2aXNpYmxlCmluIHRo
ZSBuZXcgUElEIG5hbWVzcGFjZSBzaG93cyB0aGF0IHRoZSBzaGVsbCBjYW4ndCBzZWUKYW55IHBy
b2Nlc3NlcyBvdXRzaWRlIHRoZSBQSUQgbmFtZXNwYWNlOgoKLmluICs0bgoubmYKYmFzaCQgXGZC
bW91bnQgLXQgcHJvYyBwcm9jIC9wcm9jXGZQCmJhc2gkIFxmQnBzIGF4XGZQCiAgUElEIFRUWSAg
ICAgIFNUQVQgICBUSU1FIENPTU1BTkQKICAgIDEgcHRzLzMgICAgUyAgICAgIDA6MDAgYmFzaAog
ICAyMiBwdHMvMyAgICBSKyAgICAgMDowMCBwcyBheAouZmkKLmluCi5TUyBQcm9ncmFtIHNvdXJj
ZQpcJgoubmYKLyogdXNlcm5zX2NoaWxkX2V4ZWMuYwoKICAgTGljZW5zZWQgdW5kZXIgR05VIEdl
bmVyYWwgUHVibGljIExpY2Vuc2UgdjIgb3IgbGF0ZXIKCiAgIENyZWF0ZSBhIGNoaWxkIHByb2Nl
c3MgdGhhdCBleGVjdXRlcyBhIHNoZWxsIGNvbW1hbmQgaW4gbmV3CiAgIG5hbWVzcGFjZShzKTsg
YWxsb3cgVUlEIGFuZCBHSUQgbWFwcGluZ3MgdG8gYmUgc3BlY2lmaWVkIHdoZW4KICAgY3JlYXRp
bmcgYSB1c2VyIG5hbWVzcGFjZS4KKi8KI2RlZmluZSBfR05VX1NPVVJDRQojaW5jbHVkZSA8c2No
ZWQuaD4KI2luY2x1ZGUgPHVuaXN0ZC5oPgojaW5jbHVkZSA8c3RkbGliLmg+CiNpbmNsdWRlIDxz
eXMvd2FpdC5oPgojaW5jbHVkZSA8c2lnbmFsLmg+CiNpbmNsdWRlIDxmY250bC5oPgojaW5jbHVk
ZSA8c3RkaW8uaD4KI2luY2x1ZGUgPHN0cmluZy5oPgojaW5jbHVkZSA8bGltaXRzLmg+CiNpbmNs
dWRlIDxlcnJuby5oPgoKLyogQSBzaW1wbGUgZXJyb3JcLWhhbmRsaW5nIGZ1bmN0aW9uOiBwcmlu
dCBhbiBlcnJvciBtZXNzYWdlIGJhc2VkCiAgIG9uIHRoZSB2YWx1ZSBpbiBcKGFxZXJybm9cKGFx
IGFuZCB0ZXJtaW5hdGUgdGhlIGNhbGxpbmcgcHJvY2VzcyAqLwoKI2RlZmluZSBlcnJFeGl0KG1z
ZykgICAgZG8geyBwZXJyb3IobXNnKTsgZXhpdChFWElUX0ZBSUxVUkUpOyBcXAogICAgICAgICAg
ICAgICAgICAgICAgICB9IHdoaWxlICgwKQoKc3RydWN0IGNoaWxkX2FyZ3MgewogICAgY2hhciAq
KmFyZ3Y7ICAgICAgICAvKiBDb21tYW5kIHRvIGJlIGV4ZWN1dGVkIGJ5IGNoaWxkLCB3aXRoIGFy
Z3MgKi8KICAgIGludCAgICBwaXBlX2ZkWzJdOyAgLyogUGlwZSB1c2VkIHRvIHN5bmNocm9uaXpl
IHBhcmVudCBhbmQgY2hpbGQgKi8KfTsKCnN0YXRpYyBpbnQgdmVyYm9zZTsKCnN0YXRpYyB2b2lk
CnVzYWdlKGNoYXIgKnBuYW1lKQp7CiAgICBmcHJpbnRmKHN0ZGVyciwgIlVzYWdlOiAlcyBbb3B0
aW9uc10gY21kIFthcmcuLi5dXFxuXFxuIiwgcG5hbWUpOwogICAgZnByaW50ZihzdGRlcnIsICJD
cmVhdGUgYSBjaGlsZCBwcm9jZXNzIHRoYXQgZXhlY3V0ZXMgYSBzaGVsbCAiCiAgICAgICAgICAg
ICJjb21tYW5kIGluIGEgbmV3IHVzZXIgbmFtZXNwYWNlLFxcbiIKICAgICAgICAgICAgImFuZCBw
b3NzaWJseSBhbHNvIG90aGVyIG5ldyBuYW1lc3BhY2UocykuXFxuXFxuIik7CiAgICBmcHJpbnRm
KHN0ZGVyciwgIk9wdGlvbnMgY2FuIGJlOlxcblxcbiIpOwojZGVmaW5lIGZwZShzdHIpIGZwcmlu
dGYoc3RkZXJyLCAiICAgICVzIiwgc3RyKTsKICAgIGZwZSgiXC1pICAgICAgICAgIE5ldyBJUEMg
bmFtZXNwYWNlXFxuIik7CiAgICBmcGUoIlwtbSAgICAgICAgICBOZXcgbW91bnQgbmFtZXNwYWNl
XFxuIik7CiAgICBmcGUoIlwtbiAgICAgICAgICBOZXcgbmV0d29yayBuYW1lc3BhY2VcXG4iKTsK
ICAgIGZwZSgiXC1wICAgICAgICAgIE5ldyBQSUQgbmFtZXNwYWNlXFxuIik7CiAgICBmcGUoIlwt
dSAgICAgICAgICBOZXcgVVRTIG5hbWVzcGFjZVxcbiIpOwogICAgZnBlKCJcLVUgICAgICAgICAg
TmV3IHVzZXIgbmFtZXNwYWNlXFxuIik7CiAgICBmcGUoIlwtTSB1aWRfbWFwICBTcGVjaWZ5IFVJ
RCBtYXAgZm9yIHVzZXIgbmFtZXNwYWNlXFxuIik7CiAgICBmcGUoIlwtRyBnaWRfbWFwICBTcGVj
aWZ5IEdJRCBtYXAgZm9yIHVzZXIgbmFtZXNwYWNlXFxuIik7CiAgICBmcGUoIiAgICAgICAgICAg
IElmIFwtTSBvciBcLUcgaXMgc3BlY2lmaWVkLCBcLVUgaXMgcmVxdWlyZWRcXG4iKTsKICAgIGZw
ZSgiXC12ICAgICAgICAgIERpc3BsYXkgdmVyYm9zZSBtZXNzYWdlc1xcbiIpOwogICAgZnBlKCJc
XG4iKTsKICAgIGZwZSgiTWFwIHN0cmluZ3MgZm9yIFwtTSBhbmQgXC1HIGNvbnNpc3Qgb2YgcmVj
b3JkcyBvZiB0aGUgZm9ybTpcXG4iKTsKICAgIGZwZSgiXFxuIik7CiAgICBmcGUoIiAgICBJRFwt
aW5zaWRlXC1ucyAgIElEXC1vdXRzaWRlXC1ucyAgIGxlblxcbiIpOwogICAgZnBlKCJcXG4iKTsK
ICAgIGZwZSgiQSBtYXAgc3RyaW5nIGNhbiBjb250YWluIG11bHRpcGxlIHJlY29yZHMsICIpOwog
ICAgZnBlKCJzZXBhcmF0ZWQgYnkgY29tbWFzO1xcbiIpOwogICAgZnBlKCJ0aGUgY29tbWFzIGFy
ZSByZXBsYWNlZCBieSBuZXdsaW5lcyBiZWZvcmUgd3JpdGluZyIpOwogICAgZnBlKCIgdG8gbWFw
IGZpbGVzLlxcbiIpOwoKICAgIGV4aXQoRVhJVF9GQUlMVVJFKTsKfQoKLyogVXBkYXRlIHRoZSBt
YXBwaW5nIGZpbGUgXChhcW1hcF9maWxlXChhcSwgd2l0aCB0aGUgdmFsdWUgcHJvdmlkZWQgaW4K
ICAgXChhcW1hcHBpbmdcKGFxLCBhIHN0cmluZyB0aGF0IGRlZmluZXMgYSBVSUQgb3IgR0lEIG1h
cHBpbmcuIEEgVUlEIG9yCiAgIEdJRCBtYXBwaW5nIGNvbnNpc3RzIG9mIG9uZSBvciBtb3JlIG5l
d2xpbmVcLWRlbGltaXRlZCByZWNvcmRzCiAgIG9mIHRoZSBmb3JtOgoKICAgICAgIElEXC1pbnNp
ZGVcLW5zICAgIElEXC1vdXRzaWRlXC1ucyAgIGxlbmd0aAoKICAgUmVxdWlyaW5nIHRoZSB1c2Vy
IHRvIHN1cHBseSBhIHN0cmluZyB0aGF0IGNvbnRhaW5zIG5ld2xpbmVzIGlzCiAgIG9mIGNvdXJz
ZSBpbmNvbnZlbmllbnQgZm9yIGNvbW1hbmRcLWxpbmUgdXNlLiBUaHVzLCB3ZSBwZXJtaXQgdGhl
CiAgIHVzZSBvZiBjb21tYXMgdG8gZGVsaW1pdCByZWNvcmRzIGluIHRoaXMgc3RyaW5nLCBhbmQg
cmVwbGFjZSB0aGVtCiAgIHdpdGggbmV3bGluZXMgYmVmb3JlIHdyaXRpbmcgdGhlIHN0cmluZyB0
byB0aGUgZmlsZS4gKi8KCnN0YXRpYyB2b2lkCnVwZGF0ZV9tYXAoY2hhciAqbWFwcGluZywgY2hh
ciAqbWFwX2ZpbGUpCnsKICAgIGludCBmZCwgajsKICAgIHNpemVfdCBtYXBfbGVuOyAgICAgLyog
TGVuZ3RoIG9mIFwoYXFtYXBwaW5nXChhcSAqLwoKICAgIC8qIFJlcGxhY2UgY29tbWFzIGluIG1h
cHBpbmcgc3RyaW5nIHdpdGggbmV3bGluZXMgKi8KCiAgICBtYXBfbGVuID0gc3RybGVuKG1hcHBp
bmcpOwogICAgZm9yIChqID0gMDsgaiA8IG1hcF9sZW47IGorKykKICAgICAgICBpZiAobWFwcGlu
Z1tqXSA9PSBcKGFxLFwoYXEpCiAgICAgICAgICAgIG1hcHBpbmdbal0gPSBcKGFxXFxuXChhcTsK
CiAgICBmZCA9IG9wZW4obWFwX2ZpbGUsIE9fUkRXUik7CiAgICBpZiAoZmQgPT0gXC0xKSB7CiAg
ICAgICAgZnByaW50ZihzdGRlcnIsICJvcGVuICVzOiAlc1xcbiIsIG1hcF9maWxlLCBzdHJlcnJv
cihlcnJubykpOwogICAgICAgIGV4aXQoRVhJVF9GQUlMVVJFKTsKICAgIH0KCiAgICBpZiAod3Jp
dGUoZmQsIG1hcHBpbmcsIG1hcF9sZW4pICE9IG1hcF9sZW4pIHsKICAgICAgICBmcHJpbnRmKHN0
ZGVyciwgIndyaXRlICVzOiAlc1xcbiIsIG1hcF9maWxlLCBzdHJlcnJvcihlcnJubykpOwogICAg
ICAgIGV4aXQoRVhJVF9GQUlMVVJFKTsKICAgIH0KCiAgICBjbG9zZShmZCk7Cn0KCnN0YXRpYyBp
bnQgICAgICAgICAgICAgIC8qIFN0YXJ0IGZ1bmN0aW9uIGZvciBjbG9uZWQgY2hpbGQgKi8KY2hp
bGRGdW5jKHZvaWQgKmFyZykKewogICAgc3RydWN0IGNoaWxkX2FyZ3MgKmFyZ3MgPSAoc3RydWN0
IGNoaWxkX2FyZ3MgKikgYXJnOwogICAgY2hhciBjaDsKCiAgICAvKiBXYWl0IHVudGlsIHRoZSBw
YXJlbnQgaGFzIHVwZGF0ZWQgdGhlIFVJRCBhbmQgR0lEIG1hcHBpbmdzLgogICAgICAgU2VlIHRo
ZSBjb21tZW50IGluIG1haW4oKS4gV2Ugd2FpdCBmb3IgZW5kIG9mIGZpbGUgb24gYQogICAgICAg
cGlwZSB0aGF0IHdpbGwgYmUgY2xvc2VkIGJ5IHRoZSBwYXJlbnQgcHJvY2VzcyBvbmNlIGl0IGhh
cwogICAgICAgdXBkYXRlZCB0aGUgbWFwcGluZ3MuICovCgogICAgY2xvc2UoYXJnc1wtPnBpcGVf
ZmRbMV0pOyAgICAvKiBDbG9zZSBvdXIgZGVzY3JpcHRvciBmb3IgdGhlIHdyaXRlCiAgICAgICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgZW5kIG9mIHRoZSBwaXBlIHNvIHRoYXQgd2Ugc2Vl
IEVPRgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHdoZW4gcGFyZW50IGNsb3Nl
cyBpdHMgZGVzY3JpcHRvciAqLwogICAgaWYgKHJlYWQoYXJnc1wtPnBpcGVfZmRbMF0sICZjaCwg
MSkgIT0gMCkgewogICAgICAgIGZwcmludGYoc3RkZXJyLAogICAgICAgICAgICAgICAgIkZhaWx1
cmUgaW4gY2hpbGQ6IHJlYWQgZnJvbSBwaXBlIHJldHVybmVkICE9IDBcXG4iKTsKICAgICAgICBl
eGl0KEVYSVRfRkFJTFVSRSk7CiAgICB9CgogICAgLyogRXhlY3V0ZSBhIHNoZWxsIGNvbW1hbmQg
Ki8KCiAgICBleGVjdnAoYXJnc1wtPmFyZ3ZbMF0sIGFyZ3NcLT5hcmd2KTsKICAgIGVyckV4aXQo
ImV4ZWN2cCIpOwp9CgojZGVmaW5lIFNUQUNLX1NJWkUgKDEwMjQgKiAxMDI0KQoKc3RhdGljIGNo
YXIgY2hpbGRfc3RhY2tbU1RBQ0tfU0laRV07ICAgIC8qIFNwYWNlIGZvciBjaGlsZFwoYXFzIHN0
YWNrICovCgppbnQKbWFpbihpbnQgYXJnYywgY2hhciAqYXJndltdKQp7CiAgICBpbnQgZmxhZ3Ms
IG9wdDsKICAgIHBpZF90IGNoaWxkX3BpZDsKICAgIHN0cnVjdCBjaGlsZF9hcmdzIGFyZ3M7CiAg
ICBjaGFyICp1aWRfbWFwLCAqZ2lkX21hcDsKICAgIGNoYXIgbWFwX3BhdGhbUEFUSF9NQVhdOwoK
ICAgIC8qIFBhcnNlIGNvbW1hbmRcLWxpbmUgb3B0aW9ucy4gVGhlIGluaXRpYWwgXChhcStcKGFx
IGNoYXJhY3RlciBpbgogICAgICAgdGhlIGZpbmFsIGdldG9wdCgpIGFyZ3VtZW50IHByZXZlbnRz
IEdOVVwtc3R5bGUgcGVybXV0YXRpb24KICAgICAgIG9mIGNvbW1hbmRcLWxpbmUgb3B0aW9ucy4g
VGhhdFwoYXFzIHVzZWZ1bCwgc2luY2Ugc29tZXRpbWVzCiAgICAgICB0aGUgXChhcWNvbW1hbmRc
KGFxIHRvIGJlIGV4ZWN1dGVkIGJ5IHRoaXMgcHJvZ3JhbSBpdHNlbGYKICAgICAgIGhhcyBjb21t
YW5kXC1saW5lIG9wdGlvbnMuIFdlIGRvblwoYXF0IHdhbnQgZ2V0b3B0KCkgdG8gdHJlYXQKICAg
ICAgIHRob3NlIGFzIG9wdGlvbnMgdG8gdGhpcyBwcm9ncmFtLiAqLwoKICAgIGZsYWdzID0gMDsK
ICAgIHZlcmJvc2UgPSAwOwogICAgZ2lkX21hcCA9IE5VTEw7CiAgICB1aWRfbWFwID0gTlVMTDsK
ICAgIHdoaWxlICgob3B0ID0gZ2V0b3B0KGFyZ2MsIGFyZ3YsICIraW1ucHVVTTpHOnYiKSkgIT0g
XC0xKSB7CiAgICAgICAgc3dpdGNoIChvcHQpIHsKICAgICAgICBjYXNlIFwoYXFpXChhcTogZmxh
Z3MgfD0gQ0xPTkVfTkVXSVBDOyAgICAgICAgYnJlYWs7CiAgICAgICAgY2FzZSBcKGFxbVwoYXE6
IGZsYWdzIHw9IENMT05FX05FV05TOyAgICAgICAgIGJyZWFrOwogICAgICAgIGNhc2UgXChhcW5c
KGFxOiBmbGFncyB8PSBDTE9ORV9ORVdORVQ7ICAgICAgICBicmVhazsKICAgICAgICBjYXNlIFwo
YXFwXChhcTogZmxhZ3MgfD0gQ0xPTkVfTkVXUElEOyAgICAgICAgYnJlYWs7CiAgICAgICAgY2Fz
ZSBcKGFxdVwoYXE6IGZsYWdzIHw9IENMT05FX05FV1VUUzsgICAgICAgIGJyZWFrOwogICAgICAg
IGNhc2UgXChhcXZcKGFxOiB2ZXJib3NlID0gMTsgICAgICAgICAgICAgICAgICBicmVhazsKICAg
ICAgICBjYXNlIFwoYXFNXChhcTogdWlkX21hcCA9IG9wdGFyZzsgICAgICAgICAgICAgYnJlYWs7
CiAgICAgICAgY2FzZSBcKGFxR1woYXE6IGdpZF9tYXAgPSBvcHRhcmc7ICAgICAgICAgICAgIGJy
ZWFrOwogICAgICAgIGNhc2UgXChhcVVcKGFxOiBmbGFncyB8PSBDTE9ORV9ORVdVU0VSOyAgICAg
ICBicmVhazsKICAgICAgICBkZWZhdWx0OiAgdXNhZ2UoYXJndlswXSk7CiAgICAgICAgfQogICAg
fQoKICAgIC8qIFwtTSBvciBcLUcgd2l0aG91dCBcLVUgaXMgbm9uc2Vuc2ljYWwgKi8KCiAgICBp
ZiAoKHVpZF9tYXAgIT0gTlVMTCB8fCBnaWRfbWFwICE9IE5VTEwpICYmCiAgICAgICAgICAgICEo
ZmxhZ3MgJiBDTE9ORV9ORVdVU0VSKSkKICAgICAgICB1c2FnZShhcmd2WzBdKTsKCiAgICBhcmdz
LmFyZ3YgPSAmYXJndltvcHRpbmRdOwoKICAgIC8qIFdlIHVzZSBhIHBpcGUgdG8gc3luY2hyb25p
emUgdGhlIHBhcmVudCBhbmQgY2hpbGQsIGluIG9yZGVyIHRvCiAgICAgICBlbnN1cmUgdGhhdCB0
aGUgcGFyZW50IHNldHMgdGhlIFVJRCBhbmQgR0lEIG1hcHMgYmVmb3JlIHRoZSBjaGlsZAogICAg
ICAgY2FsbHMgZXhlY3ZlKCkuIFRoaXMgZW5zdXJlcyB0aGF0IHRoZSBjaGlsZCBtYWludGFpbnMg
aXRzCiAgICAgICBjYXBhYmlsaXRpZXMgZHVyaW5nIHRoZSBleGVjdmUoKSBpbiB0aGUgY29tbW9u
IGNhc2Ugd2hlcmUgd2UKICAgICAgIHdhbnQgdG8gbWFwIHRoZSBjaGlsZFwoYXFzIGVmZmVjdGl2
ZSB1c2VyIElEIHRvIDAgaW4gdGhlIG5ldyB1c2VyCiAgICAgICBuYW1lc3BhY2UuIFdpdGhvdXQg
dGhpcyBzeW5jaHJvbml6YXRpb24sIHRoZSBjaGlsZCB3b3VsZCBsb3NlCiAgICAgICBpdHMgY2Fw
YWJpbGl0aWVzIGlmIGl0IHBlcmZvcm1lZCBhbiBleGVjdmUoKSB3aXRoIG5vbnplcm8KICAgICAg
IHVzZXIgSURzIChzZWUgdGhlIGNhcGFiaWxpdGllcyg3KSBtYW4gcGFnZSBmb3IgZGV0YWlscyBv
ZiB0aGUKICAgICAgIHRyYW5zZm9ybWF0aW9uIG9mIGEgcHJvY2Vzc1woYXFzIGNhcGFiaWxpdGll
cyBkdXJpbmcgZXhlY3ZlKCkpLiAqLwoKICAgIGlmIChwaXBlKGFyZ3MucGlwZV9mZCkgPT0gXC0x
KQogICAgICAgIGVyckV4aXQoInBpcGUiKTsKCiAgICAvKiBDcmVhdGUgdGhlIGNoaWxkIGluIG5l
dyBuYW1lc3BhY2UocykgKi8KCiAgICBjaGlsZF9waWQgPSBjbG9uZShjaGlsZEZ1bmMsIGNoaWxk
X3N0YWNrICsgU1RBQ0tfU0laRSwKICAgICAgICAgICAgICAgICAgICAgIGZsYWdzIHwgU0lHQ0hM
RCwgJmFyZ3MpOwogICAgaWYgKGNoaWxkX3BpZCA9PSBcLTEpCiAgICAgICAgZXJyRXhpdCgiY2xv
bmUiKTsKCiAgICAvKiBQYXJlbnQgZmFsbHMgdGhyb3VnaCB0byBoZXJlICovCgogICAgaWYgKHZl
cmJvc2UpCiAgICAgICAgcHJpbnRmKCIlczogUElEIG9mIGNoaWxkIGNyZWF0ZWQgYnkgY2xvbmUo
KSBpcyAlbGRcXG4iLAogICAgICAgICAgICAgICAgYXJndlswXSwgKGxvbmcpIGNoaWxkX3BpZCk7
CgogICAgLyogVXBkYXRlIHRoZSBVSUQgYW5kIEdJRCBtYXBzIGluIHRoZSBjaGlsZCAqLwoKICAg
IGlmICh1aWRfbWFwICE9IE5VTEwpIHsKICAgICAgICBzbnByaW50ZihtYXBfcGF0aCwgUEFUSF9N
QVgsICIvcHJvYy8lbGQvdWlkX21hcCIsCiAgICAgICAgICAgICAgICAobG9uZykgY2hpbGRfcGlk
KTsKICAgICAgICB1cGRhdGVfbWFwKHVpZF9tYXAsIG1hcF9wYXRoKTsKICAgIH0KICAgIGlmIChn
aWRfbWFwICE9IE5VTEwpIHsKICAgICAgICBzbnByaW50ZihtYXBfcGF0aCwgUEFUSF9NQVgsICIv
cHJvYy8lbGQvZ2lkX21hcCIsCiAgICAgICAgICAgICAgICAobG9uZykgY2hpbGRfcGlkKTsKICAg
ICAgICB1cGRhdGVfbWFwKGdpZF9tYXAsIG1hcF9wYXRoKTsKICAgIH0KCiAgICAvKiBDbG9zZSB0
aGUgd3JpdGUgZW5kIG9mIHRoZSBwaXBlLCB0byBzaWduYWwgdG8gdGhlIGNoaWxkIHRoYXQgd2UK
ICAgICAgIGhhdmUgdXBkYXRlZCB0aGUgVUlEIGFuZCBHSUQgbWFwcyAqLwoKICAgIGNsb3NlKGFy
Z3MucGlwZV9mZFsxXSk7CgogICAgaWYgKHdhaXRwaWQoY2hpbGRfcGlkLCBOVUxMLCAwKSA9PSBc
LTEpICAgICAgLyogV2FpdCBmb3IgY2hpbGQgKi8KICAgICAgICBlcnJFeGl0KCJ3YWl0cGlkIik7
CgogICAgaWYgKHZlcmJvc2UpCiAgICAgICAgcHJpbnRmKCIlczogdGVybWluYXRpbmdcXG4iLCBh
cmd2WzBdKTsKCiAgICBleGl0KEVYSVRfU1VDQ0VTUyk7Cn0KLmZpCi5TSCBTRUUgQUxTTwouQlIg
Y2xvbmUgKDIpLAouQlIgc2V0bnMgKDIpLAouQlIgdW5zaGFyZSAoMiksCi5CUiBwcm9jICg1KSwK
LkJSIGNyZWRlbnRpYWxzICg3KSwKLkJSIGNhcGFiaWxpdGllcyAoNyksCi5CUiBuYW1lc3BhY2Vz
ICg3KSwKLkJSIHBpZF9uYW1lc3BhY2VzICg3KQouc3AKVGhlIGtlcm5lbCBzb3VyY2UgZmlsZQou
SVIgRG9jdW1lbnRhdGlvbi9uYW1lc3BhY2VzL3Jlc291cmNlLWNvbnRyb2wudHh0IC4K
--bcaec5314b2df1bcc404d7f0e15e
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
--bcaec5314b2df1bcc404d7f0e15e--
