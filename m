From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [patch 1/2][RFC] add socketat syscall
Date: Fri, 31 Oct 2008 18:30:45 -0700
Message-ID: <m1ljw4mdve.fsf@frodo.ebiederm.org>
References: <20081031215602.655672481@fr.ibm.com>
	<20081031215900.810348746@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20081031215900.810348746-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> (Daniel Lezcano's message
	of "Fri, 31 Oct 2008 22:56:03 +0100")
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org> writes:

> This patch adds the socketat syscall which allows to specify in
> which network namespace we want to create a socket. The network
> namespace destination is referred by a socket fd previously opened
> in the destination network namespace.

Looks good and very simple.

I have a small update to my proposal for an ABI, that should be easier
to deploy if the ABI gods can't find fault with it.

#define SOCK_FDNS	0x100000  /* Some good non-conflicting number */
And then reuse extend socket to read one more argument when it is passed.

So.
asmlinkage long sys_socket(int domain, int type, int protocol);
becomes:
asmlinkage long sys_socket(int domain, int type, int protocol, int fd);
when SOCK_FDNS is set in type.

I believe the calling conventions in the kernel already pass 4 arguments
so we just need to read and act on the forth.  That should be easier than
allocating an extra syscall number on every architecture.

Eric
