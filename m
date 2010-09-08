From: =?ISO-8859-1?Q?Matthieu_Fertr=E9?= <matthieu.fertre-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>
Subject: C/R: File substitution at restart
Date: Wed, 08 Sep 2010 12:03:26 +0200
Message-ID: <4C875F6E.2030004@kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: "Serge E. Hallyn" <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Nathan Lynch <nathanl-V7BBcbaFuwjMbYB6QlFGEg@public.gmane.org>, Louis Rilling <Louis.Rilling-aw0BnHfMbSpBDgjK7y7TUQ@public.gmane.org>, Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

Here is a proposal for a C/R related feature already developed in
Kerrighed: file substitution at restart.

The goal of this mail is to start a discussion about adding such feature
to Linux cr. Comments are welcome!



What is file substitution ?
===========================

It is the ability, at restart of a checkpointed application, to
substitute some of the opened files by some other files.

Only files accessed through a FD can be substituted, not mapped file
(unless they are reachable through a FD in the same time).

The feature ensures 'struct file' sharing as before the checkpoint.
Thus, if a process is for instance sharing the same struct file for
stdin, stdout, and stderr, it is not possible to give a different file
for each at restart.

Use cases
=========

1) Circumvent Checkpointer limitations:

* Allow to restart an application that has some files not supported by
checkpoint/restart implementation.

2) Conflicts between existing files and files that should be restored:

* Allow to restart an application of which one input data file is not
writable by the user and thus can not be restored/replaced.

* Allow to restart an application of which one output data file is
already open by another instance of the program.

3) Checkpoint/restart optimization/flexibility:

* Let the application checkpoint and restore files by itself to get
better performance or flexibility.

Example: OpenMPI sockets. Avoid to handle communication buffers and
ensure consistent distributed state.

How user(s) can use it ?
========================

(Kerrighed) restart manual page quote:
"-s file_identifier,fd, --substitute-file=file_identifier,fd

This option allows to replace one of the open files of the checkpointed
application by one of the file opened by the process calling the restart
command.

fd is the file descriptor (as given by open (2)) of the calling process
that will be used as a replacement after the restart.

file_identifier is an identifier of one the open files of the
checkpointed application. This identifier is generated at checkpoint
time. It can be retrieved from the file(s) user_info_*.txt that live(s)
in the checkpoint directory. Each line of this file refers to one of the
open files of the checkpointed application. For each open file, we get
the following information:
type|file_identifier|symbolic name|list of pid:fd

This option can be used several times to substitute several files."

Here is a simple (and stupid?) example extracted from Louis's talk at OLS:

$ krgcr-run ping localhost
Running application 6315097
(ping output omitted)
$ checkpoint -i 6315097
$
$ cat /var/chkpt/6315097/v1/user_info_1.txt
socket |0001FFFF880066D68EA8|socket:[219057]|6315097:3
tty    |0001FFFF88007D040EA8|/dev/pts/1|6315097:0,6315097:1,6315097:2

$ # Use current terminal for standard I/O at restart:
$ # ('-t' stands for tty and acts as a wrapper for option '-s')
$ restart -t 6315097 1

$ # Use stdin instead of socket at restart:
$ restart -s 0001FFFF880066D68EA8,0 6315097 1



Thanks,

Matthieu
