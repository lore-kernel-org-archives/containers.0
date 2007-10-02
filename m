From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch -mm 1/5] mqueue namespace : add struct mq_namespace
Date: Tue, 02 Oct 2007 14:21:27 +0200
Message-ID: <470237C7.5000902@fr.ibm.com>
References: <20071002084608.149781400@fr.ibm.com>
	<20071002084906.477406083@fr.ibm.com> <47020A29.9060403@sw.ru>
	<470219BC.3050702@fr.ibm.com>
	<m1ir5plr3c.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <m1ir5plr3c.fsf-T1Yj925okcoyDheHMi7gv2pdwda3JcWeAL8bYrjMMd8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org


>> however, we have an issue with the signal notification in __do_notify()
>> we could kill a process in a different pid namespace.
> 
> So I took a quick look at the code as it is (before this patchset)
> and the taking a reference to a socket and the taking a reference to
> a struct pid should do the right thing when we intersect with other
> namespaces.  It certainly does not look like a fundamental issue.

right. this should be covered when the pid namespace signal handling is 
complete. kill_pid_info() should fail to send a signal to a sibling or 
a parent pid namespace. 

I guess we should add a WARNING() to say that we're attempting to do so.

> In practice the patchset as written  does conflict with the network
> namespace work in the net-2.6.24 tree so some adjustments will need
> to be made.

I think no more than fixing the CLONE flags in sched.h and the conflicts
in nsproxy.c.  

Thanks !

C.
