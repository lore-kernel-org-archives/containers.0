From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [patch -mm 1/5] mqueue namespace : add struct mq_namespace
Date: Tue, 02 Oct 2007 11:02:24 -0600
Message-ID: <m17im5laan.fsf@ebiederm.dsl.xmission.com>
References: <20071002084608.149781400@fr.ibm.com>
	<20071002084906.477406083@fr.ibm.com> <47020A29.9060403@sw.ru>
	<470219BC.3050702@fr.ibm.com>
	<m1ir5plr3c.fsf@ebiederm.dsl.xmission.com>
	<470237C7.5000902@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <470237C7.5000902-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> (Cedric Le Goater's message of
	"Tue, 02 Oct 2007 14:21:27 +0200")
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
Cc: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:

>>> however, we have an issue with the signal notification in __do_notify()
>>> we could kill a process in a different pid namespace.
>> 
>> So I took a quick look at the code as it is (before this patchset)
>> and the taking a reference to a socket and the taking a reference to
>> a struct pid should do the right thing when we intersect with other
>> namespaces.  It certainly does not look like a fundamental issue.
>
> right. this should be covered when the pid namespace signal handling is 
> complete. kill_pid_info() should fail to send a signal to a sibling or 
> a parent pid namespace. 

Huh?

If we call sys_mq_notify and we become the owner then it should
not be a problem to send a signal to us.

> I guess we should add a WARNING() to say that we're attempting to do so.

I don't understand the problem that you are seeing.

Eric
