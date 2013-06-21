From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [Part1 PATCH 00/22] Add namespace support for audit
Date: Fri, 21 Jun 2013 03:49:34 -0700
Message-ID: <87ehbvivr5.fsf@xmission.com>
References: <1371606834-5802-1-git-send-email-gaofeng@cn.fujitsu.com>
	<20130619204927.GJ3212@redhat.com>
	<1371675095.16587.5.camel@dhcp137-13.rdu.redhat.com>
	<51C270AF.1080902@cn.fujitsu.com>
	<1371733353.16587.19.camel@dhcp137-13.rdu.redhat.com>
	<51C3CCFB.4030901@cn.fujitsu.com> <51C42221.3030206@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <51C42221.3030206-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (Daniel J. Walsh's message of "Fri,
	21 Jun 2013 05:51:29 -0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel J Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Paris <eparis-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, matthltc-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

Daniel J Walsh <dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> Will I be able to use the audit namespace without the user namespace.  I would
> prefer to be able to use the audit namespace long before I am willing to take
> a chance with the User Namespace for things like light weight virtualization
> and securing processes with MAC.

I will be very surprised if we settle on a design that allows it.

I still think even the existence of multiple audit contexts is a little
iffy but the desire seems strong enough Gao feng will probably work
through all of the issues.

Without restricting processes to a user namespace at the same time as
restricting them to an audit context it becomes very easy to violate the
important audit policies and to bury user space generated messages from
privileged userspace applications.  At least in a user namespace we know
you are not privileged with respect to the rest of the system, so we
would only be dealing with userspace messages you would not be able to
generate otherwise.

As for taking a chance.  You will probably safer with a simultaneous use
of user namespaces and having processes secured with a MAC.  To the best
of my knowledge previous solutions have only been really safe when you
trusted the processes inside not to be malicious.  A user namespace at
least means you can stop using uid 0 inside of your light weight
virtualization.

Eric
