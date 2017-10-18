From: Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>
Subject: Re: RFC(v2): Audit Kernel Container IDs
Date: Wed, 18 Oct 2017 15:58:13 -0400
Message-ID: <CAHC9VhTBd1pNqavFpQqDHwhW=j7AX8gDL0H_c_VBD07SMMLZmQ__39707.3637963787$1508356726$gmane$org@mail.gmail.com>
References: <20171012141359.saqdtnodwmbz33b2@madcap2.tricolour.ca>
	<75b7d6a6-42ba-2dff-1836-1091c7c024e7@schaufler-ca.com>
	<20171017003340.whjdkqmkw4lydwy7@madcap2.tricolour.ca>
	<2319693.5l3M4ZINGd@x2> <1508243469.6230.24.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1508243469.6230.24.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Simo Sorce <simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, trondmy-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org, jlayton-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Eric Paris <eparis-FjpueFixGhCM4zKIHC2jIg@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Carlos O'Donell <carlos-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Linux Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Oct 17, 2017 at 8:31 AM, Simo Sorce <simo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> The container Id can be used also for authorization purposes (by other
> processes on the host), not just audit, I think this is why a separate
> control has been proposed.

Apologies, but I'm just now getting a chance to work my way through
this thread, and I wanted to make a quick comment on this point ...

The audit container ID (note I said "audit container ID" not
"container ID") is intended strictly for use by the audit subsystem at
this point.  Allowing other uses opens the door to a larger set of
problems we are trying to avoid (e.g. handling migration across
hosts).  We would love to have a generic kernel facility that the
audit subsystem could use to identify containers, but we don't, and
previous attempts have failed, so we have to create our own.  We are
intentionally trying to limit its scope in an attempt to limit
problems.  If a more general solution appears in the future I think we
would make every effect to migrate to that; keeping this initial
effort small should make that easier.

-- 
paul moore
www.paul-moore.com
