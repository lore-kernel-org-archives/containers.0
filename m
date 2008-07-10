From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC PATCH 5/5] use next syscall data to predefine the file
	descriptor value
Date: Wed, 09 Jul 2008 17:32:26 -0700
Message-ID: <m1tzeyefz9.fsf@frodo.ebiederm.org>
References: <20080708112422.164370000@bull.net>
	<20080708112459.632357000@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080708112459.632357000-6ktuUTfB/bM@public.gmane.org> (Nadia Derbey's message of
	"Tue, 08 Jul 2008 13:24:27 +0200")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Nadia.Derbey-6ktuUTfB/bM@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Nadia.Derbey-6ktuUTfB/bM@public.gmane.org writes:

> [PATCH 05/05]
>
> This patch uses the value written into the next_syscall_data proc file
> as a target file descriptor for the next file to be opened.
>
> This makes it easy to restart a process with the same fds as the ones it was
> using during the checkpoint phase, instead of 1. opening the file, 2. dup2'ing
> the open file descriptor.

As it happens the behavior of open is deterministic.  So if you open
the files in the right order you should not need this.  dup2 is only needed
if there is a gap in the fds used.

Eric
