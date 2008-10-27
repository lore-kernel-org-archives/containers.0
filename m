From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: container userspace tools
Date: Mon, 27 Oct 2008 11:49:23 -0500
Message-ID: <20081027164923.GA26701@us.ibm.com>
References: <8f34198c0810150602w70d31453je6fd8811799a3857@mail.gmail.com>
	<48F5EBF3.1070204@fr.ibm.com>
	<8f34198c0810250406s4f1c9337ha2bccc10faed1948@mail.gmail.com>
	<49031A54.70806@fr.ibm.com>
	<8f34198c0810250739s77ad8271u93992c0bcf61345c@mail.gmail.com>
	<49033F90.8090201@fr.ibm.com> <20081027145058.GA9724@us.ibm.com>
	<8f34198c0810270807k52fa15b8x6402ea262ae2ddc6@mail.gmail.com>
	<20081027160003.GB9724@us.ibm.com>
	<8f34198c0810270929g3ce890e5l91f21523247cf169@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <8f34198c0810270929g3ce890e5l91f21523247cf169-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
> > And you say that 'ps -ef' in the container shows all processes
> > on the system?
> >
> 
> No, just two processes. similar as Denial's:
> 
> ----------------------------------------------------------------------------------------------
> $ sudo  lxc-execute -n foo -- ps -ef --forest
> [sudo] password:
> UID        PID  PPID  C STIME TTY          TIME CMD
> root         1     0  0 23:24 ?        00:00:00 lxc-execute -n foo -- ps -ef --f
> root         2     1  0 23:24 pts/0    00:00:00 ps -ef --forest
> ---------------------------------------------------------------------------------------------

Oh, so in fact pids are being properly isolated.

-serge
