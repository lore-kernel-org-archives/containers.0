From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Subject: Re: [patch -mm 1/5] mqueue namespace : add struct mq_namespace
Date: Wed, 03 Oct 2007 09:38:58 +0200
Message-ID: <47034712.9060101@fr.ibm.com>
References: <20071002084608.149781400@fr.ibm.com>
	<20071002084906.477406083@fr.ibm.com> <47020A29.9060403@sw.ru>
	<470219BC.3050702@fr.ibm.com>
	<m1ir5plr3c.fsf@ebiederm.dsl.xmission.com>
	<470237C7.5000902@fr.ibm.com> <20071002163020.GA11207@us.ibm.com>
	<m1k5q5jv29.fsf@ebiederm.dsl.xmission.com>
	<470340F8.50806@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <470340F8.50806-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

[ 
  I have big fingers this morning and I managed to send this email 
  while typing it ... see below for the end. I should be awake now :) 
]

> The really challenging case to handle here  is what happens if we are
> signaling to someone in a sibling pid namespace.  What do we set the
> parent pid in the siginfo struct to.  I think we agreed that 0 (blame
> the kernel) is the appropriate pid last time we talked about this.
 
0 seems appropriate for a signal coming from a parent namespace, yes. but
here, we could be sending a signal from a child or sibling namespace.

> I'm worried now that the concept of vpid has confused someone.  It
> still doesn't feel right to me to call one pid value more or less
> virtual then any other so the concept of a virtual pid doesn't make
> sense to me.  The way I have always thought of it is:
> - pid_nr(struct pid *) 
>   The pid in the current pid namespace.
> - __pid_nr(struct pid_namespace, struct pid *) 
>   The pid in some specified pid namespace.
>
> With struct pid being defined to be global and doing something
> appropriate in all pid namespaces.
>
> Thinking about this concern that Cedric raises is actually independent
> of the mqueue namespace and seems to be totally a pid namespace thing.
> Because the only way this happens if we happen to share the mqueue
> namespace. (i.e. what we are doing now).

Is there a way to catch this general issue (we have the same in sigio)
in the kill*(struct pid) routines ? spit a big warning when the
current->nsproxy->pid_ns is not a parent ?

Thanks !

C.
