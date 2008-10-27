From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: container userspace tools
Date: Mon, 27 Oct 2008 09:50:58 -0500
Message-ID: <20081027145058.GA9724@us.ibm.com>
References: <8f34198c0810150033p42b74badrf194e66433e32cd5@mail.gmail.com>
	<48F5BE23.1060602@fr.ibm.com>
	<8f34198c0810150351n7549a1dcx63547746344fce25@mail.gmail.com>
	<48F5DB43.70003@fr.ibm.com>
	<8f34198c0810150602w70d31453je6fd8811799a3857@mail.gmail.com>
	<48F5EBF3.1070204@fr.ibm.com>
	<8f34198c0810250406s4f1c9337ha2bccc10faed1948@mail.gmail.com>
	<49031A54.70806@fr.ibm.com>
	<8f34198c0810250739s77ad8271u93992c0bcf61345c@mail.gmail.com>
	<49033F90.8090201@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <49033F90.8090201-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Daniel Lezcano (dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org):
> Ian jonhson wrote:
> >> The container will be more or less isolated depending of what you specify in
> >> the configuration file.
> >>
> > yes
> > 
> >> Without any configuration file, you will have pid, ipc and mount points
> >> isolated. If you specify the utsname, it will be isolated and if you specify
> >> the network you will have a new network stack allowing to run for example a
> >> new sshd server.
> >>
> > 
> > hmm.... then, how to configure the container to get the isolation of
> > pid, ipc and
> > mount points? 
> 
> This is done automatically, with or without configuration.

I assume Ian has a kernel compiled with CONFIG_PID_NS=n?

-serge
