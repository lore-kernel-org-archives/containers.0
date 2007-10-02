From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [patch -mm 1/5] mqueue namespace : add struct mq_namespace
Date: Tue, 02 Oct 2007 04:59:35 -0600
Message-ID: <m1ir5plr3c.fsf@ebiederm.dsl.xmission.com>
References: <20071002084608.149781400@fr.ibm.com>
	<20071002084906.477406083@fr.ibm.com> <47020A29.9060403@sw.ru>
	<470219BC.3050702@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <470219BC.3050702-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> (Cedric Le Goater's message of
	"Tue, 02 Oct 2007 12:13:16 +0200")
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

> Hello Kirill,
>
> Kirill Korotaev wrote:
>> Cedric,
>> 
>> how safe does it intersect with netlinks from network namespace?
>> I see mqueues can send netlink messages, have you checked how safe it is?
>
> a ref is taken on the 'struct sock' in the mq_notify() syscall and the
> skbuff which will be send to notify the user is also allocated in the
> mq_notify() syscall. So we should be in the same net namespace when we 
> register the notification and when we notify. 
>
> I hope the net guys can confirm or we will easily check in the next 
> -lxc patchset which will merge this patchset with netns.
>  
> however, we have an issue with the signal notification in __do_notify()
> we could kill a process in a different pid namespace.

So I took a quick look at the code as it is (before this patchset)
and the taking a reference to a socket and the taking a reference to
a struct pid should do the right thing when we intersect with other
namespaces.  It certainly does not look like a fundamental issue.

In practice the patchset as written  does conflict with the network
namespace work in the net-2.6.24 tree so some adjustments will need
to be made.

Eric
