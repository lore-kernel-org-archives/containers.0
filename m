From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: container userspace tools
Date: Mon, 27 Oct 2008 11:53:28 -0500
Message-ID: <20081027165328.GA32406@us.ibm.com>
References: <48F5BE23.1060602@fr.ibm.com>
	<8f34198c0810150351n7549a1dcx63547746344fce25@mail.gmail.com>
	<48F5DB43.70003@fr.ibm.com>
	<8f34198c0810150602w70d31453je6fd8811799a3857@mail.gmail.com>
	<48F5EBF3.1070204@fr.ibm.com>
	<8f34198c0810250406s4f1c9337ha2bccc10faed1948@mail.gmail.com>
	<49031A54.70806@fr.ibm.com>
	<8f34198c0810250739s77ad8271u93992c0bcf61345c@mail.gmail.com>
	<49033F90.8090201@fr.ibm.com>
	<8f34198c0810270923s40ee505ay214bc9dd8ebae26d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <8f34198c0810270923s40ee505ay214bc9dd8ebae26d-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ian jonhson <jonhson.ian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Ian jonhson (jonhson.ian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
> >>
> >> hmm.... then, how to configure the container to get the isolation of
> >> pid, ipc and
> >> mount points?
> >
> > This is done automatically, with or without configuration.
> >
> > For examples:
> >
> >        lxc-execute -n foo -- ps -ef --forest
> >
> > UID        PID  PPID  C STIME TTY          TIME CMD
> > root         1     0  0 16:55 ?        00:00:00 lxc-execute -n foo -- ps -ef
> > --forest
> > root         2     1  0 16:55 pts/6    00:00:00 ps -ef --forest
> >
> >
> >        lxc-execute -n foo ls /proc
> >
> > will only show process 1 and 2, showing the /proc fs has been remount inside
> > the container without interfering with your own /proc.
> >
> > You can do the same check by looking at the ipcs inside and outside the
> > container  (assuming they are different).
> >
> 
> Is it possible to isolate processes in two different containers when they access
> given local file. For example, I run a process_A in container_A to create a
> file named "shared_file". Then, another process (for example, process_B)
> in container_A can access the "shared_file", but another process, named
> process_C in container_B can not access the same file. The process_A,
> process_B, and process_C are run with same uid/gid. how to set the
> configurations of container_A and container_B to achieve the isolation?
> Is is possible to do this?

1. You can put them in each a different chroot.  For instance, extract
the debian.tar.gz which Daniel has pointed you to before into both
/vs1 and /vs2.  Put container_A in /vs1 and container_B in /vs2.

2. You can use SELinux or Smack.  Details for now left as an excercise
to the reader.

3. One day you'll be able to use user namespaces.  In that case, even
though process_{A,B,C} are all running with the same integer uid/gid,
process_C will be in a different different user namespace than
process_{A,B}.  So the file created by process_A will be accessed by
process_C as though they were different userids.  Which means if
process_A set permissions on the file as rwxr-xr-x, then process_c
will get r-x permissions.  If process_A set the permissions to
rwxr-xr-x, then process_c will have no permissions.

-serge
